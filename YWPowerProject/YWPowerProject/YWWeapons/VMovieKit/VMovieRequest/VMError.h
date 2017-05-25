//
//  VMError.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/3.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
/**请求成功
 */
#define kVMRequestSuccess @"0"

/**请求成功，但是业务返回错误
 */
#define kVMRequestFail @"1"

/**请求失败，网络错误
 */
#define kVMRequestNetFail @"-1"

/**参数错误
 */
#define kVMRequestParamsFail @"-2"

/**未知错误
 */
#define kVMRequestUnknowFail @"-3"


@interface VMError : NSObject

/**
 *kVMRequestSuccess = 0
 *kVMRequestFail = 1
 *kVMRequestNetFail = -1
 *kVMRequestParamsFail = -2
 *kVMRequestUnknowFail = -3
 */
@property (nonatomic, strong) NSString *errorCode;
@property (nonatomic, strong) NSString *errorReason;
@property (nonatomic, strong) NSDictionary *userInfo;
@end
