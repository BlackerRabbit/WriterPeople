//
//  VMChangeLabel.m
//  VMovieKit
//
//  Created by 蒋正峰 on 16/2/16.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "VMChangeLabel.h"
#import "NSTimer+VMKit.h"

#define DefaultDuration 1

@interface VMChangeLabel ()
@property (nonatomic, strong) NSTimer *changeTimer;
@property (nonatomic, assign) NSInteger currentIndex;
@end


@implementation VMChangeLabel

-(void)dealloc{
    [self.changeTimer invalidate];
    self.changeTimer = nil;
}

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentIndex = 0;
        self.durations = DefaultDuration;
        self.needChange = YES;
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.durations target:self selector:@selector(timerLabelCount:) userInfo:nil repeats:YES];
        self.changeTimer = timer;
        [self.changeTimer pauseTimer];
        [self.changeTimer resumeTimerAfterTimeInterval:.1];
        [[NSRunLoop currentRunLoop]addTimer:self.changeTimer forMode:NSRunLoopCommonModes];
        
        self.needRepeat = YES;
        return self;
    }
    return nil;
}

-(void)setChangeTextArray:(NSArray *)changeTextArray{

    if (changeTextArray == nil || changeTextArray.count == 0) {
        return;
    }
    _changeTextArray = [changeTextArray copy];
    [self setNeedsDisplay];
}

-(void)setNeedRepeat:(BOOL)needRepeat{
    if (needRepeat == _needRepeat) {
        return;
    }
    _needRepeat = needRepeat;
    [self.changeTimer invalidate];
    self.changeTimer = nil;
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.durations target:self selector:@selector(timerLabelCount:) userInfo:nil repeats:YES];
    self.changeTimer = timer;
    [[NSRunLoop currentRunLoop]addTimer:self.changeTimer forMode:NSRunLoopCommonModes];
    [self.changeTimer pauseTimer];
    [self.changeTimer resumeTimerAfterTimeInterval:.1];
}

-(void)setDurations:(CGFloat)durations{
    if (durations != DefaultDuration) {
        _durations = durations;
        [self.changeTimer invalidate];
        self.changeTimer = nil;
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.durations target:self selector:@selector(timerLabelCount:) userInfo:nil repeats:YES];
        self.changeTimer = timer;
        [[NSRunLoop currentRunLoop]addTimer:self.changeTimer forMode:NSRunLoopCommonModes];
        [self.changeTimer pauseTimer];
        [self.changeTimer resumeTimerAfterTimeInterval:.1];
    }

}

-(void)setNeedChange:(BOOL)needChange{
    _needChange = needChange;
    if (_needChange == NO) {
        [self.changeTimer pauseTimer];
    }else{
        [self.changeTimer resumeTimer];
    }
}

-(void)timerLabelCount:(NSTimer *)timer{
    if (self.changeTextArray == nil || self.changeTextArray.count == 0 ) {
        return;
    }
    if (self.currentIndex >= self.changeTextArray.count) {
        self.currentIndex = 0;
        if (self.needRepeat == NO) {
            [timer invalidate];
            return;
        }
    }
    self.text = self.changeTextArray[self.currentIndex];
    self.currentIndex ++;
}



@end
