//
//  VMTools.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/2.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"
#import <ZipArchive.h>

@interface VMTools : NSObject
+(void)alertMessage:(NSString *)mes;


#pragma mark-
+(NSString *)documentPath;
//算文件的md5值
+(NSString *)md5File:(NSString *)path;



+(void)saveDeviceId:(NSString*)Did;
+(NSString *)getDeviceId;
+(void)clearDeviceId;

+(void)saveDeviceId;

+(NSString *)fileSizeWithByte:(long long)fileSize;

/**
 *下载小文件，返回文件的路径
 */
+(NSString*)downloadSmallFile:(NSString*)fileUrl fileName:(NSString*)fileName;
+(BOOL)openZip:(NSString*)zipPath unzipto:(NSString*)unzipPath;
+(void)removeFile:(NSString *)filePath;

+(NSString *)dealWithregularString:(NSString *)normalString;
@end
