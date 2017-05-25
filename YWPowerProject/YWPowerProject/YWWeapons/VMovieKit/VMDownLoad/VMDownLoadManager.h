//
//  VMDownLoadManager.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/5.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VMDownLoadTask;
#define TASK_TABLE @"VMDownloadTask"
#import <AFNetworking.h>

typedef NS_ENUM(NSInteger, NetworkStatus){
    NETWORK_WIFI   = 0,//WIFI状态
    NETWORK_MOBILE = 1,//3g状态
    NETWORK_NONE   = 2,//无网
    NETWORK_UNKNOW = 3,//神秘的状态
};

@interface VMDownLoadManager :NSObject
@property (nonatomic, assign) NSInteger maxDownloadNumber;
@property (nonatomic, assign) BOOL canDownLoadINMobile;
@property (nonatomic, copy) void(^DownloadDidFinishedFromBackground)();
@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();

+(VMDownLoadManager *)shareManager;

/**
 *根据传入的字典进行task的查找或创建
 */
-(VMDownLoadTask *)downloadTaskBy:(NSDictionary *)dic;

/**
 *根据传入的taskID进行task的查找或创建
 */
-(VMDownLoadTask *)downloadTaskByID:(NSString *)taskID;

/**
 *外部统一调用的开始task下载的方法
 */
-(void)startTask:(VMDownLoadTask *)task;

-(void)pauseTask:(VMDownLoadTask *)task;

//只有在3g网络下点击下载按钮的时候才会调用这个方法，所以，这种情况下，一般默认网络状况就是3g网
-(void)continueTaskMobileDownload:(VMDownLoadTask *)task;


-(void)deleteTask:(VMDownLoadTask *)task;

/**根据taskid返回task的信息，以字典的形式
 */
-(NSDictionary *)taskDictionaryInfoByID:(NSString *)taskId;

@end
