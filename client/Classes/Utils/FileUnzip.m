//
//  FileUnzip.m
//  iNocco
//
//  Created by kikkawa on 10/08/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileUnzip.h"
#import "ZipArchive.h"

@implementation FileUnzip

- (id)init {
	if ([super init]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(onRequest:) name:FILE_UNZIP_REQUEST_EVENT object:nil];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private function

- (void)moveAndRename:(NSString *)outputPath targetPath:(NSString *)targetPath count:(NSUInteger)count {
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPath error:nil];
	NSString *path;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	for (path in files) {
		// Execute process of to remove child directory if root directory name is under root directory name.
		NSString *srcDir = [NSString stringWithFormat:@"%@/%@", targetPath, path];
		NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:srcDir error:nil];
		if ([attribs objectForKey:NSFileType] == NSFileTypeDirectory) {
			[self moveAndRename:outputPath targetPath:srcDir count:count];
		}
		else {
			count++;
			NSString *destDir = [NSString stringWithFormat:@"%@/%04d.%@", outputPath, count, [path pathExtension]];
			[[NSFileManager defaultManager] moveItemAtPath:srcDir toPath:destDir error:nil];
		}
	}
	[pool release];
	
	if (![outputPath isEqual:targetPath]) {
//		NSLog(@"FileUnzip.m moveAndRename remove targetPath: %@", targetPath);
		[[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
	}
}

+ (NSDictionary *)makeRequest:(NSString *)filePath outputPath:(NSString *)outputPath removeZipFile:(BOOL)removeZipFile {
	NSNumber *removeZipFileRef = [[NSNumber alloc] initWithBool:removeZipFile];
	NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
							  filePath,
							  REQUEST_FILEPATH,
							  outputPath,
							  REQUEST_OUTPUTPATH,
							  removeZipFileRef,
							  REQUEST_REMOVE_ZIPFILE,
							  nil];
	
	return userInfo;
}

- (void)unzip:(NSString *)filePath outputDir:(NSString *)outputDir removeZipFile:(BOOL)removeZipFile {
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if([za UnzipOpenFile:filePath]) {
		BOOL ret = [za UnzipFileTo:outputDir overWrite:YES];
		if(NO == ret) {
			NSLog(@"unzip error");
		}
		[za UnzipCloseFile];
	}
	[za release];

//	NSUInteger count = -1;
//	[self moveAndRename:outputPath targetPath:outputPath count:count];

	if (removeZipFile && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	}
}

- (void)onRequest:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	if (userInfo) {
		NSString *filePath = [userInfo objectForKey:REQUEST_FILEPATH];
		NSString *outputPath = [userInfo objectForKey:REQUEST_OUTPUTPATH];
		NSNumber *removeZipFileRef = [userInfo objectForKey:REQUEST_REMOVE_ZIPFILE];
		
		[self unzip:filePath outputPath:outputPath removeZipFile:[removeZipFileRef boolValue]];
		[removeZipFileRef release];
	}
	[userInfo release];
}

- (void)dealloc {
	[super dealloc];
}

@end
