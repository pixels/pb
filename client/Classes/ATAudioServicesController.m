//
//  ATAudioServicesController.m
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/09/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ATAudioServicesController.h"


@implementation ATAudioServicesController

- (id)init {
	[super init];

	dict_ = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)dealloc {
	[self unloadAllSounds];
	[dict_ release];
	
	[super dealloc];
}

- (BOOL)load:(NSString *)soundID soundPath:(NSString *)soundPath {
	if (![[NSFileManager defaultManager] fileExistsAtPath:soundPath]) {
		NSLog(@"[ERROR] ATSoundController - play: The file isn't exsit.");
		return NO;
	}
	
	SystemSoundID sound;
	CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation(nil, (const UInt8 *)[soundPath UTF8String], [soundPath length], NO);
	AudioServicesCreateSystemSoundID(fileURL, &sound);
	CFRelease(fileURL);
	NSNumber *soundIDRef = [[NSNumber alloc] initWithUnsignedLong:sound];
	[dict_ setObject:soundIDRef forKey:soundID];
	
	return YES;
}

- (void)unload:(NSString *)soundID {
	NSNumber *soundIDRef = (NSNumber *)[dict_ objectForKey:soundID];
	AudioServicesDisposeSystemSoundID([soundIDRef unsignedLongValue]);
	[soundIDRef release];
	[dict_ removeObjectForKey:soundID];
}

- (void)unloadAllSounds {
	NSString *soundID;
	for (soundID in dict_) {
		[self unload:soundID];
	}
}

- (void)play:(NSString *)soundID {
	
	NSNumber *soundIDRef = (NSNumber *)[dict_ objectForKey:soundID];
	if (soundIDRef) {
		AudioServicesPlaySystemSound([soundIDRef unsignedLongValue]);
	}
}

@end
