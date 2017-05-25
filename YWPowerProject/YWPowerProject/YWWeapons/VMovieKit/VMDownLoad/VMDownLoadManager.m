
/*
 *发送delete消息时候的数据同步问题
 *running当只允许wifi的时候，如果切换到3g状态，会发生什么事情,什么都不会发生。。其实。。
 *
 *
 *
 *
 *
 */


//
//  VMDownLoadManager.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/5.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMDownLoadManager.h"
#import "NSString+VMKit.h"
#import <AFNetworking/AFNetworking.h>
#import "VMDataBaseManager.h"
#import "VMDownLoadTask.h"
#import "VMTools.h"
#import "VMLog.h"

@interface VMSessionManager : AFURLSessionManager
@end

static NSString * const kBackgroundSessionIdentifier = @"com.domain.backgroundsession";

@implementation VMSessionManager

+ (instancetype)sharedManagerNoMobile{
    
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initWithIdentifer:@"backgroundSessionNOMobile" cellULarAccess:NO];
    });
    return sharedMyManager;
}

+(instancetype)sharedManagerWithMobile{
    
    static id mobileManager = nil;
    static dispatch_once_t onceTokenAnother;
    dispatch_once(&onceTokenAnother, ^{
        mobileManager = [[self alloc]initWithIdentifer:@"backgroundSessionWITHMobile" cellULarAccess:YES];
    });
    return mobileManager;
}


-(instancetype)initWithIdentifer:(NSString *)identiferJoke cellULarAccess:(BOOL)cellUlarAccess{
    
    NSURLSessionConfiguration *configuration;
    NSString *identifer = [NSString stringWithFormat:@"%@.%@",[VMTools documentPath],identiferJoke];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifer];
    }else
        configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifer];
    
    configuration.allowsCellularAccess = cellUlarAccess;
    configuration.networkServiceType = NSURLNetworkServiceTypeVideo;
    configuration.timeoutIntervalForRequest = 60.0f;
    configuration.timeoutIntervalForResource = 60 * 60 * 24 * 7;
    configuration.HTTPMaximumConnectionsPerHost = 6;
    configuration.discretionary = NO;

    self = [super initWithSessionConfiguration:configuration];
    if (self) {
    }
    return self;
}

@end



typedef void(^VMDownloadMessageProcessBlock)(VMDownLoadTask *dic, VMDownloadTaskEvent event);

double delayInSeconds = 1.0;//消息循环

@interface VMDownLoadManager ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *allTasksDic;//所有的tasks
@property (nonatomic, strong) VMDataBaseManager *dataManager;//database的管理类
@property (nonatomic, strong) NSMutableDictionary *taskQueue;//用来存储可下载task的队列

@property (nonatomic, strong) VMSessionManager *sessionManager;
@property (nonatomic, strong) VMSessionManager *mobileManager;
/**
 *询问是否需要3g下载的时候记录的一个task
 */
@property (nonatomic, strong) VMDownLoadTask *mobileNetTask;
@property (nonatomic, strong) NSMutableArray *waitingAry;
@property (nonatomic, strong) dispatch_queue_t dispatch_message_queue;
@property (nonatomic, assign) NetworkStatus currentNetState;
/**
 *用来存储那些可以恢复的task，键为taskid，值为恢复过后的task
 */
@property (nonatomic, strong) NSMutableDictionary *resumDataTaskDic;
/**
 *用来存储那些只是被暂停的task，键为taskid，值为暂停的task
 */
@property (nonatomic, strong) NSLock *lock;

//用来维护是允许3g下载的task的地方。这里的task，在第一次接受到消息之后，就会被remove掉
@property (nonatomic, strong) NSMutableDictionary *aToBDictionary;

@end


@implementation VMDownLoadManager

+(VMDownLoadManager *)shareManager{
    static dispatch_once_t once;
    static VMDownLoadManager * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}

-(void)configureDownloadFinished{

}

-(void)configureBackgroundSessionFinished{
    
    typeof(self) __weak weakSelf = self;
    
    [self.sessionManager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession *session) {
        if (weakSelf.backgroundTransferCompletionHandler) {
            weakSelf.backgroundTransferCompletionHandler();
            weakSelf.backgroundTransferCompletionHandler = nil;
        }
    }];
}

-(id)init{
    
    if(self = [super init]){
        
        _allTasksDic = [@{}mutableCopy];
        _waitingAry = [@[]mutableCopy];
        _taskQueue = [@{}mutableCopy];//用来存储所有下载中的task
        _resumDataTaskDic = [@{}mutableCopy];//用来存储resumdata的目录和对应的名字
        _aToBDictionary = [@{}mutableCopy];
        _dataManager = [VMDataBaseManager shareDBManager];
        
        _dispatch_message_queue = dispatch_queue_create("vmdownload_manager_message_queue", DISPATCH_QUEUE_SERIAL);
        _maxDownloadNumber = 3;
        _canDownLoadINMobile = NO;
        _currentNetState = NETWORK_UNKNOW;
        
        _lock = [[NSLock alloc]init];
        
        /*初始化一下log系统
         */
        [VMLog initializeDefaultLogSystem];
        
        //获得所有的tasks，
        [self setupTasks];
        
        //初始化sessionmanager,以及相关的delegate
        self.sessionManager = [VMSessionManager sharedManagerNoMobile];
        self.mobileManager = [VMSessionManager  sharedManagerWithMobile];

        [self setupManagerDelegateWithManager:self.sessionManager];
        [self setupManagerDelegateWithManager:self.mobileManager];
        
        [self beginNetworkReachableCharge];
    }
    return self;
}

-(void)beginNetworkReachableCharge{
    
    __weak VMDownLoadManager *weakSelf = self;
    [self.sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                weakSelf.currentNetState = NETWORK_NONE;
                ;break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                weakSelf.currentNetState = NETWORK_WIFI;
                ;break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                weakSelf.currentNetState = NETWORK_MOBILE;
                ;break;
            case AFNetworkReachabilityStatusUnknown:
                weakSelf.currentNetState = NETWORK_UNKNOW;
                ;break;
            default:
                break;
        }
        if (weakSelf.taskQueue.count == 0) {
            
        }else
            [weakSelf sendMessage:nil byMessageEvent:NETWORK_STATUS_CHANGE];
    }];
}

#pragma mark-
#pragma mark------创建或查询VMDownloadTask的方法------

-(VMDownLoadTask *)downloadTaskBy:(NSDictionary *)dic{
    
    VMDownLoadTask *task = [self taskByInfo:dic];
    [self createTaskByDictionary:dic];
    return task;
}

-(VMDownLoadTask *)downloadTaskByID:(NSString *)taskID{
    if ([taskID isValid] == NO) {
        VMLogError(@"taskid不能使用，创建task失败");
        return nil;
    }
    //根据taskId获取当前的task，首先是检查当前task是否有resumdata
    if (self.resumDataTaskDic[taskID] != nil) {
        return (VMDownLoadTask *)self.resumDataTaskDic[taskID];
    }
    
    if (_allTasksDic[taskID] != nil) {
        return (VMDownLoadTask *)self.allTasksDic[taskID];
    }
    return nil;
}

-(VMDownLoadTask *)taskByInfo:(NSDictionary *)taskInfo{
    
    if (taskInfo == nil || [taskInfo[@"task_id"] isValid] == NO) {
        return nil;
    }
    if (_allTasksDic[taskInfo[@"task_id"]] != nil) {
        return (VMDownLoadTask *)_allTasksDic[@"task_id"];
    }else{
        VMDownLoadTask *task = [[VMDownLoadTask alloc]initWithInfo:taskInfo];
        [_allTasksDic setObject:task forKey:@"task_id"];
        return task;
    }
}

-(VMDownLoadTask *)taskByTaskIdentifer:(NSString *)identifer{
    if ([identifer isValid] == NO) {
        VMLogError(@"identifer is invalid");
        return nil;
    }
    NSArray *array = [self.allTasksDic allValues];
    for (VMDownLoadTask *task  in array) {
        if ([task.taskIdentifer isEqualToString:identifer]) {
            return task;
        }
    }
    return nil;
}

/**
 *其实这个方法很二的，真的，就是通过task的urlsting去比对，去找。找到了。你就牛逼，找不到。你就傻逼，但是有一个风险，就是如果下载过的，你会发现里面可能找到以前的，所以，这个地方其实是有个小坑的，不过这回下载我们会把下载成功的task全部删除掉。这样。整个世界都美好了。
 */
-(VMDownLoadTask *)taskByTask:(NSURLSessionTask *)task{
    NSString *taskUrl = task.currentRequest.URL.absoluteString;
    NSString *taskName = nil;
    /**这个地方。。真的好蛋疼啊。。无比的蛋疼啊。这个url，长的会很奇怪，有时候是?wsiphost=local结尾的，
     *有时候又没有，所以现在只能用各种塞选把视频的名字给塞选出来。
     */
    NSString *urlInfo = [NSString stringWithFormat:@"taskByTask url is %@",taskUrl];
    VMLogError(urlInfo);
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"/?"];
    NSArray *characterAry = [taskUrl componentsSeparatedByCharactersInSet:characterSet];
    NSMutableArray *taskNameAry = [@[]mutableCopy];
    [characterAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = (NSString *)obj;
        if ([str containSubstring:@"."] && [str componentsSeparatedByString:@"."].count == 2) {
            [taskNameAry addObject:str];
        }
    }];
    
    if (taskNameAry.count == 0) {
        //什么都不干
    }else if (taskNameAry.count == 1){
        taskName = taskNameAry.lastObject;
    }else{
        for (NSString *str in taskNameAry) {
            if ([str containSubstring:@"mp4"] || [str containSubstring:@"m3u8"] || [str containSubstring:@"flv"]) {
                taskName = str;
                break;
            }
        }
    }
    if ([taskName isValid] == NO) {
        NSString *str = [NSString stringWithFormat:@"%@查找task失败，这个URLStr根本就是错误的",taskName];
        VMLogInfo(str);
        return nil;
    }
    
    for (VMDownLoadTask *task in _allTasksDic.allValues) {
        if ([task.videoName isEqualToString:taskName]) {
            VMLogInfo(@"找到一摸一样的啦。好开心，好开心");
            return task;
        }
    }
    
    NSDictionary *taskDic = [[self.dataManager getInfoByKey:@"video_name" value:taskName fromTable:TASK_TABLE] lastObject];
    if (taskDic != nil && taskDic.count > 0) {
        VMDownLoadTask *task = [self taskByInfo:taskDic];
        VMLogInfo(@"在数据库里找到啦");
        return task;
    }
    VMLogError(@"什么鬼东西也没有找到。这肯定是不对的，然而，我有没有任何屌办法。so，你造的。啊哈哈哈。");
    return nil;
}

-(VMDownLoadTask *)preparedTask{
    VMDownLoadTask *downloadTask;
    //首先从waitingarray里面找
    if (self.waitingAry != nil && self.waitingAry.count > 0) {
        VMDownLoadTask *task = [self.waitingAry objectAtIndex:0];
        downloadTask = task;
        [self.waitingAry removeObject:task];
    }else{
        //什么都不干，但是未来不排除还有其它的情况发生
    }
    return downloadTask;
}

-(void)createTaskByDictionary:(NSDictionary *)dic{
    if ([self.dataManager hasTable:TASK_TABLE] == NO) {
        
        [self.dataManager createTable:TASK_TABLE withInfo:dic];
    }
    [self.dataManager replaceInfo:dic toTable:TASK_TABLE];
}

#pragma mark-
#pragma mark------一些外部动作------


-(void)startTask:(VMDownLoadTask *)task{
    //这里的逻辑是这样的，首先判断当前的task是否已经在队列里面了
    if ([self.taskQueue.allValues containsObject:task]) {
        [self resumTaskIfNeed:task];
    }else{
        if ([self canPushTask:task]) {
            [self pushStartTask:task];
        }else{
            [self pushTaskToWaiting:task];
        }
    }
}

#pragma mark-
#pragma mark------get actions------

-(VMDataBaseManager *)dataManager{

    if (_dataManager == nil) {
        _dataManager = [VMDataBaseManager shareDBManager];
    }
    return _dataManager;
}

-(NSArray *)activeTasksFromDB{
    
    return self.allTasksDic.allValues;
}

-(NSDictionary *)taskDictionaryInfoByID:(NSString *)taskId{
    
    NSDictionary *dic = [[self.dataManager getInfoByKey:@"task_id" value:taskId fromTable:TASK_TABLE] lastObject];
    return dic;
}

#pragma mark-
#pragma mark------创建获得tasks的一些方法------

-(void)setupTasks{
    
    VMLogInfo(@"准备查询所有的task信息");
    //拿出所有的task信息
    NSArray *array = [self.dataManager getInfoByKeysAndValues:nil fromTable:TASK_TABLE];
    if (array == nil || array.count == 0) {
        VMLogError(@"获取task失败，当前没有可用的task");
    }else{
        VMLogInfo(@"当前有可用的task");
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            NSDictionary *dic = (NSDictionary *)obj;
            VMDownLoadTask *task = [self taskByInfo:dic];
            if (task == nil) {
                VMLogError(@"恢复task失败");
            }else{
                
                [self checkResumDataForTask:task];
                if ([task.resumDataPath isValid] && task.resumData.length > 0) {
                    [self.resumDataTaskDic setObject:task forKey:task.taskId];
                }
                [self.allTasksDic setObject:task forKey:task.taskId];
            }
        }];
    }
}

-(void)sendMessage:(VMDownLoadTask *)task byMessageEvent:(VMDownloadTaskEvent)event{

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
        if (task) {
            task.modify = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        }
        
        VMDownloadMessageProcessBlock block;
        switch (event) {
            case TASK_VERIFY_SUCCESS:{
                NSString *taskInfo = [NSString stringWithFormat:@"%@开始验证",task.taskId];
                VMLogInfo(taskInfo);
                //更新当前的task状态
                block = ^(VMDownLoadTask *task,VMDownloadTaskEvent event){
                    [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"state":@"510"} referKey:@"task_id" referValue:task.taskId];
                };
                task.taskStateInfo = @"验证成功";
                task.state = @"510";
                [self deleteResumDataWithTask:task];
                [self.allTasksDic removeObjectForKey:task.taskId];
                NSString *debugInfo = [NSString stringWithFormat:@"%p verify success",task];
                VMLogDebug(debugInfo);
            }break;
                
            case TASK_VERIFY_FAILURE:{
                //更新当前的task状态
                block = ^(VMDownLoadTask *task,VMDownloadTaskEvent event){
                    
                    [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"state":@"520"} referKey:@"task_id" referValue:task.taskId];
                };
                task.taskStateInfo = @"验证失败";
                task.state = @"520";
                [self deleteResumDataWithTask:task];
                [self.allTasksDic removeObjectForKey:task.taskId];
                NSString *debugInfo = [NSString stringWithFormat:@"%p verify success",task];
                VMLogDebug(debugInfo);
            }break;
                
            case TASK_START:{
                //将当task压入队列
                //启动任务会自己去监测个种任务的业务状态，所以，这里只是将当前队列压入队列
                [self pushStartTask:task];
                task.taskStateInfo = @"下载开始";
                if (![task.state isValid]) {
                    task.state = @"200";
                }
                NSString *debugInfo = [NSString stringWithFormat:@"%p 下载开始咯",task];
                VMLogDebug(debugInfo);
                
            }break;
                
            case TASK_PAUTSE:{
                //首先将当前的任务暂停，所有的暂停任务全部通过cancelWithResumData方法来实现暂停
                //将当前任务暂停，所有的下载任务全部留在当前的下载队列里。
                //除了主动的删除任务，不然，所有的任务都是不会pop出当前队列的。
                if (self.aToBDictionary[task.taskId] != nil) {
                    [self.aToBDictionary removeObjectForKey:task.taskId];
                    break;
                }
                [self suspendTask:task];
                NSString *debugInfo = [NSString stringWithFormat:@"%p 下载暂停咯",task];
                VMLogDebug(debugInfo);
                task.taskStateInfo = @"任务暂停";
                task.state = @"410";
            }break;
                
            case TASK_WAITING:{
                //当前任务进入waiting队列
                [self pushTaskToWaiting:task];
                task.taskStateInfo = @"等待中";
                task.state = @"220";
                
                NSString *debugInfo = [NSString stringWithFormat:@"%p 等待中",task];
                VMLogDebug(debugInfo);
            }break;
                
            case TASK_THREAD_POOL_AVAILABLE:{
                VMLogDebug(@"线程池可用了");
                //获取最新的一个可用任务，如果可以压入队列，则压入队列
                VMDownLoadTask *task = [self preparedTask];
                if ([self canPushTask:task]) {
                    //pushtostart
                    [self pushStartTask:task];
                    NSString *debugInfo = [NSString stringWithFormat:@"%p 入列成功",task];
                    VMLogDebug(debugInfo);
                }else{
                    NSString *debugInfo = [NSString stringWithFormat:@"%p 入列失败",task];
                    VMLogDebug(debugInfo);
                    //returnback to wait
                    [self pushTaskToWaiting:task];
                }
            }break;
                
            case TASK_DELETE:{
                block = ^(VMDownLoadTask *task, VMDownloadTaskEvent event){
                    BOOL success = [self.dataManager deleteTable:TASK_TABLE byKey:@"task_id" value:task.taskId];
                    if (!success) {
                        VMLogInfo(@"task 删除成功");
                    }else{
                        VMLogInfo(@"task 删除失败");
                    }
                };
                //移出队列
                [self popTask:task];
                [self sendMessage:nil byMessageEvent:TASK_THREAD_POOL_AVAILABLE];
                //从alltaskdic中删除
                [self.resumDataTaskDic removeObjectForKey:task.taskId];
                [self.allTasksDic removeObjectForKey:task.taskId];
                NSString *debugInfo = [NSString stringWithFormat:@"%@ 任务删除",task.taskId];
                VMLogDebug(debugInfo);
            }break;
                
            case TASK_FAILURE:{
                
                //从下载队列移除
                [self popTask:task];
                [self sendMessage:task byMessageEvent:TASK_THREAD_POOL_AVAILABLE];
                
                block = ^(VMDownLoadTask *task, VMDownloadTaskEvent event){
                    
                    [self.dataManager updateTable:TASK_TABLE
                                   withDictionary:@{@"state":@"520"}
                                         referKey:@"task_id"
                                       referValue:task.taskId];
                };
                
                task.taskStateInfo = @"任务下载失败";
                task.state = @"520";
                task.error = @"task download failure";
                [self deleteResumDataWithTask:task];
                [self.resumDataTaskDic removeObjectForKey:task.taskId];
                [self.allTasksDic removeObjectForKey:task.taskId];
                NSString *debugInfo = [NSString stringWithFormat:@"%p 任务失败",task];
                VMLogDebug(debugInfo);
                
            }break;
                
            case TASK_IOERROR:{
                //从下载队列移除
                [self popTask:task];
                [self sendMessage:task byMessageEvent:TASK_THREAD_POOL_AVAILABLE];
                
                block = ^(VMDownLoadTask *task, VMDownloadTaskEvent event){
                    [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"state":@"420"} referKey:@"task_id" referValue:task.taskId];
                };
                task.taskStateInfo = @"任务io失败";
                task.state = @"420";
                task.error = @"task download io error";
                NSString *debugInfo = [NSString stringWithFormat:@"%p 任务IO失败",task];
                VMLogDebug(debugInfo);
            }break;
                
            case TASK_FINIS:{
                task.taskStateInfo = @"任务完成";
                task.state = @"500";
                NSString *debugInfo = [NSString stringWithFormat:@"%p 下载成功，准备验证",task];
                VMLogDebug(debugInfo);
                
     
                //从下载队列移除
                [self popTask:task];
                [self sendMessage:task byMessageEvent:TASK_THREAD_POOL_AVAILABLE];
                //进入验证
                NSString *filename = task.videoName;
                NSString *path = [[VMTools documentPath] stringByAppendingPathComponent:filename];
                VMLogError(path);
                
                NSString *filePath = path;
                NSString *md5 = task.md5;
                //如果没有md5，则直接放行
                if ([md5 isValid] == NO) {
                    [self sendMessage:task byMessageEvent:TASK_VERIFY_SUCCESS];
                }else{
                    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
                        NSString *md5Value = [VMTools md5File:filePath];
                        task.appMd5 = [md5Value lowercaseString];
                        if ([[md5Value lowercaseString] isEqualToString:md5]) {
                            [self sendMessage:task byMessageEvent:TASK_VERIFY_SUCCESS];
                        }else
                            [self sendMessage:task byMessageEvent:TASK_VERIFY_FAILURE];
                    }else
                        [self sendMessage:task byMessageEvent:TASK_VERIFY_FAILURE];
                }
            }break;
                
                
            case TASK_PROGRESS:{
                /*
                 每一个下载中的
                 */
  
                if (task.downloadTask.state == NSURLSessionTaskStateCanceling || task.downloadTask.state == NSURLSessionTaskStateSuspended) {
                    return ;
                }
                block = ^(VMDownLoadTask *task, VMDownloadTaskEvent event){
                    NSDictionary *dic = @{
                                          @"state":@"212",
                                          @"length":task.length,
                                          @"progress":task.progress ? task.progress : @"1",
                                          @"modify":task.modify
                                          };
                    [self.dataManager updateTable:TASK_TABLE withDictionary:dic referKey:@"task_id" referValue:task.taskId];
                };
                task.state = @"212";
            }break;
                
                
            case TASK_RETRY:{
                task.state = @"211";
                task.taskStateInfo = @"task retrying";
                task.retryTimes++;
                if (task.retryTimes > 3) {
                    [self sendMessage:task byMessageEvent:TASK_IOERROR];
                    [self popTask:task];
                    [self sendMessage:nil byMessageEvent:TASK_THREAD_POOL_AVAILABLE];
                    [self deleteResumDataWithTask:task];
                    task.retryTimes = 0;
                }else{
                    
                    NSFileManager *manager = [NSFileManager defaultManager];
                    BOOL fileExist = [manager fileExistsAtPath:task.resumDataPath];
                    if (fileExist) {
                        NSLog(@"resumdata还是存在的");
                        if ([self.resumDataTaskDic.allValues containsObject:task] == NO) {
                            [self.resumDataTaskDic setObject:task forKey:task.taskId];
                        }
                        
                        //                        [self beginDownloadTask:task withResumData:task.resumData];
                    }else{
                        NSLog(@"resumdata根本不存在啊");
                        if ([self.allTasksDic.allValues containsObject:task] == NO) {
                            [self.allTasksDic setObject:task forKey:task.taskId];
                        }
                        task.downloadTask = nil;
                    }
                    [self startTask:task];
                }
            }break;
                
                
            case NETWORK_STATUS_CHANGE:{
                for (int i = 0; i < self.taskQueue.count; i++) {
                    VMDownLoadTask *task = self.taskQueue.allValues[i];
                    task.networkState = self.currentNetState;
                }
                
                switch (self.currentNetState) {
                    case NETWORK_UNKNOW:
                    case NETWORK_NONE:
                    case NETWORK_MOBILE:{
                        
                        NSArray *array = self.taskQueue.allKeys;
                        
                        if (self.canDownLoadINMobile == NO) {
                            for (int i = 0; i < array.count; i++) {
                                VMDownLoadTask *task = self.taskQueue[array[i]];
                                if (task.canMobileDown == NO) {
//                                    [self suspendTask:task];
                                }
                            }
                        }else{
                            for (int i = 0; i < array.count; i++) {
                                VMDownLoadTask *task = self.taskQueue[array[i]];
                                if (task.canMobileDown == NO) {
//                                    [self suspendTask:task];
                                }
                            }
                        }
                    };break;
                        
                    case NETWORK_WIFI:{
                        NSArray *array = self.taskQueue.allKeys;
                        for (int i = 0; i < array.count; i++) {
                            VMDownLoadTask *task = self.taskQueue[array[i]];
                            [self resumTaskIfNeed:task];
                        }
                    };break;

                    default:
                        break;
                }
                
            }break;
                
            default:
                break;
        }
        if (block) {
          
            VMDownLoadTask *newTask = [task taskCopy];
            dispatch_async(_dispatch_message_queue, ^{
                
                    block(newTask,event);
                    
                   
            });
        }
    }
    });
}

#pragma mark-
#pragma mark------download actions------


-(BOOL)canPushTask:(VMDownLoadTask *)task{
    if (task == nil || [task.mainURL isValid] == NO)  {
        VMLogError(@"任务不能为空");
        return NO;
    }
    
    //首先检查当前的队列是不是空闲
    if (self.taskQueue.allKeys.count < self.maxDownloadNumber) {
        /*检查当前的网络情况是不是允许
          首先检查大开关，在检查小开关
         */
        switch (self.currentNetState) {
            case NETWORK_MOBILE:{
                if (task.canPushInQueue) {
                    return YES;
                }else{
                    if (task.canMobileDown) {
                        return YES;
                    }else{
                        return NO;
                    }
                }
            }break;
            case NETWORK_WIFI:return YES;break;
            default:
                return YES;
                break;
        }
        return NO;
    }else
        return NO;
}

-(void)popTask:(VMDownLoadTask *)task{
    NSArray *array = self.taskQueue.allValues;
    if ([array containsObject:task]) {
        if (task.taskId != nil) {
            VMLogInfo(@"pop task success");
            [self.taskQueue removeObjectForKey:task.taskId];
        }else{
            VMLogError(@"pop task unexcepted!");
        }
    }else{
        VMLogError(@"pop task error");
    }
}

-(void)pushStartTask:(VMDownLoadTask *)task{
    
    if (task.taskId == nil){
        VMLogError(@"task.taskId is invalid , so return");
        return;
    }
    //push it to self.taskQueue
    [self.taskQueue setObject:task forKey:task.taskId];
    //tell the task it has been pushed in to queue
    [task taskPushedIntoQueue];
    //if the waitingqueue contains the task , remove it
    if ([self.waitingAry containsObject:task]) {
        [self.waitingAry removeObject:task];
    }
    //tell the task ,it didbegin
    task.didBegin = YES;
    
    //这个地方需要判断task是否有resumdata，通过两个方式来判断，一个是是否被resumdatataskdic包含了。
    //另一个就是。看能不能手动查询到他的resumeda;
    
    if ([self.resumDataTaskDic.allValues containsObject:task] || [self checkResumDataForTask:task]) {
        //check if task can be download in 3g
        if (task.canMobileDown) {
            [self beginDownloadTask:task withResumData:task.resumData withSessionManager:self.mobileManager];
        }else{
            [self beginDownloadTask:task withResumData:task.resumData withSessionManager:self.sessionManager];
        }
    }else{
        if (task.canMobileDown) {
            [self beginDownloadTask:task withSessionManager:self.mobileManager];
        }else
            [self beginDownloadTask:task withSessionManager:self.sessionManager];
    }
}

#pragma mark-
#pragma mark------download actions------


-(void)setupManagerDelegateWithManager:(VMSessionManager *)manager{
    
    __weak typeof(self)weakSelf = self;
    
    [manager setDownloadTaskDidResumeBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t fileOffset, int64_t expectedTotalBytes) {
        VMLogInfo(@"download resumBlock did called %lld , %lld",fileOffset,expectedTotalBytes);
    }];
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
         @autoreleasepool {
//        NSLog(@"download task thread%@",[NSThread currentThread]);
        __strong typeof(self)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableSet *set = [NSMutableSet set];
            [set addObjectsFromArray:strongSelf.taskQueue.allValues];
            [set addObjectsFromArray:strongSelf.allTasksDic.allValues];
            
            NSArray *array = set.allObjects;
            for (VMDownLoadTask *task in array) {
                @autoreleasepool {
                    if (task.downloadTask == downloadTask) {
                        task.length = [NSString stringWithFormat:@"%lld",totalBytesExpectedToWrite];
                        
//                        [self sendMessage:task byMessageEvent:TASK_PwROGRESS];
                        
                        [task updateProgressWithbytesWritten:bytesWritten
                        totalWritten:totalBytesWritten
                        totalExpected:totalBytesExpectedToWrite];
                        break;
                    }

                }
            }
           
            [set removeAllObjects];
        });
              }
    }];
    
    [manager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
        __strong typeof(self)strongSelf = weakSelf;
        if (strongSelf.backgroundTransferCompletionHandler) {
            strongSelf.backgroundTransferCompletionHandler();
            strongSelf.backgroundTransferCompletionHandler = nil;
        }
    }];
    
    //下载完成之后，将文件移到相关的目录
    [manager setDownloadTaskDidFinishDownloadingBlock:^NSURL *(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location) {
        if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)downloadTask.response statusCode];
            if (statusCode != 200) {
                // handle error here, e.g.
                NSLog(@"%@ failed (statusCode = %ld)", [downloadTask.originalRequest.URL lastPathComponent], statusCode);
                return nil;
            }
        }
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[downloadTask.response suggestedFilename]];
    }];
    
    /**
     *这里是断点下载的关键所在，每次没有下载完成的任务，再次启动都会进入这个方法，这个方法里，需要把resumdata保存起来，
     *通过NSURLSessionTask恢复VMDownloadTask
     */
    [manager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @autoreleasepool {
       
                VMDownLoadTask *downloadtask = [weakSelf taskByTask:task];
                if (downloadtask == nil) {
                    NSString *taskInfo = [NSString stringWithFormat:@"%@没有找到相关的vmtask",task];
                    VMLogError(taskInfo);
                }
                if (error) {
                    NSLog(@"进入了error %@",error);
                    //这个地方是这样的，当用户调用cancel方法的时候，无论是cancel还是cancel with resumdate都会走这个，且errroCode 都等于－999，但是当调用cancel的时候，会有resumdata这个字段，直接调用cancel的时候是没有的。
                    
                    NSData *resumData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                    if (resumData != nil && resumData.length > 0) {
                        NSString *taskIdentifer = [NSString stringWithFormat:@"%ld",task.taskIdentifier];
                        VMDownLoadTask *newTask = [weakSelf taskByTaskIdentifer:taskIdentifer];
                        if (newTask != downloadtask) {
                            NSString *str = [NSString stringWithFormat:@"%@ %@",newTask.taskId, downloadtask.taskId];
                            VMLogError(str);
                        }
                        
                        weakSelf.allTasksDic[downloadtask.taskId] = downloadtask;
                        [weakSelf saveResumData:resumData ofTask:downloadtask];
                        [weakSelf.resumDataTaskDic setObject:downloadtask forKey:downloadtask.taskId];
                        NSString *taskInfo = [NSString stringWithFormat:@"task的信息是%@",task];
                        VMLogError(taskInfo);
                    }
                }
                NSInteger haha = task.state;
                NSLog(@"===>>>> %ld",(long)haha);
                    }
            });
    }];

    [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        return NSURLSessionAuthChallengeUseCredential ;
    }];
    
}

-(void)beginDownloadTask:(VMDownLoadTask *)task withSessionManager:(VMSessionManager *)sessionManager{

    NSString *url = task.mainURL;
    if ([url isValid] == NO) {
        NSString *errorInfo = [NSString stringWithFormat:@"%p这个task 根本没有url啊，亲",task];
        VMLogError(errorInfo);
        [self sendMessage:task byMessageEvent:TASK_FAILURE];
        return;
    }
    
    if (task.downloadTask) {
        switch (task.downloadTask.state) {
            case NSURLSessionTaskStateCanceling:{
                NSString *taskInfo = [NSString stringWithFormat:@"%@ task in canceling ",task.taskId];
                VMLogInfo(taskInfo);
            };break;
            case NSURLSessionTaskStateCompleted:{
                //we can get task's property error to check out wheather the task was completed success.
                NSError *error = task.downloadTask.error;
                if (error == nil) {
                    
                }else{
                    
                }
            };break;
            case NSURLSessionTaskStateRunning:return;break;
            case NSURLSessionTaskStateSuspended:{
                if (sessionManager == self.sessionManager) {
                    if (self.currentNetState == NETWORK_WIFI || (self.currentNetState == NETWORK_MOBILE && task.canMobileDown == YES)) {
                        [task.downloadTask resume];
                    }
                    return;
                }else if(sessionManager == self.mobileManager){
                    [task.downloadTask resume];
                    return;
                }
                
            };break;
            default:
                break;
        }
    }
    __weak typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (request == nil) {
        VMLogError(@"requet 初始化失败了！！！");
        [self sendMessage:task byMessageEvent:TASK_FAILURE];
        return;
    }

    NSURLSessionDownloadTask *downloadTask;
    downloadTask = [sessionManager downloadTaskWithRequest:request progress:nil
                    destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                        
                  } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                      
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(self)strongSelf = weakSelf;
                        NSLog(@"这个是begin的success %@",error);
                        if (error == nil) {
                            VMLogInfo(@"下载成功咯，哦来来，哦啦啦");
                            task.taskStateInfo = @"下载成功";
                            [strongSelf sendMessage:task byMessageEvent:TASK_FINIS];
                            
                        }else{
                            //说明下载出错了，这个时候，需要进入retry机制，需要重新创建一个task，如果有resumdata则创建有resumedata的task，否则，则重新起一个task
                            //如果用户调用了cancel方法也会调用这个回调，调用cancel的时候，resumdata为nil。that is the point
                         
                            
                            //这个地方是这样的，当用户调用cancel方法的时候，无论是cancel还是cancel with resumdate都会走这个，且errroCode 都等于－999，但是当调用cancel的时候，会有resumdata这个字段，直接调用cancel的时候是没有的。
                            
                            NSData *resumData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                            NSInteger errorCode = error.code;
                            if (errorCode == NSURLErrorCancelled) {
                                //用户主动cancel的，通过判断resumdata以及isCancelledForResumeData来判断是用户直接调用的cancel，
                                if (resumData == nil && task.isCancelledForResumeData == YES) {
                                    //说明是用户主动cancel的，并且调用的是[task cancel]方法
                                    [strongSelf sendMessage:task byMessageEvent:TASK_DELETE];
                                    return ;
                                }else{
                                    //如果有resumdata，则，需要将resumedata保存起来，用来恢复下载用
                                    [strongSelf.allTasksDic setObject:task forKey:task.taskId];
                                    [strongSelf saveResumData:resumData ofTask:task];
                                    [strongSelf.resumDataTaskDic setObject:task forKey:task.taskId];
                                    [strongSelf sendMessage:task byMessageEvent:TASK_PAUTSE];
                                    return;
                                }
                            }else if(errorCode == 2){
                                    [strongSelf deleteResumDataWithTask:task];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [strongSelf sendMessage:task byMessageEvent:TASK_RETRY];
                                });
                                
                            }else{
                                    if (resumData) {
                                        [strongSelf.allTasksDic setObject:task forKey:task.taskId];
                                        [strongSelf saveResumData:resumData ofTask:task];
                                        [strongSelf.resumDataTaskDic setObject:task forKey:task.taskId];
                                    }
                                    [strongSelf sendMessage:task byMessageEvent:TASK_RETRY];
                                }
                        }
                    });
              
                }];
    
    /**如果要开始下载，1，需要是在wifi的状态下，
     *如果是3g状况，需要判断下这个task是否能够在3g下下载
     */
    task.downloadTask = downloadTask;
    task.taskIdentifer = [NSString stringWithFormat:@"%ld",downloadTask.taskIdentifier];
    [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"task_identifer":[NSString stringWithFormat:@"%ld",downloadTask.taskIdentifier]} referKey:@"task_id" referValue:task.taskId];
    if (sessionManager == self.sessionManager) {
        if (self.currentNetState == NETWORK_WIFI || (self.currentNetState == NETWORK_MOBILE && task.canMobileDown == YES)) {
            [task.downloadTask resume];
        }
    }else if (sessionManager == self.mobileManager){
        [task.downloadTask resume];
    }

}

-(void)beginDownloadTask:(VMDownLoadTask *)task withResumData:(NSData *)data withSessionManager:(VMSessionManager *)sessionManager{
    if (data == nil || data.length == 0) {
        VMLogError(@"根本没有断点下载啊。我操");
        [self beginDownloadTask:task withSessionManager:sessionManager];
        return;
    }
    
    if (task.downloadTask) {
        switch (task.downloadTask.state) {
            case NSURLSessionTaskStateCanceling:{
//                [VMTools alertMessage:@"正在取消中"];
                NSString *taskInfo = [NSString stringWithFormat:@"%@ beginDownload进入canceling状态",task.taskId];
                VMLogInfo(taskInfo);
                [task.downloadTask suspend];
            }break;
            case NSURLSessionTaskStateCompleted:{
//                [VMTools alertMessage:@"已经搞定了"];
                return;
            }break;
            case NSURLSessionTaskStateRunning:{
//                [VMTools alertMessage:@"居然在运行"];
                return;
            }break;
            case NSURLSessionTaskStateSuspended:{
//                [VMTools alertMessage:@"还没有启动呢"];
                if (sessionManager == self.sessionManager) {
                    if (self.currentNetState == NETWORK_WIFI || (self.currentNetState == NETWORK_MOBILE && task.canMobileDown == YES)) {
                        [task.downloadTask resume];
                    }
                    return;
                }else{
                
                    [task.downloadTask resume];
                    return;
                }
    
            }
                break;
            default:
                break;
        }
    }
    
    __weak typeof(self)weakSelf = self;
    NSURLSessionDownloadTask *downloadtask = [sessionManager downloadTaskWithResumeData:data progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self)strongSelf = weakSelf;
            NSLog(@"begin with resumdata de success%@",error);
            
            if (error == nil) {
                VMLogInfo(@"下载成功咯，哦来来，哦啦啦");
                task.taskStateInfo = @"下载成功";
                [strongSelf sendMessage:task byMessageEvent:TASK_FINIS];
                
            }else{
                //说明下载出错了，这个时候，需要进入retry机制，需要重新创建一个task，如果有resumdata则创建有resumedata的task，否则，则重新起一个task
                //如果用户调用了cancel方法也会调用这个回调，调用cancel的时候，resumdata为nil。that is the point
                
                
                //这个地方是这样的，当用户调用cancel方法的时候，无论是cancel还是cancel with resumdate都会走这个，且errroCode 都等于－999，但是当调用cancel的时候，会有resumdata这个字段，直接调用cancel的时候是没有的。
                
                NSData *resumData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                NSInteger errorCode = error.code;
                if (errorCode == NSURLErrorCancelled) {
                    //用户主动cancel的，通过判断resumdata来判断是用户直接调用的cancel
                    if (resumData == nil && task.isCancelledForDelete == YES) {
                        //说明是用户主动cancel的，并且调用的是[task cancel]方法
                        [strongSelf sendMessage:task byMessageEvent:TASK_DELETE];
                        return ;
                    }else{
                        //如果有resumdata，则，需要将resumedata保存起来，用来恢复下载用
                        [strongSelf.allTasksDic setObject:task forKey:task.taskId];
                        [strongSelf saveResumData:resumData ofTask:task];
                        [strongSelf.resumDataTaskDic setObject:task forKey:task.taskId];
                        [strongSelf sendMessage:task byMessageEvent:TASK_PAUTSE];
                        return;
                    }
                }else if(errorCode == 2){
                   
                    [strongSelf deleteResumDataWithTask:task];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf sendMessage:task byMessageEvent:TASK_RETRY];
                    });
                }else{
                    if (resumData) {
                        [strongSelf.allTasksDic setObject:task forKey:task.taskId];
                        [strongSelf saveResumData:resumData ofTask:task];
                        [strongSelf.resumDataTaskDic setObject:task forKey:task.taskId];
                    }
                    [strongSelf sendMessage:task byMessageEvent:TASK_RETRY];
                }
            }
        });

    }];
    if (task.downloadTask) {
        [task.downloadTask cancel];
    }
    
    task.downloadTask = downloadtask;
    task.taskIdentifer = [NSString stringWithFormat:@"%ld",downloadtask.taskIdentifier];
    [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"task_identifer":[NSString stringWithFormat:@"%ld",downloadtask.taskIdentifier]} referKey:@"task_id" referValue:task.taskId];
    
    if (sessionManager == self.sessionManager) {
        if (self.currentNetState == NETWORK_WIFI || (self.currentNetState == NETWORK_MOBILE && task.canMobileDown == YES)) {
            [task.downloadTask resume];
        }
    }else if (sessionManager == self.mobileManager){
        [task.downloadTask resume];
    }
}

//对外开放的接口
-(void)pauseTask:(VMDownLoadTask *)task{

    [self sendMessage:task byMessageEvent:TASK_PAUTSE];
}

-(void)continueTaskMobileDownload:(VMDownLoadTask *)task{
    if (self.currentNetState == NETWORK_MOBILE) {
        if ([self.taskQueue.allValues containsObject:task] == NO && [self.waitingAry containsObject:task]) {
            self.mobileNetTask = task;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc]initWithTitle:nil message:@"确定使用流量获取影片?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
            });
        }
            
        if ([self.taskQueue.allValues containsObject:task]) {
            if (task.canMobileDown) {
                [self resumTaskIfNeed:task];
            }else{
                self.mobileNetTask = task;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc]initWithTitle:nil message:@"确定使用流量获取影片?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                });
            }
        }
    }else{
        [self resumTaskIfNeed:task];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex){
        self.mobileNetTask.canMobileDown = YES;
        self.mobileNetTask.mobile_down = @"1";
        BOOL updateResult = [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"mobile_down":@"1"} referKey:@"task_id" referValue:self.mobileNetTask.taskId];
        if (updateResult) {
            NSLog(@"wocao ,chenggongle !!!");
        }
        self.mobileNetTask.isCancelledForResumeData = YES;
        [self.aToBDictionary setObject:self.mobileNetTask forKey:self.mobileNetTask.taskId];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mobileNetTask.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveResumData:resumeData ofTask:self.mobileNetTask];
                    [self pushStartTask:self.mobileNetTask];
                    if (self.mobileNetTask.mobileDownloadBlock) {
                        self.mobileNetTask.mobileDownloadBlock(self.mobileNetTask, YES);
                    }
                    self.mobileNetTask = nil;
                });
        
            }];
    
        });
    }
}



//对内进行处理的逻辑
-(void)suspendTask:(VMDownLoadTask *)task{
    
    NSLog(@"suspend task is %@ and %@",self.sessionManager.tasks, task.downloadTask);

    NSURLSessionDownloadTask *downloadTask = task.downloadTask;
    if (downloadTask == nil) {
        
        VMLogError(@"downloadtask为空！！！！！！");
        return;
    }
    if (task == nil) {
        VMLogError(@"task为空！！！！！");
        return;
    }
    //这个是发送暂停信息，如果当前的task是正在运行的状态，则需要发送cancel消息，不然的话，应该都不用去管
    if (self.currentNetState == NETWORK_MOBILE) {
        NSLog(@"进入了3g网");
        if (task && task.canMobileDown == NO) {
            switch (downloadTask.state) {
                case NSURLSessionTaskStateSuspended:NSLog(@"3g %@ %@ suspended",task,downloadTask);;break;
                case NSURLSessionTaskStateCanceling:{
                    NSLog(@"3g %@ %@ canceling",task,downloadTask);
//                       [VMTools alertMessage:@"cancling 尼玛"];
                    NSString *taskInfo = [NSString stringWithFormat:@"%@进入canceling状态",task.taskId];
                    VMLogInfo(taskInfo);
                }
                    break;
                case NSURLSessionTaskStateCompleted:NSLog(@"3g %@ %@ completed",task,downloadTask);;break;
                case NSURLSessionTaskStateRunning:{
                    NSLog(@"3g %@ %@ running",task,downloadTask);
                    task.isCancelledForResumeData = YES;
                    [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"3g %@ %@ resumdatazhong ",task,downloadTask);
                            if (resumeData == nil || resumeData.length == 0) {
                                [task.downloadTask suspend];
                            }else
                                [self saveResumData:resumeData ofTask:task];
                        });
                    }];
                
                }break;
                default:
                    break;
            }
        }else{
            switch (downloadTask.state) {
                case NSURLSessionTaskStateSuspended:;break;
                case NSURLSessionTaskStateCanceling:{
//                       [VMTools alertMessage:@"cancleing 你妹"];
                }break;
                case NSURLSessionTaskStateCompleted:;break;
                case NSURLSessionTaskStateRunning:{
                    task.isCancelledForResumeData = YES;
                    [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (resumeData == nil || resumeData.length == 0) {
                                [task.downloadTask suspend];
                            }else
                                [self saveResumData:resumeData ofTask:task];
                        });
                            
                                //                            [weakSelf saveResumData:resumeData ofTask:weakTask];
                    }];
                }break;
                default:
                    break;
            }
        }
    }else{
        NSLog(@"进入了非3g网状态");
        switch (downloadTask.state) {
            case NSURLSessionTaskStateSuspended:NSLog(@"%@ %@ suspended",task,downloadTask);break;
            case NSURLSessionTaskStateCanceling:{
                NSString *taskInfo = [NSString stringWithFormat:@"%@进入canceling状态",task.taskId];
                VMLogInfo(taskInfo);
                [downloadTask suspend];
            }break;
            case NSURLSessionTaskStateCompleted:NSLog(@"%@ %@ completed",task,downloadTask);;break;
            case NSURLSessionTaskStateRunning:{
                NSLog(@"%@ %@ running",task,downloadTask);
                task.isCancelledForResumeData = YES;
                [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (resumeData == nil || resumeData.length == 0) {
                                [task.downloadTask suspend];
                            }else
                                [self saveResumData:resumeData ofTask:task];
                        });
                        
                    }];
     
                }break;
                default:
                    break;
            }
        }
}


/**这个地方的逻辑是这样的，
 如果当前的task，正在下载，则没有必要进行任何的操作
 如果当前的task，正在canceling，则需要等待其cancel结束，并且，重新启动下载
 如果当前的task是suspened，则直接启动resum
 如果当前的task是
 */
-(void)resumTaskIfNeed:(VMDownLoadTask *)task{
    if (task == nil) {
        VMLogError(@"resumTaskIfNeedError, task == nil");
        return;
    }
    NSURLSessionDownloadTask *downloadTask = task.downloadTask;
    if (downloadTask == nil) {
        //要根据task是否允许3g下载来确定他到底放进哪个队列里
        if (task.canMobileDown) {
            [self beginDownloadTask:task withResumData:task.resumData withSessionManager:self.mobileManager];
        }else
            [self beginDownloadTask:task withResumData:task.resumData withSessionManager:self.sessionManager];
    }else{
        switch (downloadTask.state) {
            case NSURLSessionTaskStateRunning:;break;
            case NSURLSessionTaskStateSuspended:[downloadTask resume];break;
            case NSURLSessionTaskStateCompleted:{
                //task已经完成了，这种完成不包括被cancel掉的，而且，如果是在这种状况下，task，不会在接收到任何的回调信息,
                [self beginDownloadTask:task withResumData:task.resumData withSessionManager:self.mobileManager];
                        
            };break;
            case NSURLSessionTaskStateCanceling:{
                //task收到了cancel的消息，也许收到了回调，也许还没有。
                //因为是正在cancel，所以，这个地方应该是又一个延时操作。告诉task，一会需要进行恢复启动
                NSString *taskInfo = [NSString stringWithFormat:@"%@进入canceling状态",task.taskId];
                VMLogInfo(taskInfo);
            };break;
            default:
            break;
            }
    }
}

-(void)deleteTask:(VMDownLoadTask *)task{
    if (task == nil) {
        return;
    }
    [task.downloadTask cancel];
    task.isCancelledForDelete = YES;
    //cancel里有发送task_delete的消息
    [self sendMessage:task byMessageEvent:TASK_DELETE];
}

#pragma mark-
#pragma mark------waiting------

-(void)pushTaskToWaiting:(VMDownLoadTask *)task{

    if (task == nil) {
        VMLogError(@"task为nil不能进入等待队列");
        return;
    }
    if ([self.waitingAry containsObject:task]) {
        return;
    }
    [self.waitingAry addObject:task];
    [self sendMessage:task byMessageEvent:TASK_WAITING];
}

-(void)pushTaskInfoToWaiting:(NSDictionary *)dic{

    if (dic == nil || dic.count == 0) {
        VMLogError(@"task的信息为空，不能进入等待队列");
        return;
    }
    [self.waitingAry addObject:[self taskByInfo:dic]];
}

#pragma mark-
#pragma mark------resum data actions------

-(void)saveResumData:(NSData *)resumData ofTask:(VMDownLoadTask *)task{

    if (resumData.length == 0) {
        NSLog(@"%@ 没有resumdata",task);
        //if resumeData.length == 0, then we delete the task's resumData if there had
        [self deleteResumDataWithTask:task];
        return;
    }
    NSString *documentsResumData = [[VMTools documentPath] stringByAppendingPathComponent:@"Magic_box_resume"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL fileExits = [fileManager fileExistsAtPath:documentsResumData isDirectory:&isDirectory];
    if (fileExits) {
        //if resumdata exits, do nothing ,but go on
    }else{
        //else ,check the directiories, create one if there were no directiories.
        NSError *error;
        BOOL createResult = [fileManager createDirectoryAtPath:documentsResumData withIntermediateDirectories:YES attributes:nil error:&error];
        if (createResult) {
            VMLogDebug(@"创建resumdata目录成功");
        }else{
            NSString *errorReason = [NSString stringWithFormat:@"创建resumdata目录失败，原因是%@",error.localizedDescription];
            VMLogError(errorReason);
            return;
        }
    }
    NSString *urlName = task.videoName;
    NSString *finalPath = [documentsResumData stringByAppendingPathComponent:urlName];
    VMLogError(finalPath);
    NSData *data = [NSData dataWithContentsOfFile:finalPath];
    if (data != nil && [data isEqualToData:resumData]) {
        //if there's the sameData we delete it
        VMLogError(@"已经存在一摸一样的啦的啦，那么，删掉他吧！");
        [fileManager removeItemAtPath:finalPath error:nil];
    }
    //write the resumData to the director path
    [resumData writeToFile:finalPath atomically:YES];
    task.resumDataPath = finalPath;
    task.resumData = resumData;
    //if we save the resumdata， so, the NSURLSessionDownloadTask should be nil , and taskIdentifer should be @"". update the dataBase
    task.downloadTask = nil;
    task.taskIdentifer = @"";
    [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"task_identifer":@""} referKey:@"task_id" referValue:task.taskId];
    if (task.downloadTask != nil) {
        NSString *taskString = [NSString stringWithFormat:@"%@ %@",task.taskId, task.downloadTask];
        NSLog(@"这两个根本不一样 %@",taskString);
    }
}

/**
 *delete the resumData of the task \n
 *then update the database
 */

-(void)deleteResumDataWithTask:(VMDownLoadTask *)task{
    NSFileManager *manager = [NSFileManager  defaultManager];
    if (task.resumDataPath) {
        [manager removeItemAtPath:task.resumDataPath error:nil];
        task.resumDataPath = nil;
        task.resumData = nil;
        task.taskIdentifer = @"";
    
        [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"task_identifer":@""} referKey:@"task_id" referValue:task.taskId];
    }else{
        NSString *documentsResumData = [[VMTools documentPath] stringByAppendingPathComponent:@"Magic_box_resume"];
        NSString *resumName = [documentsResumData stringByAppendingPathComponent:task.videoName];
        [manager removeItemAtPath:resumName error:nil];
        task.resumDataPath = nil;
        task.resumData = nil;
        task.taskIdentifer = @"";
        [self.dataManager updateTable:TASK_TABLE withDictionary:@{@"task_identifer":@""}  referKey:@"task_id" referValue:task.taskId];
    }
    if ([self.resumDataTaskDic objectForKey:task.taskId]) {
        [self.resumDataTaskDic removeObjectForKey:task.taskId];
    }
}

-(BOOL)checkResumDataForTask:(VMDownLoadTask *)task{
    if (task == nil) {
        VMLogError(@"task都没有，你查个屁啊!");
        return NO;
    }
    NSString *documentsResumData = [[VMTools documentPath] stringByAppendingPathComponent:@"Magic_box_resume"];
    NSString *urlName = task.videoName;
    NSString *finalPath = [documentsResumData stringByAppendingPathComponent:urlName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:finalPath]) {
        task.resumDataPath = finalPath;
        task.resumData = [NSData dataWithContentsOfFile:finalPath];
        return YES;
    }
    return NO;
}

#pragma mark-
#pragma mark------3g download actions------



@end
