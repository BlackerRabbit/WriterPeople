//
//  VMTools.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/2.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMTools.h"
#import <UIKit/UIKit.h>

#include <stdint.h>
#include <stdio.h>
#import "NSString+VMKit.h"
// Core Foundation
#include <CoreFoundation/CoreFoundation.h>

// Cryptography
#include <CommonCrypto/CommonDigest.h>

// In bytes
#define FileHashDefaultChunkSizeForReadingData 4096

#define kKeyChainGroupName nil // @"com.molihe.com.vmovier.vmapps" //nil
#define kKeyChainID_DeviceID @"kKeyChainID_DeviceID"

@implementation VMTools
+(void)alertMessage:(NSString *)mes{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc]initWithTitle:@"提示" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
    });

}

+(NSString *)documentPath{

    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return docsdir;
}


// Function
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
                                      size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

+(NSString *)md5File:(NSString *)path{
    CFStringRef md5hash = FileMD5HashCreateWithPath((__bridge CFStringRef)path,FileHashDefaultChunkSizeForReadingData);
    NSString *md5String = [(__bridge NSString *)md5hash copy];
    CFRelease(md5hash);
    return md5String;
}

+(KeychainItemWrapper*) keyChainWithDeviceId{
    
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:kKeyChainID_DeviceID accessGroup:kKeyChainGroupName];
    
    return keychin;
}



+(void) saveDeviceId:(NSString*)Did{
    
    if (Did && ![Did isEqualToString:@""])
    {
        KeychainItemWrapper* keychin = [self keyChainWithDeviceId];
        [keychin setObject:Did forKey:(__bridge id)kSecAttrAccount];
        
        [[NSUserDefaults standardUserDefaults]setObject:Did forKey:@"DeviceID"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


+(NSString *)getDeviceId{
    KeychainItemWrapper* keychin = [self keyChainWithDeviceId];
    NSString* deviceID = nil;
    deviceID =  [keychin objectForKey:(__bridge id)kSecAttrAccount];
    if ([deviceID isEqualToString:@""]) {
        deviceID = [[NSUserDefaults standardUserDefaults]objectForKey:@"DeviceID"];
    }
    return deviceID;
}

+(void)clearDeviceId{
    
    KeychainItemWrapper* keychin = [self keyChainWithDeviceId];
    [keychin resetKeychainItem];
}


//写入uuid
+(void)saveDeviceId{

    [VMTools saveDeviceIdIfEmpty:[VMTools uuidString]];
}

+(void)saveDeviceIdIfEmpty:(NSString *)Did{
    
    if (Did && [Did isValid]){
        NSString* saveDeviceId = [VMTools getDeviceId];
        if (saveDeviceId.length>0)
        {
            [VMTools saveDeviceId:saveDeviceId];
        }
        else{
            [VMTools saveDeviceId:Did];
        }
    }
}

+(NSString *)uuidString{
    return [[NSUUID UUID]UUIDString];
}


/**
 * @fileSize ,文件大小，NSInterger
 * return 单位为 G,M，K，B
 */
+(NSString *)fileSizeWithByte:(long long)fileSize{
    
    if (fileSize < 1024 * 1024) {
        
        return [NSString stringWithFormat:@"%.1fK",fileSize/1024.0];
    }else if(fileSize<1024*1024*1024){
        
        return [NSString stringWithFormat:@"%.1fM",fileSize/1024.0/1024.0];
    }else{
        
        return [NSString stringWithFormat:@"%.1fG",fileSize/1024.0/1024.0/1024.0];
    }
}

+(NSString*)downloadSmallFile:(NSString*)fileUrl fileName:(NSString*)fileName{

    NSString *FileName = [[VMTools documentPath] stringByAppendingPathComponent:fileName];//fileName就是保存文件的文件名
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Copy the database sql file from the resourcepath to the documentpath
    if ([fileManager fileExistsAtPath:FileName]){
        return FileName;
    }else{
        NSURL *url = [NSURL URLWithString:fileUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:FileName atomically:YES];//将NSData类型对象data写入文件，文件名为FileName
    }
    return FileName;
}

+(BOOL)openZip:(NSString*)zipPath unzipto:(NSString*)unzipPath{
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:zipPath] ){
        
        BOOL ret = [zip UnzipFileTo:unzipPath overWrite:YES];
        if( NO==ret ){
            
            NSLog(@"error");
        }
        [zip UnzipCloseFile];
        return ret;
    }
    return NO;
}

+(void)removeFile:(NSString *)filePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
}

-(void)test{
    
//    [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:1]

}


+(void)dealWithregularString:(NSString *)normalString{

    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[\r\n\f\t]*" options:0 error:&error];
    if (error) {
        return;
    }
    normalString = [regular stringByReplacingMatchesInString:normalString options:0 range:NSMakeRange(0, normalString.length) withTemplate:@"\n"];
}



@end
