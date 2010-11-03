//
//  ATSoundController.h
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/09/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>

#define BYTES_OF_BUFFERS 0x10000
#define NUM_BUFFERS 3
#define BUFFER_POOL_SECOND 0.5f
#define TRACK_FINISHED_PLAYING_EVENT @"TRACK_FINISHED_PLAYING_EVENT"

typedef enum {
	StatusModeWait,
	StatusModeRecording,
	StatusModePlaying,
} StatusMode;

@interface ATSoundController : NSObject {
	StatusMode status_;
	NSUInteger bufferCount_;
	
	AudioFileID audioFile_;
	AudioStreamBasicDescription dataFormat_;
	AudioQueueRef queue_;
	AudioQueueBufferRef buffers_[NUM_BUFFERS];
	SInt64 currentPacket_;
	
	UInt64 packetIndex_;
	UInt32 numPacketsToRead_;
	AudioStreamPacketDescription *packetDescs_;
	BOOL repeat_;
	BOOL trackClosed_;
	BOOL trackEnded_;	
}

@property (nonatomic, assign, readonly) StatusMode status;
@property (nonatomic, assign) AudioQueueRef queue;
@property (nonatomic, assign) SInt64 currentPacket;
@property (nonatomic, assign) AudioFileID audioFile;

- (void)statusChange:(StatusMode)mode;
- (void)initDataFormat;
- (void)record:(NSString *)path;
- (void)stop;
- (BOOL)play:(NSString *)path;
- (void)load:(NSString *)path;
- (void)pause;
- (void)close;
- (void)setRepeat:(BOOL)yn;
- (void)setGain:(Float32)gain;

static void AudioInputCallback(  
							   void* inUserData,  
							   AudioQueueRef inAQ,  
							   AudioQueueBufferRef inBuffer,  
							   const AudioTimeStamp *inStartTime,  
							   UInt32 inNumberPacketDescriptions,  
							   const AudioStreamPacketDescription *inPacketDescs  
							   );  


@end
