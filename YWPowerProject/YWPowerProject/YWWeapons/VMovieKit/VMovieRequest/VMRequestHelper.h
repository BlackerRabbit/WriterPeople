//
//  VMRequestHelper.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/2.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMovieDefine.h"
@class VMError;
typedef NS_ENUM(NSInteger,VMRequestType){
    
    VMREQUEST_GET = 0,
    VMREQUEST_POST ,
    VMREQUEST_DOWNLOAD,
    VMREQUEST_UPLOAD,
};


@interface VMRequestHelper : NSObject

#pragma mark-
#pragma mark------get request------

/*所有的success以及errorblock都是在主线程执行的，不许要在额外处理
 *
 *
 */
+(void)requestGetURL:(NSString *)url
       completeBlock:(void (^)(id vmRequest, id responseObj))completeBlock
          errorBlock:(void (^)(VMError *error))errorBlock;

+(void)requestGetURL:(NSString *)url
             timeout:(int)timeout
       completeBlock:(void (^)(id vmRequest, id responseObj))completeBlock
          errorBlock:(void (^)(VMError *error))errorBlock;

+(void)requestGetURL:(NSString *)url
               param:(NSDictionary *)param
           headerDic:(NSDictionary *)header
             timeout:(int)timeout
       completeBlock:(void (^)(id, id))completeBlock
          errorBlock:(void (^)(VMError *))errorBlock;


#pragma mark-
#pragma mark------post接口------

+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
        completeBlock:(void (^)(id vmRequest, id responseObj))completeBlock
           errorBlock:(void (^)(VMError *error))errorBlock;

+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
              timeout:(int)timeout
        completeBlock:(void (^)(id vmRequest, NSString *responseStr))completeBlock
           errorBlock:(void (^)(VMError *error))errorBlock;

+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
     withOperationKey:(NSString *)key
  operationDictionary:(NSMutableDictionary *)dic
        completeBlock:(void (^)(id vmRequest, id responseObj))completeBlock
           errorBlock:(void (^)(VMError *error))errorBlock;

#pragma mark-
#pragma mark------upload images------
//files里面存的是字典，字典的结构为@{@"name":filename,@"data":nsdata};
+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
                files:(NSArray *)files
     withOperationKey:(NSString *)key
  operationDictionary:(NSMutableDictionary *)dic
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock;


+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
             withFile:(BOOL)withFile
     withOperationKey:(NSString *)key
  operationDictionary:(NSMutableDictionary *)dic
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock;


#pragma mark-
#pragma mark------cancel actions------
+(void)cancleOperation:(id)oper;
+(void)cancleAllRequest;


#pragma mark-
#pragma mark------这个是可以添加header的请求------

+(void)requestPostURL:(NSString *)url
               header:(NSDictionary *)header
            paramDict:(NSDictionary *)postDict
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock;

+(void)requestPostURL:(NSString *)url
               header:(NSDictionary *)header
            paramDict:(NSDictionary *)postDict
              timeOut:(int)timeOut
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock;

+(void)requestPostURL:(NSString *)url
               header:(NSDictionary *)header
            paramDict:(NSDictionary *)postDict
                files:(NSArray *)files
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock;

@end
