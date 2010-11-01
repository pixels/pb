//
//  VoicePackCollection.h
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VoicePackInfo;

@interface VoicePackCollection : NSObject <NSFetchedResultsControllerDelegate> {
	NSArray *sortArray_;
	NSEntityDescription *entity_;
	NSString *currentBookID_;
}

- (id)initWithBookID:(NSString *)bookID;
- (void)changeTargetBookByID:(NSString *)bookID;
- (BOOL)addWithValue:(NSString *)voicePackID
	  voicePackName:(NSString *)voicePackName
			 bookID:(NSString *)bookID
	  voicePackIndex:(NSUInteger)voicePackIndex
			   date:(NSDate *)date
			  owner:(BOOL)owner;
- (VoicePackInfo *)getAtIndex:(NSUInteger)index;
- (void)updateObjectAtIndexAndKey:(id)value index:(NSUInteger)index key:(NSString *)key;
- (void)swapIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)toIndex;
- (BOOL)removeAtIndex:(NSUInteger)index;
- (NSUInteger)count;

@end
