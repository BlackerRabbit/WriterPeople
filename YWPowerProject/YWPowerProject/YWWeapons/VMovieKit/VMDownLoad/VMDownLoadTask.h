//
//  VMDownLoadTask.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/5.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMDownLoadManager.h"
#import "VMovieRequest.h"

@class VMDownLoadTask;
//task的下载状态，所有的transtion状态都是过渡态，剩下的为终态

//task是否已经初始化完毕
typedef NS_ENUM(NSInteger, VMDownloadTaskStatus) {
    VMDownLoadTaskIniting = 0,
    VMDownLoadTaskPrepared = 1
};



//发送task的相关动作消息
typedef NS_ENUM(NSInteger, VMDownloadTaskEvent){
    
    TASK_START                 = 150, //任务启动
    TASK_PAUTSE                = 151, //任务暂停
    TASK_DELETE                = 152, //任务删除
    TASK_IOERROR               = 153, //任务io错误
    TASK_WAITING               = 154, //任务待命,即task进入waiting状态
    
    
    NETWORK_STATUS_CHANGE      = 200, //网络发生变化
    
    TASK_VERIFY_FAILURE        = 300, //md5或者hash验证失败
    TASK_VERIFY_SUCCESS        = 301, //md5或者hash验证成功
    
    TASK_THREAD_POOL_AVAILABLE = 400, //线程池可用
    
    TASK_FINIS                 = 401, //下载任务完成
    TASK_FAILURE               = 402, //下载任务失败
    TASK_RETRY                 = 403, //下载任务重试
    
    TASK_PROGRESS              = 404, //下载进度条
};


typedef void(^DownloadTaskGetFileSizeHandler)(NSString *length);

typedef void(^DownloadTaskVerifyCompleteHandler)(VMDownLoadTask *task,BOOL verifySuccess);
typedef void(^DownloadTaskDownloadingBlock)(VMDownLoadTask *task, NSString *progress, NSString *taskInfo);
typedef void(^DownloadTaskRealProgressBlock)(VMDownLoadTask *task, NSInteger realProgeress);
typedef void(^DownloadTaskNetWorkStateChangeBlock)(VMDownLoadTask *task, NSString *state ,NetworkStatus netStatus,BOOL candownloadMobile);
typedef void(^DownloadTaskDidBeginBlock)(VMDownLoadTask *task);
typedef void(^DownloadTaskDeleteBlock)(VMDownLoadTask *task);
typedef void(^DownloadTaskRetryBlock)(VMDownLoadTask *task, NSInteger realProgress, NSInteger retryTimes);
typedef void(^DownloadTaskIOErrorBlock)(VMDownLoadTask *task, NSInteger realProgeress);
typedef void(^DownloadTaskDidSeletedMobileDownload)(VMDownLoadTask *task , BOOL startInMobile);




typedef void(^DownloadTaskPauseOrDownloadBlock)(VMDownLoadTask *task, BOOL isPaused);

/**
 *task被成功创建，并且进入队列
 */
typedef void(^DownloadTaskWillBeginBlock)(VMDownLoadTask *task);

@interface VMDownLoadTask : NSObject

@property (nonatomic, strong) NSString *mainID;    //task在数据库里的主键
@property (nonatomic, strong) NSString *mainURL;    //下载的主url地址
@property (nonatomic, strong) NSString *path;       //存储的path
@property (nonatomic, strong) NSString *title;      //片子的标题
@property (nonatomic, strong) NSString *desInfo;    //片子的描述
@property (nonatomic, strong) NSString *mimetype;   //task的片源的类型
@property (nonatomic, strong) NSString *state;      //task的状态
@property (nonatomic, strong) NSString *error;      //task错误的原因
@property (nonatomic, strong) NSString *md5;        //md5校验值
@property (nonatomic, strong) NSString *sha1;       //sha1校验值
@property (nonatomic, strong) NSString *length;     //片子的长度
@property (nonatomic, copy)   NSString *progress;   //片子的下载进度
@property (nonatomic, strong) NSString *create;     //task的创建时间
@property (nonatomic, strong) NSString *modify;     //task的修改时间
@property (nonatomic, strong) NSString *mobile_down; // 字符串的形式记录是否可以3g下载
@property (nonatomic, assign) BOOL canMobileDown;   //task是否允许3g下载

@property (nonatomic, strong) NSString *videoName;  //影片的名字

@property (nonatomic, strong) NSString *taskIdentifer; //用来区分vmdownloadtask的标识，默认为@“”
@property (nonatomic, strong) NSString *appMd5;

/**
 *用来区分是被cancel掉的，还是cancelByProducingResumeData的
 */
@property (nonatomic, assign) BOOL isCancelledForResumeData;


/**
 *用来标识是不是被主动cancel的。只有当主动调用cancle的时候，才会使该属性为YES
 */
@property (nonatomic, assign) BOOL isCancelledForDelete;



/**
 *下载是否被手动暂停，如果是的话，下一次进入的时候，需要记住这个状态，默认为no
 */
@property (nonatomic, strong) NSString *isPaused;

@property (nonatomic, assign) NSInteger taskStatus;
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *resumDataPath;//task的resumdata存储的path

@property (nonatomic, strong) NSData *resumData;

@property (nonatomic, assign) NetworkStatus networkState;
@property (nonatomic, assign) BOOL didBegin;


@property (nonatomic, strong) NSDictionary *taskDic;
/**
 *下载速度，k,m,g
 */
@property (nonatomic, strong) NSString *taskDownloadSpeed;
@property (nonatomic, strong) NSString *taskDownloadingNetworkState;

/**
 *这是一个比较无奈的属性，实时的反溃下载的进度，告诉进度条，现在是个什么状况了
 */
@property (nonatomic, assign) NSInteger taskRealProgress;


/**
 *额外添加的一个属性，是否可以进队列。
 */
@property (nonatomic, assign) BOOL canPushInQueue;

@property (nonatomic, assign) NSInteger retryTimes;
@property (nonatomic, strong) NSString *taskStateInfo;
@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, copy) DownloadTaskDownloadingBlock downloadingBlock;
@property (nonatomic, copy) DownloadTaskVerifyCompleteHandler veryfyBlock;
@property (nonatomic, copy) DownloadTaskGetFileSizeHandler filesizeBlock;
@property (nonatomic, copy) DownloadTaskRealProgressBlock realBlock;
@property (nonatomic, copy) DownloadTaskNetWorkStateChangeBlock netBlock;
@property (nonatomic, copy) DownloadTaskDidBeginBlock beginBlock;
@property (nonatomic, copy) DownloadTaskWillBeginBlock willBeginBlock;
@property (nonatomic, copy) DownloadTaskDeleteBlock deleteBlock;
@property (nonatomic, copy) DownloadTaskRetryBlock retryBlock;

@property (nonatomic, copy) DownloadTaskIOErrorBlock ioErrorBlock;
@property (nonatomic, copy) DownloadTaskPauseOrDownloadBlock pauseOrDownloadBlock;

@property (nonatomic, copy) DownloadTaskDidSeletedMobileDownload mobileDownloadBlock;


-(instancetype)initWithInfo:(NSDictionary *)info;
-(id)initWithTaskId:(NSString *)taskId;
-(void)updateProgressWithbytesWritten:(int64_t)bytesWritten
                         totalWritten:(int64_t)totalBytesWritten
                        totalExpected:(int64_t)totalBytesExpectedToWrite;

-(VMDownLoadTask *)taskCopy;

-(void)taskPushedIntoQueue;

@end
