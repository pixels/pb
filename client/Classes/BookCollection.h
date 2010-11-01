//
//  BookCollection.h
//  PictureBooks
//
//  Created by kikkawa on 10/09/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookInfo;

@interface BookCollection : NSObject {
	NSMutableDictionary *dict_;
	NSMutableArray *list_;
}

- (BOOL)add:(BookInfo *)bookInfo;
- (BOOL)addWithValue:(NSString *)bookID
		   pageCount:(NSUInteger)pageCount
			   title:(NSString *)title
			  author:(NSString *)author
			language:(NSString *)language
		   direction:(NSUInteger)direction;
- (BookInfo *)get:(NSString *)bookID;
- (BookInfo *)getAtIndex:(NSUInteger)index;
- (void)swapIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)toIndex;
- (void)remove:(NSString *)bookID;
- (void)removeAtIndex:(NSUInteger)index;
- (NSUInteger)count;

@end
