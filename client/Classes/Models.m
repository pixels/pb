//
//  Models.m
//  PictureBooks
//
//  Created by kikkawa on 10/10/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Models.h"

@implementation Models
@synthesize bookCollection = bookCollection_;
@synthesize voicePackCollection = voicePackCollection_;

- (id)init {
	if ((self = [super init])) {
	}
	
	bookCollection_ = [[BookCollection alloc] init];
	voicePackCollection_ = [[VoicePackCollection alloc] init];

	return self;
}

- (void)dealloc {
	[voicePackCollection_ release];
	[bookCollection_ release];
	[super dealloc];
}

@end
