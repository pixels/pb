//
//  FileDownload.m
//  iNocco
//
//  Created by kikkawa on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileDownload.h"

#define DEFAULT_TIMEOUT_SEC 60

@implementation FileDownload
@synthesize timeout = timeout_;

- (id)init {
	
	if ([super init]) {
		timeout_ = DEFAULT_TIMEOUT_SEC;
	}
	return self;
}

- (BOOL)download:(NSString *)url filePath:(NSString *)filePath {
	
	if (conn_ || !url || !filePath) {
		return NO;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
									initWithURL:[NSURL URLWithString:url]
									cachePolicy:NSURLRequestUseProtocolCachePolicy
									timeoutInterval:timeout_
									];
	conn_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	path_ = [filePath retain];
	dataPool_ = [[NSMutableData alloc] init];
	
	[request release];
	
	return YES;
}

- (void)addTarget:(id)target action:(SEL)action forDownloadEvents:(FileDownloadEvent)downloadEvents {
	targetObject_ = target;

	switch (downloadEvents) {
		case FileDownloadEventEnded:
			actionEnded_ = action;
			break;

		case FileDownloadEventReceiveData:
			actionReceivedData_ = action;
			break;
	}
}

- (void)reset {
	
	if (path_) {
		[path_ release];
		path_ = nil;
	}
	
	if (conn_) {
		[conn_ release];
		conn_ = nil;
	}
	
	if (dataPool_) {
		[dataPool_ release];
		dataPool_ = nil;
	}
}

// レスポンスを受け取った時点で呼び出される。データ受信よりも前なので注意
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"didReceiveResponse length: %d", response.expectedContentLength);
    [dataPool_ setLength:0];
}

// データを受け取る度に呼び出される
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//	NSLog(@"didReceiveData length: %d", [data length]);

    [dataPool_ appendData:data];
	if (targetObject_ && actionReceivedData_) {
		NSNumber *lengthRef = [NSNumber numberWithUnsignedInt:[data length]];
		[targetObject_ performSelector:actionReceivedData_ withObject:lengthRef];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"Connection connection didReceiveAuthenticationChallenge, host: %@", challenge.protectionSpace.host);
	
//	if ([challenge proposedCredential]) {
//		[connection cancel];
//	}
//	else {
//		NSURLCredential *credential = [NSURLCredential credentialWithUser:AUTH_USERNAME password:AUTH_PASSWORD persistence:NSURLCredentialPersistenceNone];
//		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error: %@", [error localizedDescription]);

    [self reset];
}

// データを全て受け取ると呼び出される
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//	NSLog(@"connectionDidFinishLoading");
	
	[dataPool_ writeToFile:path_ atomically:YES];
	if (targetObject_ && actionEnded_) {
		[targetObject_ performSelector:actionEnded_ withObject:nil];
	}
    [self reset];
}

- (void)dealloc {
    [self reset];
	[super dealloc];
}

@end
