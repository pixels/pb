//
//  VoicePackInfo.h
//  GoodPB
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VoicePackInfo : NSObject {
	NSString *voicePackID_;
	NSString *voicePackName_;
	NSString *bookID_;
	NSUInteger voicePackIndex_;
	NSDate *date_;
	BOOL owner_;
	
	NSManagedObject *managedObject_;
}

@property (nonatomic, readonly) NSString *voicePackID;
@property (nonatomic, readonly) NSString *voicePackName;
@property (nonatomic, readonly) NSString *bookID;
@property (nonatomic, readonly) NSUInteger voicePackIndex;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) BOOL owner;

- (id)initWithManagedObject:(NSManagedObject *)managedObject;

- (id)initWithValue:(NSString *)voicePackID
	  voicePackName:(NSString *)voicePackName
			 bookID:(NSString *)bookID
	 voicePackIndex:(NSUInteger)voicePackIndex
			   date:(NSDate *)date
			  owner:(BOOL)owner;

@end
