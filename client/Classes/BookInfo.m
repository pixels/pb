//
//  BookInfo.m
//  PictureBooks
//
//  Created by kikkawa on 10/09/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BookInfo.h"


@implementation BookInfo
@synthesize bookID = bookID_;
@synthesize pageCount = pageCount_;
@synthesize title = title_;
@synthesize author = author_;
@synthesize language = language_;
@synthesize direction = direction_;

#pragma mark -
#pragma mark Common methods

- (id)initWithValue:(NSString *)bookID
		  pageCount:(NSUInteger)pageCount
			  title:(NSString *)title
			 author:(NSString *)author
		   language:(NSString *)language
		  direction:(NSUInteger)direction {
	[super init];
	
	bookID_ = [bookID retain];
	pageCount_ = pageCount;
	title_ = [title retain];
	author_ = [author retain];
	language_ = [language retain];
	direction_ = direction;
	
	return self;
}

- (void)dealloc {
	[bookID_ release];
	[title_ release];
	[author_ release];
	[language_ release];
	[super dealloc];
}

@end
