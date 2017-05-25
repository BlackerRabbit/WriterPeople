//
//  VMLog.h
//  VMovieKit
//
//  Created by 吴宇 on 15/11/3.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDLog.h>
#import <UIKit/UIColor.h>


//VMlog级别设置
/*
 LOG_LEVEL_ERROR：只显示错误日志。
 LOG_LEVEL_WARN：包括：LOG_LEVEL_ERROR
 LOG_LEVEL_INFO：包括：LOG_LEVEL_WARN
 LOG_LEVEL_DEBUG：包括：LOG_LEVEL_INFO
 LOG_LEVEL_VERBOSE：包括：LOG_LEVEL_DEBUG
 LOG_LEVEL_OFF：关闭日志
 */

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


//日志输出类型
/*
DDLogError：定义输出错误文本
DDLogWarn：定义输出警告文本
DDLogInfo：定义输出信息文本
DDLogDebug：定义输出调试文本
DDLogVerbose：定义输出详细文本
 */

#define VMLogError(...)   DDLogError(__VA_ARGS__)
#define VMLogWarn(...)    DDLogWarn(__VA_ARGS__)
#define VMLogInfo(...)    DDLogInfo(__VA_ARGS__)
#define VMLogDebug(...)   DDLogDebug(__VA_ARGS__)
#define VMLogVerbose(...) DDLogVerbose(__VA_ARGS__)

@interface VMLog : NSObject

/**
 *  默认会初始化三个Logger对象来分别往 console.app/Xcode console / app沙箱中输出 message
 */
+ (void)initializeDefaultLogSystem;

/**
 *  添加另一个文件logger对象
 */
+ (void)addOneFileLoggerWithFolderName:(NSString *)folerName;
@end
