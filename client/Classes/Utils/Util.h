//
//  Util.h
//  WePublish
//
//  Created by Yusuke Kikkawa on 10/07/13.
//  Copyright 2010 3di. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface Util : NSObject {

}

+ (NSString *)getLocalDocument;
+ (NSString *)getBandleFile:(NSString *)filename type:(NSString *)type;
+ (BOOL)isExist:(NSString *)path;
+ (NSString *)getMD5ChecksumOfFile:(NSString*)pathOfFile;
+ (NSString *)getMD5OfByte:(const char *)bytes;
+ (NSString *)array2hexForMD5:(unsigned char *)value;
+ (NSDate *)string2Date:(NSString *)dateString;
+ (NSString *)makeBookPathFormat:(NSString *)dir pageNo:(NSUInteger)pageNo extension:(NSString *)extension;
+ (CGSize)makeAspectFitCGSize:(CGSize)origin target:(CGSize)targe;
+ (UIImage *)resizeUIImage:(UIImage *)image width:(NSUInteger)width height:(NSUInteger)height aspectFit:(BOOL)aspectFit;
+ (void)resizeAndWriteUIImage:(UIImage *)image outputPath:(NSString *)outputPath width:(NSUInteger)width height:(NSUInteger)height aspectFit:(BOOL)aspectFit;
+ (void)resizeAndWriteUIImageFromPath:(NSString *)filePath outputPath:(NSString *)outputPath width:(NSUInteger)width height:(NSUInteger)height aspectFit:(BOOL)aspectFit;
+ (NSUInteger)realMemory;

@end
