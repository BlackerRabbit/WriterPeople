//
//  VMTimerLabel.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/12/26.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMTimerLabel.h"
#import "NSTimer+VMKit.h"
@interface VMTimerLabel ()
@property (nonatomic, strong) NSTimer *currentTimer;
@property (nonatomic, assign) NSInteger countTime;
@end

@implementation VMTimerLabel

-(void)dealloc{
    
    [self unregisterKVOObserver];
    [self.currentTimer invalidate];
    self.currentTimer = nil;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerLabelCount:) userInfo:nil repeats:YES];
        self.currentTimer = timer;
        [self.currentTimer pauseTimer];
        [self.currentTimer resumeTimerAfterTimeInterval:.1];
        [[NSRunLoop currentRunLoop]addTimer:self.currentTimer forMode:NSRunLoopCommonModes];
        self.beginNum = 10;
        self.endNum = 0;
        self.jumpNum = 1;
        self.countTime = self.beginNum;
        
        self.font = [UIFont boldSystemFontOfSize:40];
        [self registerKOVObserver];
        
        return self;
    }
    return nil;
}


-(void)pauseTimer{
    [self.currentTimer pauseTimer];
}

-(void)startTimer{
    [self.currentTimer resumeTimer];
}

-(void)timerLabelCount:(NSTimer *)timer{
    
    if (self.beginNum > self.endNum) {
        self.countTime -= self.jumpNum;
        if (self.countTime < self.endNum) {
            self.text = [NSString stringWithFormat:@"%ld",(long)self.endNum];
            [self.currentTimer invalidate];
            self.currentTimer = nil;
            
            if (self.block) {
                self.block();
            }
            return;
        }
    }else if (self.beginNum < self.endNum){
        self.countTime += self.jumpNum;
        if (self.countTime > self.endNum) {
            self.text = [NSString stringWithFormat:@"%ld",(long)self.endNum];
            [self.currentTimer invalidate];
            self.currentTimer = nil;
            
            
            if (self.block) {
                self.block();
            }
            return;
        }
    }else{
        [self.currentTimer invalidate];
        self.currentTimer = nil;
        if (self.block) {
            self.block();
        }
        
    }
    self.text = [NSString stringWithFormat:@"%ld",(long)self.countTime];
}

-(void)resetTimerAndCount{
    if (self.currentTimer) {
        [self.currentTimer pauseTimer];
    }
    self.countTime = self.beginNum;
    [self.currentTimer resumeTimerAfterTimeInterval:.1];
}

#pragma mark-
#pragma mark------kvos------

-(void)registerKOVObserver{
    for (NSString *keyPath in [self KVOKeypathsArray]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:@"VMTimerLabel"];
    }
}

-(NSArray *)KVOKeypathsArray{
    return @[@"beginNum",@"endNum",@"jumpNum",@"extraInfo"];
}

-(void)unregisterKVOObserver{
    for (NSString *keyPath in [self KVOKeypathsArray]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (context == @"VMTimerLabel") {
        if ([keyPath isEqualToString:@"beginNum"] || [keyPath isEqualToString:@"endNum"] || [keyPath isEqualToString:@"jumpNum"] || [keyPath isEqualToString:@"extraInfo"]) {
            [self resetTimerAndCount];
        }
    }
}






@end
