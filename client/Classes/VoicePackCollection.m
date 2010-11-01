//
//  VoicePackCollection.m
//  PictureBooks
//
//  Created by Yusuke Kikkawa on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "PictureBooksAppDelegate.h"
#import "VoicePackCollection.h"
#import "VoicePackInfo.h"

@interface VoicePackCollection (InternalMethods)
- (BOOL)dataSetup:(NSString *)bookID;
@end

@implementation VoicePackCollection

#pragma mark -
#pragma mark Common methods

- (id)initWithBookID:(NSString *)bookID {
	if ((self = [super init])) {
		currentBookID_ = [bookID retain];
		[self dataSetup:currentBookID_];
	}
	
	return self;
}

- (void)dealloc {
	[currentBookID_ release];
	[super dealloc];
}

#pragma mark -
#pragma mark Class's methods

- (void)changeTargetBookByID:(NSString *)bookID {
	[currentBookID_ release];
	currentBookID_ = [bookID retain];
	
	[self dataSetup:currentBookID_];
}

- (BOOL)addWithValue:(NSString *)voicePackID
	  voicePackName:(NSString *)voicePackName
			 bookID:(NSString *)bookID
	  voicePackIndex:(NSUInteger)voicePackIndex
			   date:(NSDate *)date
			  owner:(BOOL)owner {
	
	PictureBooksAppDelegate *appDelegate = (PictureBooksAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:[entity_ name] inManagedObjectContext:appDelegate.managedObjectContext];
	[mo setValue:[NSNumber numberWithInt:[self count]] forKey:@"number"];
	[mo setValue:voicePackID forKey:@"voicePackID"];
	[mo setValue:voicePackName forKey:@"voicePackName"];
	[mo setValue:bookID forKey:@"bookID"];
	[mo setValue:[NSNumber numberWithInt:voicePackIndex] forKey:@"voicePackIndex"];
	[mo setValue:date forKey:@"date"];
	[mo setValue:[NSNumber numberWithBool:owner] forKey:@"owner"];
	
	if (![[mo managedObjectContext] save:nil]) {
		NSLog(@"[ERROR] userinfoReset save missed");
		return NO;
	}
	
	return [self dataSetup:currentBookID_];
}

- (VoicePackInfo *)getAtIndex:(NSUInteger)index {
	NSManagedObject *managedObject = [sortArray_ objectAtIndex:index];
	VoicePackInfo *info = [[[VoicePackInfo alloc] initWithManagedObject:managedObject] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter release];
	return info;
}

- (void)updateObjectAtIndexAndKey:(id)value index:(NSUInteger)index key:(NSString *)key {
	NSManagedObject *mo = [sortArray_ objectAtIndex:index];
	[mo setValue:value forKey:key];
	
	if (![mo.managedObjectContext save:nil]) {
		NSLog(@"[ERROR] updateAtIndexAndKey mo save missed");
	}
}

- (void)swapIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)toIndex {
	NSManagedObject *fromMO = [sortArray_ objectAtIndex:fromIndex];
	VoicePackInfo *fromInfo = [[VoicePackInfo alloc] initWithManagedObject:fromMO];
	
	NSManagedObject *toMO = [sortArray_ objectAtIndex:toIndex];
	VoicePackInfo *toInfo = [[VoicePackInfo alloc] initWithManagedObject:toMO];
	
	[fromMO setValue:toInfo.voicePackID forKey:@"voicePackID"];
	[fromMO setValue:toInfo.voicePackName forKey:@"voicePackName"];
	[fromMO setValue:toInfo.bookID forKey:@"bookID"];
	[fromMO setValue:[NSNumber numberWithInt:toInfo.voicePackIndex] forKey:@"voicePackIndex"];
	[fromMO setValue:toInfo.date forKey:@"date"];
	[fromMO setValue:[NSNumber numberWithBool:toInfo.owner] forKey:@"owner"];
	
	if (![fromMO.managedObjectContext save:nil]) {
		NSLog(@"[ERROR] userinfoReset fromMO save missed");
	}
	
	[toMO setValue:fromInfo.voicePackID forKey:@"voicePackID"];
	[toMO setValue:fromInfo.voicePackName forKey:@"voicePackName"];
	[toMO setValue:fromInfo.bookID forKey:@"bookID"];
	[toMO setValue:[NSNumber numberWithInt:fromInfo.voicePackIndex] forKey:@"voicePackIndex"];
	[toMO setValue:fromInfo.date forKey:@"date"];
	[toMO setValue:[NSNumber numberWithBool:fromInfo.owner] forKey:@"owner"];
	
	if (![toMO.managedObjectContext save:nil]) {
		NSLog(@"[ERROR] userinfoReset toMO save missed");
	}
}

- (BOOL)removeAtIndex:(NSUInteger)index {
	PictureBooksAppDelegate *appDelegate = (PictureBooksAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObject *mo = [sortArray_ objectAtIndex:index];
	[appDelegate.managedObjectContext deleteObject:mo];
	
	if (![mo.managedObjectContext save:nil]) {
		NSLog(@"[ERROR] userinfoReset toMO save missed");
	}

	NSUInteger i = 0;
	NSUInteger count = 0;
	for (i; i < [sortArray_ count]; i++) {
		if (i == index) {
			continue;
		}
		
		mo = [sortArray_ objectAtIndex:i];
		[mo setValue:[NSNumber numberWithInt:count++] forKey:@"number"];
		[mo.managedObjectContext save:nil];
	}
	
	
	return [self dataSetup:currentBookID_];
}

- (NSUInteger)count {
//	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController_ sections] objectAtIndex:0];
//	return [sectionInfo numberOfObjects];
	return [sortArray_ count];
}

#pragma mark -
#pragma mark CoreData

- (BOOL)dataSetup:(NSString *)bookID {
	
	PictureBooksAppDelegate *appDelegate = (PictureBooksAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    entity_ = [NSEntityDescription entityForName:@"VoicePackInfo" inManagedObjectContext:appDelegate.managedObjectContext];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID == %@", bookID];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity_];
    [fetchRequest setFetchBatchSize:20];
	
	if (sortArray_) {
		[sortArray_ release];
		sortArray_ = nil;
	}
    sortArray_ = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] retain];
	
//	NSManagedObject *mo;
//	for (mo in sortArray_) {
//		NSLog(@"voicePackID: %@ bookID:%@", [mo valueForKey:@"voicePackID"], [mo valueForKey:@"bookID"]);
//	}
	
    [fetchRequest release];
	[sortDescriptors release];
	[sortDescriptor release];
	
	return YES;
}

@end
