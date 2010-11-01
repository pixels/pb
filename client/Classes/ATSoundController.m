//
//  ATSoundController.m
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/09/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ATSoundController.h"


@interface ATSoundController (InternalMethods)

static void propertyListenerCallback(void *inUserData, AudioQueueRef queueObject, AudioQueuePropertyID	propertyID);
- (void)playBackIsRunningStateChanged;

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer);
- (void)callbackForBuffer:(AudioQueueBufferRef)buffer;
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

@end


@implementation ATSoundController
@synthesize status = status_;
@synthesize queue = queue_;
@synthesize currentPacket = currentPacket_;
@synthesize audioFile = audioFile_;

static void AudioInputCallback(  
							   void* inUserData,  
							   AudioQueueRef inAQ,  
							   AudioQueueBufferRef inBuffer,  
							   const AudioTimeStamp *inStartTime,  
							   UInt32 inNumberPacketDescriptions,  
							   const AudioStreamPacketDescription *inPacketDescs)  
{  
	ATSoundController *recorder = (ATSoundController *)inUserData;  
	OSStatus status = AudioFileWritePackets(  
											recorder.audioFile,  
											NO,  
											inBuffer->mAudioDataByteSize,  
											inPacketDescs,  
											recorder.currentPacket,  
											&inNumberPacketDescriptions,  
											inBuffer->mAudioData);  
	
	if (status == noErr) {
		recorder.currentPacket += inNumberPacketDescriptions;
		AudioQueueEnqueueBuffer(recorder.queue, inBuffer, 0, nil);
	}
	
	NSLog(@"AudioInputCallback");
}

- (id)init {
	[super init];
	
	[self statusChange:StatusModeWait];
	trackClosed_ = YES;
	
	return self;
}

- (void)dealloc {
	
	if (status_ == StatusModeRecording) {
		[self stop];
	}
	else if (status_ == StatusModePlaying) {
		[self close];
	}
	
	[super dealloc];
}

- (void)statusChange:(StatusMode)mode {
	if (mode == StatusModeWait) {
		// reset variables.
		bufferCount_ = 0;
	}
	else if (mode == StatusModeRecording) {
	}
	else if (mode == StatusModePlaying) {
	}
	
	status_ = mode;
	
//	NSLog(@"statusChange mode: %d", mode);
}

- (void)initDataFormat {
	// AIFF 16bit 44.1kHz STEREO
	dataFormat_.mSampleRate = 44100.0f;
	dataFormat_.mFormatID = kAudioFormatLinearPCM;
	dataFormat_.mFormatFlags =
	kLinearPCMFormatFlagIsBigEndian |
	kLinearPCMFormatFlagIsSignedInteger |
	kLinearPCMFormatFlagIsPacked;
	dataFormat_.mBitsPerChannel = 16;
	dataFormat_.mChannelsPerFrame = 2;
	dataFormat_.mFramesPerPacket = 1;
	dataFormat_.mBytesPerFrame = 4;
	dataFormat_.mBytesPerPacket = 4;
	dataFormat_.mReserved = 0;
	
	
	//  WAVE 8bit 48kHz MONO
	//	AudioStreamBasicDescription wavFormat;
	//	wavFormat_.mSampleRate = 48000.0;
	//	wavFormat_.mFormatID = kAudioFormatLinearPCM;
	//	wavFormat_.mFormatFlags = kAudioFormatFlagIsPacked; //WAVの8bitはunsigned
	//	wavFormat_.mBitsPerChannel = 8;
	//	wavFormat_.mChannelsPerFrame = 1;
	//	wavFormat_.mFramesPerPacket = 1;
	//	wavFormat_.mBytesPerFrame = 1;
	//	wavFormat_.mBytesPerPacket = 1;
	//	wavFormat_.mReserved = 0;
	
	
	//  AAC 44.1kHz STEREO
	//	AudioStreamBasicDescription m4aFormat;
	//	m4aFormat_.mSampleRate = 44100.0;
	//	m4aFormat_.mFormatID = kAudioFormatMPEG4AAC;
	//	m4aFormat_.mFormatFlags = kAudioFormatFlagIsBigEndian;
	//	m4aFormat_.mBytesPerPacket = 0;
	//	m4aFormat_.mFramesPerPacket = 1024;
	//	m4aFormat_.mBytesPerFrame = 0;
	//	m4aFormat_.mChannelsPerFrame = 2;
	//	m4aFormat_.mBitsPerChannel = 0;
	//	m4aFormat_.mReserved = 0;
}

- (void)record:(NSString *)path {
	[self statusChange:StatusModeRecording];
	[self initDataFormat];

	CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation(nil, (const UInt8 *)[path UTF8String], [path length], NO);
	currentPacket_ = 0;
	
	AudioQueueNewInput(&dataFormat_, AudioInputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue_);
	AudioFileCreateWithURL(fileURL, kAudioFileAIFFType, &dataFormat_, kAudioFileFlags_EraseFile, &audioFile_);
	CFRelease(fileURL);
	
	UInt32 cookieSize;
	if (AudioQueueGetPropertySize(queue_, kAudioQueueProperty_MagicCookie, &cookieSize) == noErr) {
		char* magicCookie = (char *) malloc (cookieSize);
		if (AudioQueueGetProperty(queue_, kAudioQueueProperty_MagicCookie, magicCookie, &cookieSize) == noErr) {
			AudioFileSetProperty(audioFile_, kAudioFilePropertyMagicCookieData, cookieSize, magicCookie);
		}
		free (magicCookie);
	}
	
	for(int i = 0; i < NUM_BUFFERS; i++) {
		AudioQueueAllocateBuffer(queue_, (dataFormat_.mSampleRate * BUFFER_POOL_SECOND) * dataFormat_.mBytesPerFrame, &buffers_[i]);
		AudioQueueEnqueueBuffer(queue_, buffers_[i], 0, nil);
	}
	AudioQueueStart(queue_, nil);
}

-(void)stop {
	AudioQueueFlush(queue_);
	AudioQueueStop(queue_, NO);
	for(int i = 0; i < NUM_BUFFERS; i++) {
		AudioQueueFreeBuffer(queue_, buffers_[i]);  
	}  
	
	AudioQueueDispose(queue_, YES);  
	AudioFileClose(audioFile_);
	
	[self statusChange:StatusModeWait];
}

- (void)close
{
	if (trackClosed_)
		return;
	
	trackClosed_ = YES;
	
	AudioQueueStop(queue_, YES);
	AudioQueueDispose(queue_, YES);  
	AudioFileClose(audioFile_);
	
	[self statusChange:StatusModeWait];
}

- (void)load:(NSString *)path {
	UInt32 size;
	UInt32 maxPacketSize;
	char *cookie;
	int i;
	
	// try to open up the file using the specified path
	if (noErr != AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath:path], 0x01, 0, &audioFile_)) {
		NSLog(@"[ERROR] ATSoundController - load: could not open audio file. Path given was: %@", path);
		return;
	}
	
	// get the data format of the file
	size = sizeof(dataFormat_);
	AudioFileGetProperty(audioFile_, kAudioFilePropertyDataFormat, &size, &dataFormat_);
	
	// create a new playback queue using the specified data format and buffer callback
	AudioQueueNewOutput(&dataFormat_, BufferCallback, self, nil, nil, 0, &queue_);
	
	// calculate number of packets to read and allocate space for packet descriptions if needed
	if (dataFormat_.mBytesPerPacket == 0 || dataFormat_.mFramesPerPacket == 0) {
		// since we didn't get sizes to work with, then this must be VBR data (Variable BitRate), so
		// we'll have to ask Core Audio to give us a conservative estimate of the largest packet we are
		// likely to read with kAudioFilePropertyPacketSizeUpperBound
		size = sizeof(maxPacketSize);
		AudioFileGetProperty(audioFile_, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
		if (maxPacketSize > BYTES_OF_BUFFERS) {
			maxPacketSize = BYTES_OF_BUFFERS;
			NSLog(@"[WARN] ATSoundController - load: had to limit packet size requested for file: %@", [path lastPathComponent]);
		}
		numPacketsToRead_ = BYTES_OF_BUFFERS / maxPacketSize;
		
		// will need a packet description for each packet since this is VBR data, so allocate space accordingly
		packetDescs_ = malloc(sizeof(AudioStreamPacketDescription) * numPacketsToRead_);
	}
	else {
		// for CBR data (Constant BitRate), we can simply fill each buffer with as many packets as will fit
		numPacketsToRead_ = BYTES_OF_BUFFERS / dataFormat_.mBytesPerPacket;
		
		// don't need packet descriptions for CBR data
		packetDescs_ = nil;
	}
	
	// see if file uses a magic cookie (a magic cookie is meta data which some formats use)
	AudioFileGetPropertyInfo(audioFile_, kAudioFilePropertyMagicCookieData, &size, nil);
	if (size > 0) {
		// copy the cookie data from the file into the audio queue
		cookie = malloc(sizeof(char) * size);
		AudioFileGetProperty(audioFile_, kAudioFilePropertyMagicCookieData, &size, cookie);
		AudioQueueSetProperty(queue_, kAudioQueueProperty_MagicCookie, cookie, size);
		free(cookie);
	}
	
	// we want to know when the playing state changes so we can properly dispose of the audio queue when it's done
	AudioQueueAddPropertyListener(queue_, kAudioQueueProperty_IsRunning, propertyListenerCallback, self);
	
	// allocate and prime buffers with some data
	packetIndex_ = 0;
	for (i = 0; i < NUM_BUFFERS; i++) {
		AudioQueueAllocateBuffer(queue_, BYTES_OF_BUFFERS, &buffers_[i]);
		if ([self readPacketsIntoBuffer:buffers_[i]] == 0) {
			// this might happen if the file was so short that it needed less buffers than we planned on using
			break;
		}
	}
	
	trackClosed_ = NO;
	trackEnded_ = NO;
}

- (BOOL)play:(NSString *)path {

	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSLog(@"[ERROR] ATSoundController - play: The file isn't exsit. path: %@", path);
		return NO;
	}
	
	
	[self statusChange:StatusModePlaying];
	
	if (trackClosed_) {
		[self load:path];
	}
	
	OSStatus result = AudioQueuePrime(queue_, 1, nil);	
	if (result) {
		NSLog(@"[ERROR] ATSoundController - play: error priming AudioQueue");
		return NO;
	}
	
	AudioQueueStart(queue_, nil);
	return YES;
}

- (void)pause {
	if (trackClosed_)
		return;
	
	AudioQueuePause(queue_);
}

- (void)setGain:(Float32)gain {
	if (trackClosed_)
		return;

	AudioQueueSetParameter(queue_, kAudioQueueParam_Volume, gain);
}

- (void)setRepeat:(BOOL)yn {
	repeat_ = yn;
}

#pragma mark -
#pragma mark Callback

static void propertyListenerCallback(void *inUserData, AudioQueueRef queueObject, AudioQueuePropertyID	propertyID) {
	// redirect back to the class to handle it there instead, so we have direct access to the instance variables
	if (propertyID == kAudioQueueProperty_IsRunning) {
		[(ATSoundController *)inUserData playBackIsRunningStateChanged];
	}
}

- (void)playBackIsRunningStateChanged {
	if (trackEnded_) {
		
		// go ahead and close the track now
		[self close];
		
		// we're not in the main thread during this callback, so enqueue a message on the main thread to post notification
		// that we're done, or else the notification will have to be handled in this thread, making things more difficult
		[self performSelectorOnMainThread:@selector(postTrackFinishedPlayingNotification:) withObject:nil waitUntilDone:NO];
	}
}

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
	// redirect back to the class to handle it there instead, so we have direct access to the instance variables
	[(ATSoundController *)inUserData callbackForBuffer:buffer];
}

- (void)callbackForBuffer:(AudioQueueBufferRef)buffer {
	// I guess it's possible for the callback to continue to be called since this is in another thread, so to be safe,
	// don't do anything else if the track is closed, and also don't bother reading anymore packets if the track ended
	if (trackClosed_ || trackEnded_)
		return;
	
	if ([self readPacketsIntoBuffer:buffer] == 0) {
		if (repeat_) {
			// End Of File reached, so rewind and refill the buffer using the beginning of the file instead
			packetIndex_ = 0;
			[self readPacketsIntoBuffer:buffer];
		}
		else {
			// set it to stop, but let it play to the end, where the property listener will pick up that it actually finished
			AudioQueueStop(queue_, NO);
			trackEnded_ = YES;
		}
	}
}

- (void)postTrackFinishedPlayingNotification:(id)object {
	// if we're here then we're in the main thread as specified by the callback, so now we can post notification that
	// the track is done without the notification observer(s) having to worry about thread safety and autorelease pools
	[[NSNotificationCenter defaultCenter] postNotificationName:TRACK_FINISHED_PLAYING_EVENT object:self];
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer {
	UInt32 numBytes;
	UInt32 numPackets;
	
	// read packets into buffer from file
	numPackets = numPacketsToRead_;
	AudioFileReadPackets(audioFile_, NO, &numBytes, packetDescs_, packetIndex_, &numPackets, buffer->mAudioData);
	if (numPackets > 0) {
		// - End Of File has not been reached yet since we read some packets, so enqueue the buffer we just read into
		// the audio queue, to be played next
		// - (packetDescs ? numPackets : 0) means that if there are packet descriptions (which are used only for Variable
		// BitRate data (VBR)) we'll have to send one for each packet, otherwise zero
		buffer->mAudioDataByteSize = numBytes;
		AudioQueueEnqueueBuffer(queue_, buffer, (packetDescs_ ? numPackets : 0), packetDescs_);
		
		// move ahead to be ready for next time we need to read from the file
		packetIndex_ += numPackets;
	}
	
	return numPackets;
}

@end
