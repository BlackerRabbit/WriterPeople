//
//  VMLog.m
//  VMovieKit
//
//  Created by 吴宇 on 15/11/3.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMLog.h"
#import <DDTTYLogger.h>
#import <DDASLLogger.h>
#import <DDFileLogger.h>
#import <objc/runtime.h>

@implementation VMLog

/**
 *  初始化默认的日志系统
 *
 */
+ (void)initializeDefaultLogSystem
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //默认设置输出
        [self setupTTY];
        [self setupASL];
        [self shareFileManager];
    });
}

/**
 *  往Xcode console 输出日志
 */
+ (void)setupTTY {
    DDTTYLogger *TTY = [DDTTYLogger sharedInstance];
    [DDLog addLogger:TTY withLevel:DDLogLevelVerbose];
    [TTY setColorsEnabled:YES];
}

/**
 *  往Console.app   输出日志
 */
+ (void)setupASL {
    DDASLLogger *ASL = [DDASLLogger sharedInstance];
    [DDLog addLogger:ASL withLevel:DDLogLevelVerbose];
}

/**
 *  默认将日志存储在Logfile文件夹下
 */
+ (void)shareFileManager
{
    [self addOneFileLoggerWithFolderName:@"Logfile"];
}


+ (void)addOneFileLoggerWithFolderName:(NSString *)folerName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [dirPath stringByAppendingPathComponent:folerName];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        if(![fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil])
            DDLogError(@"Error: Create folder failed");
    }
    DDLogInfo(@"shareFileManagerWithFolerName ---- %@",filePath);
    
    DDLogFileManagerDefault *fileLoggerManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:filePath];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileLoggerManager];
    
    [fileLogger setMaximumFileSize: (1024 * 100)];
    [fileLogger setRollingFrequency:(60*60*24)];
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:7];
    [fileLogger setLogFormatter:[[DDLogFileFormatterDefault alloc] init]];
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelDebug];
}



@end
