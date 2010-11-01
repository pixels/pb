//
//  FileUnzip.h
//  iNocco
//
//  Created by kikkawa on 10/08/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILE_UNZIP_REQUEST_EVENT @"FILE_UNZIP_REQUEST_EVENT"
#define REQUEST_FILEPATH @"REQUEST_FILEPATH"
#define REQUEST_OUTPUTPATH @"REQUEST_OUTPUTPATH"
#define REQUEST_REMOVE_ZIPFILE @"REQUEST_REMOVE_ZIPFILE"

@interface FileUnzip : NSObject {

}

+ (NSDictionary *)makeRequest:(NSString *)filePath outputPath:(NSString *)outputPath removeZipFile:(BOOL)removeZipFile;

- (void)unzip:(NSString *)filePath outputDir:(NSString *)outputDir removeZipFile:(BOOL)removeZipFile;

@end
