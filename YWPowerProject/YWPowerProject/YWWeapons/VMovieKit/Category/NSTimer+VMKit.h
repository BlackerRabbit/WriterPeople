//
//  NSTimer+VMKit.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/19.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer(VMKit)
- (void)pauseTimer; //停止定时器
- (void)resumeTimer; //开启定时器
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval; //几秒后开启定时器

@end
