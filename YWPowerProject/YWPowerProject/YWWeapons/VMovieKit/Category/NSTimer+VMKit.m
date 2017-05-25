//
//  NSTimer+VMKit.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/19.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "NSTimer+VMKit.h"

@implementation NSTimer(VMKit)

-(void)pauseTimer
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]];
}


-(void)resumeTimer
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}
@end
