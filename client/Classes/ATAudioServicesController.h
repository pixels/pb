//
//  ATAudioServicesController.h
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/09/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ATAudioServicesController : NSObject {
	NSMutableDictionary *dict_;
}

- (BOOL)load:(NSString *)soundID soundPath:(NSString *)soundPath;
- (void)unload:(NSString *)soundID;
- (void)unloadAllSounds;
- (void)play:(NSString *)soundID;

@end
