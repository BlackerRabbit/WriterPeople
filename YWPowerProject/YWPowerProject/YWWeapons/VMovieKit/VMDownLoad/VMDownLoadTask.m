//
//  VMDownLoadTask.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/5.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMDownLoadTask.h"
#import "NSString+VMKit.h"
#import "VMDataBaseManager.h"
#import "VMDownloadDefines.h"
#import <AFNetworking/AFNetworking.h>
#import "VMLog.h"
#import "VMRequestHelper.h"
#import "VMTools.h"


/*start状态包括downloading和waiting状态,
 *downloading状态包括retrying和ongoing两个状态
 *done状态包括success和failure两个状态
 */

/*
 |status
        |start
              |will start
              |stared
 
        |processing 
        |done
 
*/

/** task data base info
 
 id             int   //primary key 自增长
 task_id        text  //taskid
 main_url       text  //主下载地址
 path           text  //存储地址
 title          text  //标题
 description    text  //描述
 mimetype       text  //文件的mimetype
 state          text  //任务状态
 error          text  //错误原因
 md5            text  //md5值
 sha1           text  //sha1值
 length         text  //文件大小
 progress       text  //文件的进度
 create         text  //创建时间
 modify         text  //修改时间
 mobile_down    text  //是否允许移动网络下载，0:不可以，1：可以
 videoName      text  //影片的名字
 */


#define TASK_RETRY_TIMES 3

typedef NS_ENUM(NSInteger, VMDownloadStatus){
    
    VMDownLoadStatusDelete              = -100, //task被删除了
    
    VMDownloadStatusIniting             = 100, //task正在初始化
    
    VMDownloadStatusStarted             = 200, //task进入开始状态
    VMDownloadStatusDownloading         = 210, //task进入下载状态
    VMDownloadStatusRetry               = 211, //task进入retry状态
    VMDownloadStatusOngoing             = 212, //task进入ongoing状态
    VMDownloadStatusWaiting             = 220, //task进入等待状态
    
    
    VMDownloadStatusVerifying           = 300, //task进入验证状态
    
    VMDownloadStatusStop                = 400, //task进入停止状态
    VMDownloadStatusPaused              = 410, //task进入暂停状态
    VMDownloadStatusIOError             = 420, //task进入ioerror状态
    
    
    VMDownloadStatusDone                = 500, //task进入完成状态
    VMDownloadStatusSuccess             = 510, //task进入下载成功状态
    VMDownloadStatusError               = 520, //task进入下载失败状态
};


@interface VMDownLoadTask ()

@property (nonatomic, assign) VMDownloadStatus downloadStatus;
@property (nonatomic, strong) NSURLSessionDownloadTask *sessionDownloadTask;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDownloadInfo;

@property (nonatomic, assign) VMDownloadTaskEvent taskEvent;

@property (nonatomic, weak) VMDownLoadManager *downloadManager;


@property (nonatomic, strong) NSFileHandle *handler;

@property (nonatomic, assign) BOOL hasSendSize;
@property (nonatomic, assign) NSTimeInterval previousTime;
@property (nonatomic, assign) int64_t previousByte;
@property (nonatomic, assign) NSTimeInterval betweentTimeInterval;//间隔的时间

//@property (nonatomic, assign) int64_t thisTimeWrite;
@end


@implementation VMDownLoadTask

-(void)dealloc{
    [self unregisterFromKVO];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark-
#pragma mark------初始化------

-(instancetype)initWithInfo:(NSDictionary *)info{
    self = [super init];
    if (self) {
        /**从数据库恢复的数据.
         */
        self.mainID = [NSString stringWithFormat:@"%@",info[@"ID"]];
        self.taskId = [NSString stringWithFormat:@"%@",info[@"task_id"]];
        self.mainURL = [NSString stringWithFormat:@"%@",info[@"main_url"]];
        self.path   = [NSString stringWithFormat:@"%@",info[@"path"]];
        self.title  = [NSString stringWithFormat:@"%@",info[@"title"]];
        self.desInfo = [NSString stringWithFormat:@"%@",info[@"description"]];
        
        self.mimetype = [NSString stringWithFormat:@"%@",info[@"mimetype"]];
        self.state  = [NSString stringWithFormat:@"%@",info[@"state"]];
        self.error  = [NSString stringWithFormat:@"%@",info[@"error"]];
        self.md5    = [NSString stringWithFormat:@"%@",info[@"md5"]];
        self.sha1 = [NSString stringWithFormat:@"%@",info[@"sha1"]];
        
        self.length = [NSString stringWithFormat:@"%@",info[@"length"]];
        self.progress = [NSString stringWithFormat:@"%@",info[@"progress"]];
        self.create = [NSString stringWithFormat:@"%@",info[@"create"]];
        self.modify = [NSString stringWithFormat:@"%@",info[@"modify"]];
        self.mobile_down = [NSString stringWithFormat:@"%@",info[@"mobile_down"]];
        self.canMobileDown = [self.mobile_down isEqualToString:@"1"] ? YES : NO;
        
        self.videoName = [NSString stringWithFormat:@"%@",info[@"video_name"]];
        self.isPaused = [[NSString stringWithFormat:@"%@",info[@"isPaused"]] isValid] ? [NSString stringWithFormat:@"%@",info[@"isPaused"]] : @"0";
        self.taskIdentifer = [NSString stringWithFormat:@"%@",info[@"task_identifer"]];
        /*****邪恶的分割线，下面是一些自己的数据*******/
         
        self.retryTimes = 0;
        self.taskDic = info;
        self.networkState = NETWORK_WIFI;
        self.didBegin = NO;
        self.canPushInQueue = YES;
        [self registerForKVO];
        return self;
    }
    return nil;
}

-(id)init{

    self = [super init];
    return self;
}

-(id)initWithTaskId:(NSString *)taskId{

    self = [self init];
    if (self) {
        if ([taskId isValid] == NO) {
            
            return nil;
        }
        _taskId = taskId;
        return self;
    }
    return self;
}

-(BOOL)canMobileDown{

    return _canMobileDown && [self.mobile_down isEqualToString:@"1"];
}


-(VMDownLoadTask *)taskCopy{
    VMDownLoadTask *task = [[VMDownLoadTask alloc]init];
    [task registerForKVO];
    task.mainID = [NSString stringWithFormat:@"%@",self.mainID];
    task.taskId = [NSString stringWithFormat:@"%@",self.taskId];
    task.mainURL = [NSString stringWithFormat:@"%@",self.mainURL];
    task.path = [NSString stringWithFormat:@"%@",self.path];
    task.title = self.title;
    task.desInfo = self.desInfo;
    task.mimetype = self.mimetype;
    task.state  = self.state;
    task.error = self.error;
    task.md5 = self.md5;
    task.sha1 = self.sha1;
    task.taskIdentifer = self.taskIdentifer;
    
    task.length = self.length;
    task.progress = self.progress;
    task.create = self.create;
    task.modify = self.modify;
    task.canMobileDown = self.canMobileDown;
    task.videoName = self.videoName;
    
    task.isPaused = self.isPaused;
    return task;
}

#pragma mark-
#pragma mark------业务处理的方法------

//转改转换
-(VMDownloadStatus)getStatusFrom:(NSInteger)status{
    
    switch (status) {
        case 100:return VMDownloadStatusIniting;
        case 200:return VMDownloadStatusStarted;
        case 210:return VMDownloadStatusDownloading;
        case 211:return VMDownloadStatusRetry;
        case 212:return VMDownloadStatusOngoing;
        case 220:return VMDownloadStatusWaiting;
        case 300:return VMDownloadStatusVerifying;
        case 400:return VMDownloadStatusStop;
        case 410:return VMDownloadStatusPaused;
        case 420:return VMDownloadStatusIOError;
        case 500:return VMDownloadStatusDone;
        case 510:return VMDownloadStatusSuccess;
        case 520:return VMDownloadStatusError;
        default:
            break;
    }
    return VMDownloadStatusIniting;
}

-(BOOL)isCancelledReasonUserForceQuitApplicationOrBackgroundUpdatesDisabledForError:(NSError *)error{
    NSInteger errorReason = [error.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] integerValue];
    if (errorReason == NSURLErrorCancelledReasonUserForceQuitApplication ||
        errorReason == NSURLErrorCancelledReasonBackgroundUpdatesDisabled ||
        error.code != NSURLErrorCancelled ) {
        return YES;
    }
    return NO;
}


#pragma mark-
#pragma mark------task 更新一些乱七八糟的东西------

-(void)taskPushedIntoQueue{
    if (self.willBeginBlock) {
        self.willBeginBlock(self);
    }
}

-(void)updateProgressWithbytesWritten:(int64_t)bytesWritten
                         totalWritten:(int64_t)totalBytesWritten
                        totalExpected:(int64_t)totalBytesExpectedToWrite{

    
    __weak typeof(self)weakSelf = self;
    if (self.previousTime == 0) {
        self.previousTime = [[NSDate date]timeIntervalSince1970];
    }
    if (self.previousByte == 0) {
        self.previousByte = 0;
    }
    if (self.betweentTimeInterval == 0 ) {
        self.betweentTimeInterval = 0;
    }
    
    double_t currentProcess = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    self.taskRealProgress = currentProcess * 100;
    
    
    NSTimeInterval writeTime = [[NSDate date]timeIntervalSince1970];
    NSTimeInterval timeDistance = writeTime - self.previousTime;
    self.previousTime = writeTime;
    self.betweentTimeInterval += timeDistance;
    if (self.betweentTimeInterval == 0) {
        
    }else if(self.betweentTimeInterval >= 1){
        float_t speed = (double_t)(totalBytesWritten - self.previousByte) * .1f / (self.betweentTimeInterval * .1f);
        self.taskDownloadSpeed = [VMTools fileSizeWithByte:(long long)speed];
        self.previousByte = totalBytesWritten;
        self.betweentTimeInterval = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            
            double_t currentProcess = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            NSString *progressTemp = [NSString stringWithFormat:@"%f",currentProcess];
            strongSelf.progress = progressTemp;
            if (strongSelf.progress.length == 0 || strongSelf.progress.length > 10) {
                
            }
            strongSelf.state = @"ongoing";
        });
    }
}


#pragma mark-
#pragma mark------

-(void)registerForKVO{

    for (NSString *keyPath in [self obserableKeyPaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:@"VMDOWNLOAD_TASK_CONTEXT"];
    }
}

-(NSArray *)obserableKeyPaths{
    
    return @[@"progress",
             @"state",
             @"taskStateInfo",
             @"length",
             @"taskRealProgress",
             @"networkState",
             @"didBegin",
             @"canMobileDown",
             @"isPaused"];
}

-(void)unregisterFromKVO{

    for (NSString *keyPath in [self obserableKeyPaths]) {
        [self removeObserver:self forKeyPath:keyPath context:@"VMDOWNLOAD_TASK_CONTEXT"];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change
                      context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (context == @"VMDOWNLOAD_TASK_CONTEXT") {
            [self updateUIForKeyPath:keyPath];
        }
    });

}

-(void)updateUIForKeyPath:(NSString *)keyPath{
    if ([keyPath isEqualToString:@"progress"]) {
        if (self.downloadingBlock) {
            self.downloadingBlock(self, self.progress, self.taskStateInfo);
        }
    }else if ([keyPath isEqualToString:@"state"]){
        NSInteger stateNum = [self.state integerValue];
        switch (stateNum) {
            case 510:
            case 520:
                if (self.veryfyBlock)
                    self.veryfyBlock(self, [self.state isEqualToString:@"510"] ? YES : NO);
            ;break;
            case -100:{
                if (self.deleteBlock)
                    self.deleteBlock(self);
            };break;
            
            case 211:{
                if (self.retryBlock)
                    self.retryBlock(self, self.taskRealProgress, self.retryTimes);
            };break;
                
            case 420:{
                if (self.ioErrorBlock)
                    self.ioErrorBlock(self, self.taskRealProgress);
                
            };break;
                
                
                
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"length"]){
        
        if (!self.hasSendSize) {
            if (self.filesizeBlock) {
                self.hasSendSize = YES;
                self.filesizeBlock(self.length);
            }
        }
    }else if ([keyPath isEqualToString:@"taskRealProgress"]){
    
        if (self.realBlock) {
            self.realBlock(self, self.taskRealProgress);
        }
    }else if ([keyPath isEqualToString:@"networkState"]){
        if (self.netBlock) {
            self.netBlock(self,self.state,self.networkState,self.canMobileDown);
        }
    }else if ([keyPath isEqualToString:@"didBegin"]){
        if (self.beginBlock) {
            self.beginBlock(self);
        }
    }else if ([keyPath isEqualToString:@"canMobileDown"]){
    
    }else if ([keyPath isEqualToString:@"isPaused"]){
        if (self.pauseOrDownloadBlock) {
            BOOL isPaused = [self.isPaused isEqualToString:@"0"] ? NO : YES;
            self.pauseOrDownloadBlock(self, isPaused);
        }
        
    }
}

-(BOOL)isEqual:(id)object{
    VMDownLoadTask *task = (VMDownLoadTask *)object;
    if ([self.taskId isEqualToString:task.taskId]) {
        return YES;
    }else
        return [super isEqual:object];
}

@end
