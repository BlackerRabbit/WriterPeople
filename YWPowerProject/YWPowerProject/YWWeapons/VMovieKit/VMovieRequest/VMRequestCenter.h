//
//  VMRequestCenter.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/2.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMRequestCenter : NSObject

//一个request被缓存的时长，这是一个全局变量，设置一次之后，所有的请求都遵循这个时间
@property (nonatomic, assign, readwrite) NSInteger requestCacheTime;

+(VMRequestCenter *)currentRequestCenter;




@end
