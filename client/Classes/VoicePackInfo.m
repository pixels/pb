//
//  VoicePackInfo.m
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VoicePackInfo.h"


@implementation VoicePackInfo
@synthesize voicePackID = voicePackID_;
@synthesize voicePackName = voicePackName_;
@synthesize bookID = bookID_;
@synthesize voicePackIndex = voicePackIndex_;
@synthesize date = date_;
@synthesize owner = owner_;

- (id)initWithManagedObject:(NSManagedObject *)managedObject {
    if ((self = [super init])) {
		managedObject_ = managedObject;
		
		NSNumber *num;
		
		voicePackID_ = [[managedObject_ valueForKey:@"voicePackID"] retain];
		voicePackName_ = [[managedObject_ valueForKey:@"voicePackName"] retain];
		bookID_ = [[managedObject_ valueForKey:@"bookID"] retain];
		
		num = (NSNumber *)[managedObject_ valueForKey:@"voicePackIndex"];
		voicePackIndex_ = [num intValue];
		
		date_ = [(NSDate *)[managedObject_ valueForKey:@"date"] retain];
		
		num = (NSNumber *)[managedObject_ valueForKey:@"owner"];
		owner_ = [num boolValue];
    }
	
	return self;
}

- (id)initWithValue:(NSString *)voicePackID
	  voicePackName:(NSString *)voicePackName
			 bookID:(NSString *)bookID
	 voicePackIndex:(NSUInteger)voicePackIndex
			   date:(NSDate *)date
			  owner:(BOOL)owner {
	[super init];
	
	voicePackID_ = [voicePackID retain];
	voicePackName_ = [voicePackName retain];
	bookID_ = [bookID retain];
	voicePackIndex_ = voicePackIndex;
	date_ = [date retain];
	owner_ = owner;
	
	return self;
}

- (void)dealloc {
	[voicePackID_ release];
	[voicePackName_ release];
	[bookID_ release];
	[date_ release];
	[super dealloc];
}

@end
