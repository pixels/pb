//
//  FileDownload.h
//  iNocco
//
//  Created by kikkawa on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FileDownloadEventEnded = 0,
    FileDownloadEventReceiveData = 1,
} FileDownloadEvent;

@interface FileDownload : NSObject {
@private
	NSURLConnection *conn_;
	NSMutableData *dataPool_;
	NSString *path_;
	NSTimeInterval timeout_;
	
	id targetObject_;
	SEL actionEnded_;
	SEL actionReceivedData_;
}

@property (nonatomic, assign) NSTimeInterval timeout;

- (BOOL)download:(NSString *)url filePath:(NSString *)filePath;
- (void)addTarget:(id)target action:(SEL)action forDownloadEvents:(FileDownloadEvent)downloadEvents;
- (void)reset;

@end
