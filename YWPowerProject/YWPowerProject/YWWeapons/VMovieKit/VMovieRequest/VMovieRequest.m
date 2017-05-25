//
//  VMovieRequest.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/2.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMovieRequest.h"
#import <AFNetworking.h>

NSString * const VMNetworkingReachabilityDidChangeNotification = @"VMovieKit.com.alamofire.networking.reachability.change";

@interface VMovieRequest()
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@end

@implementation VMovieRequest

-(void)dealloc{

    [self.reachabilityManager stopMonitoring];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

+ (VMovieRequest *)shareRequest
{
    static dispatch_once_t once;
    static VMovieRequest * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[VMovieRequest alloc] init]; } );
    return __singleton__;
}

-(id)init
{
    if(self = [super init])
    {
        self.ves = VMEventSettingRelease;
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [self networkStatusFrom:self.reachabilityManager.networkReachabilityStatus];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkReachabilityStatusChanaged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

-(void)networkStatusFrom:(AFNetworkReachabilityStatus)network{
    switch (network) {
        case AFNetworkReachabilityStatusUnknown: _networkStatus = VMNetStatusUnKnown; break;
        case AFNetworkReachabilityStatusNotReachable: _networkStatus = VMNetStatusNotReachable; break;
        case AFNetworkReachabilityStatusReachableViaWWAN: _networkStatus = VMNetStatusMobile; break;
        case AFNetworkReachabilityStatusReachableViaWiFi: _networkStatus = VMNetStatusWIFI; break;
        default:
            _networkStatus = VMNetStatusUnKnown;
            break;
    }
}

-(NSString *)currentNetworkStateString{
    switch (self.networkStatus) {
        case VMNetStatusUnKnown:return @"";break;
        case VMNetStatusNotReachable:return @"";break;
        case VMNetStatusMobile:return @"3G";break;
        case VMNetStatusWIFI:return @"WiFi";break;
        default:
            return @"WiFi";
            break;
    }
}

-(void)startNetworkStatusWatching{
    [self.reachabilityManager startMonitoring];
}

-(void)networkReachabilityStatusChanaged:(NSNotification *)no{
    
    switch (self.reachabilityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown: _networkStatus = VMNetStatusUnKnown; break;
        case AFNetworkReachabilityStatusNotReachable: _networkStatus = VMNetStatusNotReachable; break;
        case AFNetworkReachabilityStatusReachableViaWWAN: _networkStatus = VMNetStatusMobile; break;
        case AFNetworkReachabilityStatusReachableViaWiFi: _networkStatus = VMNetStatusWIFI; break;
        default:
            _networkStatus = VMNetStatusUnKnown;
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:VMNetworkingReachabilityDidChangeNotification
                                                       object:@(self.networkStatus)];
}

-(NSString *)getURLHost{
    
    switch (self.ves)
    {
        case VMEventSettingDaily:
        {
            return @"http://superteamsvn.sinaapp.com/download/";
        }
        case VMEventSettingRelease:
        {
            return @"http://139.196.100.29:8080/xgows/v1/";
        }
    }
}

@end
