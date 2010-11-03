//
//  BookInfo.h
//  GoodPB
//
//  Created by kikkawa on 10/09/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookInfo : NSObject {
	NSString *bookID_;
	NSUInteger pageCount_;
	NSString *title_;
	NSString *author_;
	NSString *language_;
	NSUInteger direction_;
}

@property (nonatomic, readonly) NSString *bookID;
@property (nonatomic, readonly) NSUInteger pageCount;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *author;
@property (nonatomic, readonly) NSString *language;
@property (nonatomic, readonly) NSUInteger direction;

- (id)initWithValue:(NSString *)bookID
		  pageCount:(NSUInteger)pageCount
			  title:(NSString *)title
			 author:(NSString *)author
		   language:(NSString *)language
		  direction:(NSUInteger)direction;

@end
