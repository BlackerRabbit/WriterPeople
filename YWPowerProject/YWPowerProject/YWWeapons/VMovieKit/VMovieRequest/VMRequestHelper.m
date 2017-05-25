//
//  VMRequestHelper.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/2.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMRequestHelper.h"
#import <AFNetworking.h>
#import "NSString+VMKit.h"
#import "VMError.h"
#import "VMovieRequest.h"
#import "VMTools.h"

/*
 *  header 中的设备唯一标识
 */
#define kKeyHeaderDeviceId @"Device-Id"

@interface VMRequestHelper ()

@end


@implementation VMRequestHelper

+(void)requestGetURL:(NSString *)url
       completeBlock:(void (^)(id mmdRequest, id responseObj))completeBlock
          errorBlock:(void (^)(VMError *error))errorBlock{
    
    [VMRequestHelper requestURL:url
                         method:VMREQUEST_GET
                         header:nil
                      paramDict:nil
                         files:nil
                     needCancel:NO
               withOperationKey:nil
            operationDictionary:nil
                        timeout:30
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
}


+(void)requestGetURL:(NSString *)url
             timeout:(int)timeout
       completeBlock:(void (^)(id mmdRequest, id responseObj))completeBlock
          errorBlock:(void (^)(VMError *error))errorBlock{
    
    [VMRequestHelper requestURL:url
                         method:VMREQUEST_GET
                         header:nil
                      paramDict:nil
                          files:nil
                     needCancel:NO
               withOperationKey:nil
            operationDictionary:nil
                        timeout:timeout
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
}

+(void)requestGetURL:(NSString *)url
               param:(NSDictionary *)param
           headerDic:(NSDictionary *)header
             timeout:(int)timeout
       completeBlock:(void (^)(id, id))completeBlock
          errorBlock:(void (^)(VMError *))errorBlock{
    
    [VMRequestHelper requestURL:url
                         method:VMREQUEST_GET
                         header:header
                      paramDict:param
                          files:nil
                     needCancel:NO
               withOperationKey:nil
            operationDictionary:nil
                        timeout:timeout
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
}


#pragma mark-
#pragma mark------post actions------


+(void)requestPostURL:(NSString *)url
             paramDict:(NSDictionary *)postDict
        completeBlock:(void (^)(id mmdRequest, id responseObj))completeBlock
           errorBlock:(void (^)(VMError *error))errorBlock{
    
    [VMRequestHelper requestURL:url
                         method:VMREQUEST_POST
                         header:nil
                      paramDict:postDict
                         files:nil
                     needCancel:NO
               withOperationKey:nil
            operationDictionary:nil
                        timeout:30
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
    
    
}

+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
              timeout:(int)timeout
        completeBlock:(void (^)(id vmRequest, NSString *responseStr))completeBlock
           errorBlock:(void (^)(VMError *error))errorBlock{
    
    [VMRequestHelper requestURL:url
                         method:VMREQUEST_POST
                         header:nil
                      paramDict:postDict
                         files:nil
                     needCancel:NO
               withOperationKey:nil
            operationDictionary:nil
                        timeout:timeout
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
}

+(void)requestURL:(NSString *)url
           method:(VMRequestType)method
           header:(NSDictionary *)header
        paramDict:(NSDictionary *)paramDict
           files:(NSArray *)images
       needCancel:(BOOL)needCacel
 withOperationKey:(NSString *)key
operationDictionary:(NSMutableDictionary *)operationDic
          timeout:(int)timeout
    completeBlock:(void (^)(id vmRequest, id responesObj))completeBlock
       errorBlock:(void (^)(VMError *error))errorBlock{
    
    if ([url isKindOfClass:[NSString class]] && [url length] > 0)
    {
        
    }
    else
    {
        return;
    }
    //拼接请求地址
    VMovieRequest *vmRequest = [VMovieRequest shareRequest];
    NSString *httpURL =[[vmRequest getURLHost] stringByAppendingUrlComponent:url];
    
    //打印log
    NSLog(@"地址：\n%@",httpURL);
    NSLog(@"参数：\n%@",paramDict);
    
    
    
    /*
    //获取全局的manager
    vmovieOperationManager = [VMRequestHelper vmovieOperationManager];
    if (header != nil && header.allValues.count > 0) {
        AFHTTPRequestSerializer *serializer = [VMRequestHelper getRequestSerializerWithHeader:header];
        vmovieOperationManager.requestSerializer = serializer;
    }
    if (timeout > 0) {
        vmovieOperationManager.requestSerializer.timeoutInterval = timeout;
    }
    
    AFHTTPRequestOperation *currentOperation;
    if (method == VMREQUEST_GET) {
        
        currentOperation = [vmovieOperationManager GET:httpURL
                                     parameters:paramDict
                                        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSLog(@"请求成功返回值:\n%@",responseObject);
                        
                                completeBlock(operation,responseObject);
                                    
                                        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"请求失败错误:\n%@",error);
                                VMError *veError = [[VMError alloc]init];
                                veError.errorCode = @"0";
                                veError.errorReason = @"请求失败";
                                errorBlock(veError);
                                    
                            }];
        
    }else if(method == VMREQUEST_POST){
        
        currentOperation = [vmovieOperationManager POST:httpURL
                                      parameters:paramDict
                                         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                             NSLog(@"请求返回的response是%@",operation.response);
                                    NSLog(@"请求成功返回值:\n%@",responseObject);
                                    completeBlock(operation,responseObject);
                                
                                }
                                failure:^(AFHTTPRequestOperation * _Nonnull operation,NSError * _Nonnull error) {
                                NSString *str = [[NSString alloc]initWithData:operation.responseData encoding:NSUTF8StringEncoding];
                                NSLog(@"%@",str);
#warning 这个地方需要后面注释掉，因为现在服务器返回的就是一个字符串，以后是json字符串，此处仅作为测试
                                NSLog(@"请求失败错误:\n%@",error);
                                VMError *veError = [[VMError alloc]init];
                                veError.errorCode = @"0";
                                veError.errorReason = str;
                                errorBlock(veError);
                                 }];
            
        
    }else if (method == VMREQUEST_UPLOAD){
        
        NSArray *array = paramDict.allKeys;
        NSMutableDictionary *paramsFinalDic = [paramDict mutableCopy];
        NSMutableArray *files = [@[]mutableCopy];
        for (id key in array) {
            id value = paramDict[key];
            if ([[value class] isSubclassOfClass:[NSData class]]) {
                [files addObject:@{key:value}];
                [paramsFinalDic removeObjectForKey:key];
            }
        }
        
        for (int i = 0; i < images.count; i++) {
            NSDictionary *dic = images[i];
            NSDictionary *imagesDic = @{dic[@"name"]:dic[@"data"]};
            [files addObject:imagesDic];
        }
        //images里面存的是字典，字典的结构为@{@"name":filename,@"data":nsdata};
        currentOperation = [vmovieOperationManager POST:httpURL
                                             parameters:paramDict
                                constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                    for (int i = 0; i < files.count; i++) {
                                        NSDictionary *dataDic = files[i];
                                        NSString *fileName = [dataDic.allKeys lastObject];
                                        NSString *finalName = [[fileName componentsSeparatedByString:@"."] firstObject];
                                        
                                        [formData appendPartWithFileData:dataDic.allValues.lastObject
                                                                    name:finalName
                                                                fileName:fileName
                                                                mimeType:[VMRequestHelper contentTypeFromName:fileName]];
                                    }
                                    
                                } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                    NSLog(@"请求成功返回值:\n%@",responseObject);
                                    completeBlock(operation,responseObject);
                                    
                                } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                    NSString *str = [[NSString alloc]initWithData:operation.responseData encoding:NSUTF8StringEncoding];
                                    NSLog(@"%@",str);
#warning 这个地方需要后面注释掉，因为现在服务器返回的就是一个字符串，以后是json字符串，此处仅作为测试
                                    NSLog(@"请求失败错误:\n%@",error);
                                    VMError *veError = [[VMError alloc]init];
                                    veError.errorCode = @"0";
                                    veError.errorReason = str;
                                    errorBlock(veError);
                                }];
    }
    //判断是否需要将当前的request存起来，以便后面进行cancle
    if (needCacel == NO) {
        
    }else{
        if ([key isValid] == NO) {
            return;
        }
        if (operationDic == nil) {
            return;
        }
        operationDic[key] = currentOperation;
    }
     */
}


/*

+(AFHTTPRequestOperationManager *)vmovieOperationManager{
    if (vmovieOperationManager == nil) {
        vmovieOperationManager = [AFHTTPRequestOperationManager manager];
        vmovieOperationManager.operationQueue.maxConcurrentOperationCount = 5;
        vmovieOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
        security.allowInvalidCertificates = NO;
//        vmovieOperationManager.securityPolicy 
    }
    return vmovieOperationManager;
}

+(AFHTTPRequestOperationManager *)vmovieOperationManagerWi{
    if (vmovieOperationManager == nil) {
        vmovieOperationManager = [AFHTTPRequestOperationManager manager];
        vmovieOperationManager.operationQueue.maxConcurrentOperationCount = 5;
        vmovieOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        AFHTTPResponseSerializer *responser = [AFHTTPResponseSerializer serializer];
        vmovieOperationManager.responseSerializer = responser;
        vmovieOperationManager.requestSerializer = serializer;
    }
    return vmovieOperationManager;
}
*/


+(void)addNormalRequestHEADER:(NSDictionary *)head forRequest:(NSMutableURLRequest *)request{
    if ([[head class]isSubclassOfClass:[NSNull class]] || head.allKeys.count == 0 || request == nil) {
        return;
    }
    NSArray *allKeys = head.allKeys;
    for (int i = 0; i < head.allKeys.count; i++) {
        NSString *headName = allKeys[i];
        NSString *headValue = head[headName];
        [request addValue:headValue forHTTPHeaderField:headName];
    }
}

+(void)cancleAllRequest{
    /*
    AFHTTPRequestOperation *operation = [vmovieOperationManager.operationQueue operations].firstObject;
    [operation cancel];
    [vmovieOperationManager.operationQueue cancelAllOperations];
     */
}

+(void)cancleOperation:(id)oper{
    /*
    NSLock *lock = [[NSLock alloc]init];
    [lock lock];
    for (AFHTTPRequestOperation *operation in vmovieOperationManager.operationQueue.operations) {
        if (oper == operation) {
            [oper cancel];
            break;
        }else{
            
        }
    }
    [lock unlock];
     */
}


+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
     withOperationKey:(NSString *)key
  operationDictionary:(NSMutableDictionary *)dic
        completeBlock:(void (^)(id vmRequest, id responseObj))completeBlock
           errorBlock:(void (^)(VMError *error))errorBlock{

    [VMRequestHelper requestURL:url
                         method:VMREQUEST_POST
                         header:nil
                      paramDict:postDict
                         files:nil
                     needCancel:YES
               withOperationKey:key
            operationDictionary:dic
                        timeout:60
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
   
}

+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
               files:(NSArray *)images
     withOperationKey:(NSString *)key
  operationDictionary:(NSMutableDictionary *)dic
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock{
    [VMRequestHelper requestURL:url
                         method:VMREQUEST_UPLOAD
                         header:nil
                      paramDict:postDict
                         files:images
                     needCancel:YES
               withOperationKey:key
            operationDictionary:dic
                        timeout:120
                  completeBlock:completeBlock
                     errorBlock:errorBlock];
}

+(void)requestPostURL:(NSString *)url
            paramDict:(NSDictionary *)postDict
             withFile:(BOOL)withFile
     withOperationKey:(NSString *)key
  operationDictionary:(NSMutableDictionary *)dic
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock{
    if (!withFile) {
        [VMRequestHelper requestPostURL:url
                              paramDict:postDict
                       withOperationKey:key
                    operationDictionary:dic
                          completeBlock:completeBlock
                             errorBlock:errorBlock];
    }else{
    
        [VMRequestHelper requestURL:url
                             method:VMREQUEST_UPLOAD
                             header:nil
                          paramDict:postDict
                              files:nil
                         needCancel:YES
                   withOperationKey:key
                operationDictionary:dic
                            timeout:120
                      completeBlock:completeBlock
                         errorBlock:errorBlock];
    }
}


+(void)requestPostURL:(NSString *)url
               header:(NSDictionary *)header
            paramDict:(NSDictionary *)postDict
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock{
    if (header == nil || header.allValues.count == 0) {
        
        [VMRequestHelper requestPostURL:url
                              paramDict:postDict
                          completeBlock:completeBlock
                             errorBlock:errorBlock];
    }else{
        
        [VMRequestHelper requestURL:url
                             method:VMREQUEST_POST
                             header:header
                          paramDict:postDict
                              files:nil
                         needCancel:NO
                   withOperationKey:nil
                operationDictionary:nil
                            timeout:60
                      completeBlock:completeBlock
                         errorBlock:errorBlock];
    }
}

+(void)requestPostURL:(NSString *)url
               header:(NSDictionary *)header
            paramDict:(NSDictionary *)postDict
              timeOut:(int)timeOut
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock{
    if (header == nil || header.allValues.count == 0) {
        
        [VMRequestHelper requestPostURL:url
                              paramDict:postDict
                                timeout:timeOut
                          completeBlock:completeBlock
                             errorBlock:errorBlock];
    }else{
        
        [VMRequestHelper requestURL:url
                             method:VMREQUEST_POST
                             header:header
                          paramDict:postDict
                              files:nil
                         needCancel:NO
                   withOperationKey:nil
                operationDictionary:nil
                            timeout:timeOut
                      completeBlock:completeBlock
                         errorBlock:errorBlock];
    }
}


+(void)requestPostURL:(NSString *)url
               header:(NSDictionary *)header
            paramDict:(NSDictionary *)postDict
                files:(NSArray *)files
        completeBlock:(void (^)(id, id))completeBlock
           errorBlock:(void (^)(VMError *))errorBlock{
    if (header == nil || header.allValues.count == 0) {
        [VMRequestHelper requestPostURL:url
                              paramDict:postDict
                                  files:files
                       withOperationKey:nil
                    operationDictionary:nil
                          completeBlock:completeBlock
                             errorBlock:errorBlock];
    }else{
        [VMRequestHelper requestURL:url
                             method:VMREQUEST_UPLOAD
                             header:header
                          paramDict:postDict
                              files:files
                         needCancel:YES
                   withOperationKey:nil
                operationDictionary:nil
                            timeout:60
                      completeBlock:completeBlock
                         errorBlock:errorBlock];
    }
}



#pragma mark-
#pragma mark------http mine type of file------

+(NSString *)contentTypeFromName:(NSString *)fileName{
    
    NSAssert(fileName, @"filename can not be null");
    if ([fileName hasSuffix:@"png"]) {
        return @"image/png";
    }
    if ([fileName hasSuffix:@"jpg"] || [fileName hasSuffix:@"jpeg"] || [fileName hasSuffix:@"jpe"]) {
        return @"image/jpeg";
    }
    return @"image/png";
}


//添加请求的头部信息
+(AFHTTPRequestSerializer *)getRequestSerializerWithHeader:(NSDictionary *)heades{
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSEnumerator* enumer = [heades keyEnumerator];
    id dicKey = nil;
    while (dicKey = [enumer nextObject]){
        [serializer setValue:[heades objectForKey:dicKey] forHTTPHeaderField:dicKey];
    }
    return serializer;
}

@end
