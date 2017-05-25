//
//  SWWeiBoEmotionManager.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/8.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "SWWeiBoEmotionManager.h"
#import "VMovieKit.h"
#import <ImageIO/ImageIO.h>

NSString *const SWWeiBoEmotionNameDoesNotExistsError = @"SWWeiBoEmotionNameDoesNotExistsError";
NSString *const SWWeiBoEmotionDownloadError          = @"SWWeiBoEmotionDownloadError";
NSString *const SWWeiBoEmotionDidNotFindError        = @"SWWeiBoEmotionDidNotFindError";



NSString *const SWWeiBoDownloadImageURL             = @"SWWeiBoDownloadImageURL.url";
NSString *const SWWeiBoDownloadImageSaveFolder      = @"SWWeiBoDownloadImageSaveFolder.folder";
NSString *const SWWeiBoDownloadImageName            = @"SWWeiBoDownloadImageName.name";

@interface SWWeiBoEmotionManager ()
@property (nonatomic, assign, readwrite) NSInteger retryTimes;
@property (nonatomic, assign, readwrite) NSInteger repeatTime;
@property (nonatomic, strong, readwrite) NSTimer *cacheTimer;

@property (nonatomic, strong, readwrite) NSArray *dataArrray;

@property (nonatomic, strong, readwrite) NSMutableDictionary *emotionDic;
@property (nonatomic, strong, readwrite) NSMutableArray *retryListAry;

//最佳列表的策略暂时先放着，以后优化一下，
@property (nonatomic, strong, readwrite) NSMutableArray *favoriteList;


//这是一个存放下载图片的block容器array，用来存储那些暂时没有办法返回的blcok。
@property (nonatomic, strong, readwrite) NSMutableArray *emotionCheckHandlerAry;

@end


@implementation SWWeiBoEmotionManager

-(void)dealloc{
    [self.cacheTimer invalidate];
    self.cacheTimer = nil;
}

+(SWWeiBoEmotionManager *)shareManager{
    static SWWeiBoEmotionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SWWeiBoEmotionManager alloc]init];
    });
    return manager;
}

-(id)init{

    self = [super init];
    if (self) {
        self.retryTimes     = 0;
        self.repeatTime     = 30;
        self.emotionDic     = [@{}mutableCopy];
        self.retryListAry   = [@[]mutableCopy];
        self.favoriteList   = [@[]mutableCopy];
        self.emotionCheckHandlerAry = [@[]mutableCopy];
        [self updateEmotion];
        return self;
    }
    return nil;
}

-(NSAttributedString *)checkEmotion:(NSString *)emotion{
    if (emotion == nil) {
        return nil;
    }
    
    __block int count = 0;
    __block NSAttributedString *attString = nil;
    [self.dataArrray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *icon = dic[@"icon"];
        NSString *phrase = dic[@"phrase"];
        
        count ++;
        NSLog(@"%d %lu %lu",count, (unsigned long)idx, (unsigned long)self.dataArrray.count);
        
        if ([phrase isEqualToString:emotion]) {
            *stop = YES;
            NSString *hashName = [NSString stringWithFormat:@"%ld",[icon hash]];
            NSString *imgPath = [[VMTools documentPath] stringByAppendingPathComponent:@"SWWeiBoEmotion"];
            NSString *finImgPath = [imgPath stringByAppendingPathComponent:hashName];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL imgExist = [manager fileExistsAtPath:finImgPath];
            if (imgExist) {
                __block UIImage *image = nil;
                if ([icon hasSuffix:@".gif"]) {
                    [self getGIFImageWithURL:finImgPath withCompleteBlock:^(NSArray *imgAry) {
                        image = [imgAry firstObject];
                    }];
                }else{
                    image = [UIImage imageWithContentsOfFile:finImgPath];
                }

                //创建相应的attsting
                NSTextAttachment *attment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
                attment.image = image;
                attment.bounds = CGRectMake(0, 0, 15, 15);
                NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:attment];
                attString = att;
            }else{
                
                NSDictionary *infoDic = @{
                                          SWWeiBoDownloadImageURL:icon,
                                          SWWeiBoDownloadImageName:emotion,
                                          SWWeiBoDownloadImageSaveFolder:@"SWWeiBoEmotion"
                                          };
                [self downloadImage:emotion userInfo:infoDic completeHandler:^(NSString *url, NSString *imgPath, UIImage *image, NSError *error) {
                    
                }];
            }
        }else{
            if (count == self.dataArrray.count) {
              
                NSLog(@"哎呀我去，还真被执行了啊！！！！！");
            }
        }
    }];
    return attString;
}


-(void)checkEmotion:(NSString *)emotion withCompleteHandler:(SWWeiBoCheckMeotionCompleteHandler)handler{
    
    if ([emotion isValid] == NO) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:SWWeiBoEmotionNameDoesNotExistsError code:-1 userInfo:nil];
            handler(emotion,nil, nil, error);
        }
        return;
    }
    __block int count = 0;
    [self.dataArrray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *icon = dic[@"icon"];
        NSString *phrase = dic[@"phrase"];
        
        count ++;
        NSLog(@"%d %lu %lu",count, (unsigned long)idx, (unsigned long)self.dataArrray.count);
        
        if ([phrase isEqualToString:emotion]) {
            *stop = YES;
            NSString *hashName = [NSString stringWithFormat:@"%ld",[icon hash]];
            NSString *imgPath = [[VMTools documentPath] stringByAppendingPathComponent:@"SWWeiBoEmotion"];
            NSString *finImgPath = [imgPath stringByAppendingPathComponent:hashName];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL imgExist = [manager fileExistsAtPath:finImgPath];
            if (imgExist) {
                if (handler) {
                    
                    if ([icon hasSuffix:@".gif"]) {
                        [self getGIFImageWithURL:finImgPath withCompleteBlock:^(NSArray *imgAry) {
                            UIImage *image = [imgAry firstObject];
                            if (handler) {
                                handler(emotion, nil, image, nil);
                            }
                        }];
                    }else{
                        UIImage *image = [UIImage imageWithContentsOfFile:finImgPath];
                        handler(emotion, finImgPath, image, nil);
                    }
                }
                return ;
            }else{
            //在这里进行下载，然后，在主线程返回
               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   UIImage *image = [UIImage imageWithURL:icon timeOut:10];
                   if (image) {
                       NSString *hashName = [NSString stringWithFormat:@"%ld",[icon hash]];
                       NSString *imgPath = [[VMTools documentPath] stringByAppendingPathComponent:@"SWWeiBoEmotion"];
                       dispatch_async(dispatch_get_main_queue(), ^{
                        //下载成功后，将图片的url作为value存入字典，将图片的name作为key
                           NSString *imgRealPath = [imgPath stringByAppendingPathComponent:hashName];
                           if ([icon hasSuffix:@".gif"]) {
                               [self getGIFImageWithURL:imgRealPath withCompleteBlock:^(NSArray *imgAry) {
                                   if (handler) {
                                       UIImage *image = [imgAry firstObject];
                                       handler(emotion, imgRealPath, image, nil);
                                   }
                               }];
                           }else{
                               if (handler) {
                                   UIImage *image = [UIImage imageWithContentsOfFile:imgRealPath];
                                   handler(emotion, imgRealPath, image, nil);
                               }
                           }
                           return ;
                        });
                   }else{
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (handler) {
                               NSError *error = [NSError errorWithDomain:SWWeiBoEmotionDownloadError code:-2 userInfo:nil];
                               handler(emotion, nil, nil,error);
                               return ;
                           }
                       });
                   }
               });
            }
        }else{
            if (count == self.dataArrray.count) {
                NSError *error = [NSError errorWithDomain:SWWeiBoEmotionDidNotFindError code:-3 userInfo:nil];
                handler(emotion, nil, nil,error);
                NSLog(@"哎呀我去，还真被执行了啊！！！！！");
            }
        }
    }];
}

-(void)checkEmotions:(NSArray *)emotions{
    
    /*
     {
     category = "\U6d6a\U5c0f\U82b1";
     common = 0;
     hot = 0;
     icon = "http://img.t.sinajs.cn/t4/appstyle/expression/ext/normal/09/lxhjihuoche_thumb.gif";
     phrase = "[\U6324\U706b\U8f66]";
     picid = "";
     type = face;
     url = "http://img.t.sinajs.cn/t4/appstyle/expression/ext/normal/09/lxhjihuoche_org.gif";
     value = "[\U6324\U706b\U8f66]";
     },
     */
    

    if (emotions == nil || emotions.count == 0) {
        return;
    }
    NSMutableArray *findEmoAry = [@[]mutableCopy];
    
    [emotions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *emotionName = (NSString *)obj;
        for (NSDictionary *dic in self.dataArrray) {
            NSString *phrase = dic[@"phrase"];
            if ([phrase isEqualToString:emotionName]) {
                [findEmoAry addObject:dic];
                break;
            }
        }
    }];
    
    
    NSMutableArray *emoresultAry = [@[]mutableCopy];
    
    if (findEmoAry.count) {
        
        //这里的话应该是像manager类请求相关的表情图片，如果本地没有，需要进行下载
        for (NSDictionary *dic in findEmoAry) {
            NSString *icon = dic[@"icon"];
            NSString *phrase = dic[@"phrase"];
            NSString *hashName = [NSString stringWithFormat:@"%ld",[icon hash]];
            NSString *imgPath = [[VMTools documentPath] stringByAppendingPathComponent:@"SWWeiBoEmotion"];
            NSString *finImgPath = [imgPath stringByAppendingPathComponent:hashName];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL imgExist = [manager fileExistsAtPath:finImgPath];
            if (imgExist) {
                NSDictionary *dic = @{phrase  : finImgPath };
                [emoresultAry addObject:dic];
            }
        }
    }
    self.findImgDic = emoresultAry.lastObject;
//    NSLog(@"%p",emoresultAry);
    
}

-(void)loadValues:(NSArray *)ary{
    self.dataArrray = ary;
    [self downloadImages:self.dataArrray];
}



-(void)updateEmotion{
    
    [self updateEmotionIfNeed:YES];
}

-(void)updateEmotionIfNeed:(BOOL)need{
    //
    NSArray *emotions = [self loadFormLoacal];
    if (emotions == nil) {
        //从网络进行获取，
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *array = [self requestEmotion];
            if (array) {
                [self writeEmotionsToLocal:array];
            }else{
                //下载失败，进入retry流程
                
            }
        });
    }else{
        
    }
}

-(void)writeEmotionsToLocal:(NSArray *)array{
    NSLock *lock = [[NSLock alloc]init];
    [lock lock];
    NSString *emo = [self emotionPath];
    BOOL write = [array writeToFile:emo atomically:YES];
    if (write) {
        NSLog(@"写表情到本地成功");
    }else{
        NSLog(@"写表情到本地失败");
    }
    [lock unlock];
}

-(NSString *)emotionPath{
    NSString *docu = [VMTools documentPath];
    NSString *emotionPath = [docu stringByAppendingPathComponent:@"emotion.plist"];
    return emotionPath;
}


-(NSArray *)loadFormLoacal{
    
    NSString *emotionPath = [self emotionPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL fileExist = [manager fileExistsAtPath:emotionPath];
    if (fileExist == NO) {
        return nil;
    }else{
        NSArray *emotions = [NSArray arrayWithContentsOfFile:emotionPath];
        return emotions;
    }
}

-(NSArray *)requestEmotion{
    
    NSString *accesToken = @"2.00uaVGcFIPWHbBc90b8611710JQYye";
    NSString *type = @"face";
    NSString *language = @"cnname";
    NSDictionary *param = @{
                            @"access_token" : accesToken,
                            @"type"         : type,
                            @"language"     : language
                            };
    NSString *url = [NSString stringWithFormat:@"%@?%@",@"https://api.weibo.com/2/emotions.json",[self urlEncodedKeyValueStringWithDic:param]];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingMappedAlways error:&error];
    if (data) {
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        return result;
    }else
        return nil;
}

-(void)retryRequest{
    if (self.retryTimes > 3) {
        [self cacheRequestAndRestart];
        //启动定时请求线程
        return;
    }
    NSArray *array = [self requestEmotion];
    if (array && array.count > 0) {
        self.retryTimes = 0;
        return;
    }else{
        self.retryTimes ++;
        [self retryRequest];
    }
}

-(void)cacheTimerFired:(NSTimer *)timer{
    
    //每次发动一次请求，凑，这里的逻辑有点复杂，暂时先就把接口留在这吧。
}

-(void)cacheRequestAndRestart{
    
    [self.cacheTimer resumeTimer];
}

-(NSString*) urlEncodedKeyValueStringWithDic:(NSDictionary *)dic {
    
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in dic) {
        NSObject *value = [dic valueForKey:key];
        if([value isKindOfClass:[NSString class]])
            [string appendFormat:@"%@=%@&", [self mk_urlEncodedStringWithString:key], [self mk_urlEncodedStringWithString:((NSString*)value)]];
        else
            [string appendFormat:@"%@=%@&", [self mk_urlEncodedStringWithString:key], value];
    }
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    return string;
}

- (NSString*) mk_urlEncodedStringWithString:(NSString *)str { // mk_ prefix prevents a clash with a private api
    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) str,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    if(!encodedString)
        encodedString = @"";
    return encodedString;
}


-(void)loadEmotion:(NSString *)emotion withCompleteBlock:(SWWeiBoEmotionLoadHandler)handler{
    
    if ([emotion isValid] == NO) {
        NSError *error = [NSError errorWithDomain:SWWeiBoEmotionNameDoesNotExistsError code:1 userInfo:nil];
        if (handler) {
            handler(nil, error);
        }
        return;
    }
}

#pragma mark- 
#pragma mark -down load images ------

-(void)downloadImage:(NSString *)url{
    UIImage *image = [UIImage imageWithURL:url timeOut:10];
}

-(void)downloadImages:(NSArray *)array{
    
    /*这是图片的存储路径
     NSString *hashName = [NSString stringWithFormat:@"%ld",[url hash]];
     NSFileManager *manager = [NSFileManager defaultManager];
     BOOL isExist = [manager fileExistsAtPath:[[VMTools documentPath]stringByAppendingPathComponent:@"SWWeiBoEmotion"]];
     */
    
    if (array == nil || array.count == 0) {
        return;
    }
    dispatch_apply(array.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t t) {
        NSDictionary *dic = array[t];
        NSString *icon = dic[@"icon"];
        UIImage *image = [UIImage imageWithURL:icon timeOut:10];
        NSString *hashName = [NSString stringWithFormat:@"%ld",[icon hash]];
        NSString *imgPath = [[VMTools documentPath] stringByAppendingPathComponent:@"SWWeiBoEmotion"];
        
        NSString *phrase = dic[@"phrase"];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //下载成功后，将图片的url作为value存入字典，将图片的name作为key
                NSString *imgRealPath = [imgPath stringByAppendingPathComponent:hashName];
                [self.emotionDic setObject:imgRealPath forKey:phrase];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.retryListAry addObject:dic];
            });
        }
    });
}

//NSString *url, NSString *imgPath, UIImage *image, NSError *error

-(void)downloadImage:(NSString *)img userInfo:(NSDictionary *)userInfo completeHandler:(SWWeiBoImageCompleteHandler)handler{
    if (userInfo == nil || userInfo.count == 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:SWWeiBoEmotionNameDoesNotExistsError code:-1 userInfo:nil];
            handler(nil, nil, nil, error);
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = userInfo[SWWeiBoDownloadImageURL];
        NSString *name = userInfo[SWWeiBoDownloadImageName];
        NSString *folder = userInfo[SWWeiBoDownloadImageSaveFolder];
        UIImage *image = [UIImage imageWithURL:url inDocumentFolder:folder];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    NSString *hashName = [NSString stringWithFormat:@"%ld",[url hash]];
                    NSString *imgPath = [[VMTools documentPath] stringByAppendingPathComponent:folder];
                    NSString *finImgPath = [imgPath stringByAppendingPathComponent:hashName];
                    
                    if ([url hasSuffix:@".gif"]) {
                        [self getGIFImageWithURL:finImgPath withCompleteBlock:^(NSArray *imgAry) {
                            UIImage *resultImage = [imgAry firstObject];
                            if (handler) {
                                handler(url, finImgPath, resultImage, nil);
                            }
                        }];
                    }else{
                        UIImage *resultImage = [UIImage imageWithContentsOfFile:finImgPath];
                        handler(url, finImgPath, resultImage, nil);
                    }
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    NSError *error = [NSError errorWithDomain:SWWeiBoEmotionDownloadError code:-2 userInfo:nil];
                    handler(url, nil, nil, error);
                }
            });
        }
    });
}

#pragma mark - load gif ------

-(void)getGIFImageWithURL:(NSString *)urlString withCompleteBlock:(void(^)(NSArray *imgAry))imgBlock{
    
    NSURL *url = [NSURL fileURLWithPath:urlString];
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    size_t count = CGImageSourceGetCount(source);
    float allTime = 0;
    NSMutableArray *imgAry      = [@[]mutableCopy];
    NSMutableArray *timeAry     = [@[]mutableCopy];
    NSMutableArray *widthAry    = [@[]mutableCopy];
    NSMutableArray *heightAry   = [@[]mutableCopy];
    
    for (size_t i = 0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        [imgAry addObject:[UIImage imageWithCGImage:image]];
        CGImageRelease(image);
        //大小信息
        NSDictionary *info = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        CGFloat width = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelWidth] floatValue];
        CGFloat height = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelHeight] floatValue];
        [widthAry addObject:@(width)];
        [heightAry addObject:@(height)];
        //时间信息
        NSDictionary *timeInfo = [info objectForKey:(__bridge NSDictionary *)kCGImagePropertyGIFDictionary];
        CGFloat time = [[timeInfo objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime] floatValue];
        allTime += time;
        [timeAry addObject:@(time)];
    }
    if (imgBlock) {
        imgBlock(imgAry);
    }
}


#pragma mark- lazy actions ------

-(NSTimer *)cacheTimer{

    if (_cacheTimer == nil) {
        _cacheTimer = [NSTimer scheduledTimerWithTimeInterval:self.repeatTime target:self selector:@selector(cacheTimerFired:) userInfo:nil repeats:YES];
        [_cacheTimer pauseTimer];
    }
    return _cacheTimer;
}

@end
