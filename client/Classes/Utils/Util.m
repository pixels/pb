//
//  Util.m
//  WePublish
//
//  Created by Yusuke Kikkawa on 10/07/13.
//  Copyright 2010 3di. All rights reserved.
//

#import "CommonCrypto/CommonDigest.h"
#import "Util.h"
#include <mach/mach.h>

@implementation Util

+ (NSString *)getLocalDocument {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)getBandleFile:(NSString *)filename type:(NSString *)type {
	return [[NSBundle mainBundle] pathForResource:filename ofType:type];
}

+ (BOOL)isExist:(NSString *)path {
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString *)getMD5FromString:(NSString*)code {
	const char *cstr = [code UTF8String]; // C言語の文字列を取得する
	return [self getMD5OfByte:cstr];
}

+ (NSString *)getMD5ChecksumOfFile:(NSString*)pathOfFile {
	const char *cstr = [[NSData dataWithContentsOfFile:pathOfFile] bytes];
	return [self getMD5OfByte:cstr];
}

+ (NSString *)getMD5OfByte:(const char *)bytes {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(bytes, strlen(bytes), result);
	
	return [self array2hexForMD5:result];
}

+ (NSString *)array2hexForMD5:(unsigned char *)value {
	return [NSString
			stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			value[0], value[1],
			value[2], value[3],
			value[4], value[5],
			value[6], value[7],
			value[8], value[9],
			value[10], value[11],
			value[12], value[13],
			value[14], value[15]];
}

+ (NSDate *)string2Date:(NSString *)dateString {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setTimeStyle:NSDateFormatterFullStyle];
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
	NSDate *date = [df dateFromString:dateString];
	[df release];
	
	return date;
}

+ (NSString *)makeBookPathFormat:(NSString *)dir pageNo:(NSUInteger)pageNo extension:(NSString *)extension {
	return [[NSString alloc] initWithFormat:@"%@/%04d.%@", dir, pageNo, extension];
}

+ (CGSize)makeAspectFitCGSize:(CGSize)origin target:(CGSize)target {
	float xRate = origin.width / target.width;
	float yRate = origin.height / target.height;
	
	CGSize tmp;
	if (xRate < yRate) {
		tmp = CGSizeMake(origin.width / yRate, origin.height / yRate);
	}
	else {
		tmp = CGSizeMake(origin.width / xRate, origin.height / xRate);
	}
	
	return tmp;
}

+ (UIImage *)resizeUIImage:(UIImage *)image width:(NSUInteger)width height:(NSUInteger)height aspectFit:(BOOL)aspectFit {
	CGImageRef imageRef = [image CGImage];
	size_t w = CGImageGetWidth(imageRef);
	size_t h = CGImageGetHeight(imageRef);
	
	CGSize resize;
	if (aspectFit) {
		resize = [self makeAspectFitCGSize:CGSizeMake(w, h) target:CGSizeMake(width, height)];
	}
	else {
		resize = CGSizeMake(width, height);
	}

	UIGraphicsBeginImageContext(CGSizeMake(resize.width, resize.height));
	[image drawInRect:CGRectMake(0, 0, resize.width, resize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}

+ (void)resizeAndWriteUIImage:(UIImage *)image outputPath:(NSString *)outputPath width:(NSUInteger)width height:(NSUInteger)height aspectFit:(BOOL)aspectFit {
	
	UIImage* newImage = [self resizeUIImage:image width:width height:height aspectFit:aspectFit];
	
	NSData *data = [[NSData alloc] initWithData:UIImageJPEGRepresentation(newImage, 0)];
	//	NSData *data = [[NSData alloc] initWithData:UIImagePNGRepresentation(newImage)];
	[data writeToFile:outputPath atomically:YES];
	[data release];
}

+ (void)resizeAndWriteUIImageFromPath:(NSString *)filePath outputPath:(NSString *)outputPath width:(NSUInteger)width height:(NSUInteger)height aspectFit:(BOOL)aspectFit {
	
	// Load
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
	[self resizeAndWriteUIImage:image outputPath:outputPath width:width height:height aspectFit:aspectFit];
	[image release];
}

+ (NSUInteger)realMemory {
	struct task_basic_info t_info;
	mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
	if (task_info(current_task(), TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count)!= KERN_SUCCESS) {
		NSLog(@"%s(): Error in task_info(): %s", __FUNCTION__, strerror(errno));
	}
	
//	// 物理メモリの使用量(byte) - Activity MonitorのReal Memoryに該当
//	u_int rss = t_info.resident_size;
	
//	// 仮想メモリの使用量(byte) - Activity MonitorのVirtual Memoryに該当??
//	u_int vs = t_info.virtual_size;
	
	return t_info.resident_size;
}

@end
