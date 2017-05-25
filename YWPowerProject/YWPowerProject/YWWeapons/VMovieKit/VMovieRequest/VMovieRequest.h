//
//  VMovieRequest.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/2.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VMEventSetting){
    
    VMEventSettingDaily = 0,
    VMEventSettingRelease,
};

//跟afnetworking的网络监控是对应的
typedef NS_ENUM (NSInteger, VMNetStatus) {
    VMNetStatusUnKnown          = -1,
    VMNetStatusNotReachable     = 0,
    VMNetStatusMobile           = 1,
    VMNetStatusWIFI             = 2,
};


FOUNDATION_EXPORT NSString * const VMNetworkingReachabilityDidChangeNotification;


@interface VMovieRequest : NSObject
@property (nonatomic, assign) VMEventSetting ves;
@property (nonatomic, assign, readonly) VMNetStatus networkStatus;
+ (VMovieRequest *)shareRequest;
- (NSString *)currentNetworkStateString;
- (void)startNetworkStatusWatching;
- (NSString *)getURLHost;

@end
