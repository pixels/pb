//
//  BookCollection.m
//  GoodPB
//
//  Created by kikkawa on 10/09/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoodPBAppDelegate.h"
#import "BookCollection.h"
#import "BookInfo.h"
#import "DirectionType.h"

@interface BookCollection (InternalMethods)
- (void)setup;
@end

@implementation BookCollection

#pragma mark -
#pragma mark Common methods

- (id)init {
	[super init];
	[self setup];
	
	dict_ = [[NSMutableDictionary alloc] init];
	list_ = [[NSMutableArray alloc] init];
	
	
	// Dummy data
	[self addWithValue:@"BOOK_JPN_00000000" pageCount:24 title:@"だあれだ　だれだ？" author:@"うしろ　よしあき（文）　長谷川義史（絵）" language:@"JPN" direction:DIRECTION_RIGHT];
	[self addWithValue:@"BOOK_JPN_00000001" pageCount:64 title:@"赤ちゃんにおくる絵本" author:@"とだ　こうしろう（絵）" language:@"JPN" direction:DIRECTION_LEFT];
	[self addWithValue:@"BOOK_USA_00000001" pageCount:64 title:@"For baby" author:@"KOHOSHIROU TODA (IMG)" language:@"USA" direction:DIRECTION_LEFT];
	[self addWithValue:@"BOOK_JPN_00000002" pageCount:28 title:@"まんじゅうこわい" author:@"川端　誠" language:@"JPN" direction:DIRECTION_LEFT];
	
	return self;
}

- (void)dealloc {
	[list_ release];
	[dict_ release];
	[super dealloc];
}

#pragma mark -
#pragma mark Class's methods

- (BOOL)add:(BookInfo *)bookInfo {
	if (bookInfo && ![dict_ objectForKey:bookInfo.bookID]) {
		[dict_ setValue:bookInfo forKey:bookInfo.bookID];
		[list_ addObject:bookInfo];
		return YES;
	}
	return NO;
}

- (BOOL)addWithValue:(NSString *)bookID
		   pageCount:(NSUInteger)pageCount
			   title:(NSString *)title
			  author:(NSString *)author
			language:(NSString *)language
		   direction:(NSUInteger)direction {
	BookInfo *bookInfo = [[BookInfo alloc] initWithValue:bookID pageCount:pageCount title:title author:author language:language direction:direction];
	BOOL success = [self add:bookInfo];
	[bookInfo release];
	return success;
}

- (BookInfo *)get:(NSString *)bookID {
	return [dict_ objectForKey:bookID];
}

- (BookInfo *)getAtIndex:(NSUInteger)index {
	return [list_ objectAtIndex:index];
}

- (void)swapIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)toIndex {
	BookInfo *item = [(BookInfo *)[list_ objectAtIndex:fromIndex] retain];
	[list_ removeObject:item];
	[list_ insertObject:item atIndex:toIndex];
	[item release];
}

- (void)remove:(NSString *)bookID {
	BookInfo *bookInfo = [self get:bookID];
	[list_ removeObject:bookInfo];
	[dict_ removeObjectForKey:bookID];
}

- (void)removeAtIndex:(NSUInteger)index {
	BookInfo *bookInfo = [list_ objectAtIndex:index];
	[list_ removeObjectAtIndex:index];
	[dict_ removeObjectForKey:bookInfo.bookID];
}

- (NSUInteger)count {
	return [dict_ count];
}

#pragma mark -
#pragma mark CoreData

- (void)setup {
	
	GoodPBAppDelegate *appDelegate = (GoodPBAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookInfo"
											  inManagedObjectContext:appDelegate.managedObjectContext];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookID" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[sortDescriptors release];
	[sortDescriptor release];
    [fetchRequest release];
}

@end
