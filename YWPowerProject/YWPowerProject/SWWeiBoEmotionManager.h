//
//  SWWeiBoEmotionManager.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/8.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

FOUNDATION_EXTERN NSString *const SWWeiBoEmotionNameDoesNotExistsError;
FOUNDATION_EXTERN NSString *const SWWeiBoEmotionDownloadError;
FOUNDATION_EXTERN NSString *const SWWeiBoEmotionDidNotFindError;
//FOUNDATION_EXTERN NSString *const SW;


FOUNDATION_EXTERN NSString *const SWWeiBoDownloadImageURL;
FOUNDATION_EXTERN NSString *const SWWeiBoDownloadImageSaveFolder;
FOUNDATION_EXTERN NSString *const SWWeiBoDownloadImageName;


typedef void(^SWWeiBoEmotionLoadHandler)(UIImage *img, NSError *error);

typedef void(^SWWeiBoRequestEmotionCompleteHandler)(NSArray *array, NSError *error);


typedef void(^SWWeiBoCheckMeotionCompleteHandler)(NSString *emtotionName, NSString *imagePath , UIImage *image, NSError *error);

typedef void(^SWWeiBoImageCompleteHandler)(NSString *url, NSString *imgPath, UIImage *image, NSError *error);



@interface SWWeiBoEmotionManager : NSObject

@property (nonatomic, strong, readwrite) NSDictionary *findImgDic;
+(SWWeiBoEmotionManager *)shareManager;

-(void)loadValues:(NSArray *)ary;

-(void)getGIFImageWithURL:(NSString *)urlString withCompleteBlock:(void(^)(NSArray *imgAry))imgBlock;

-(void)checkEmotion:(NSString *)emotion withCompleteHandler:(SWWeiBoCheckMeotionCompleteHandler)handler;

-(void)checkEmotions:(NSArray *)emotions;

-(void)writeEmotionsToLocal:(NSArray *)array;

//-(void)checkURL:(NSString *)url withCompleteBlock:();

//-(UIImage *)checkEmotion:(NSString *)emotion;

-(NSAttributedString *)checkEmotion:(NSString *)emotion;



//接受下载图片的通知，并且在下载完成后，进行block返回
/*
 *这里的userinfo里至少需要两样数据，1，下载的url地址；2，存储的folder目录; 3,下载的图片名称，当然了，这里所有的图片都是用url的hash值来存储的，图片的名称用来备用，或者做为缓存的健来用，如果必要的话。
 */
-(void)downloadImage:(NSString *)img userInfo:(NSDictionary *)userInfo completeHandler:(SWWeiBoImageCompleteHandler)handler;



@end
