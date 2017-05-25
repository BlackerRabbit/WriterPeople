//
//  VMTimerLabel.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/12/26.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TimerLabelFinishBlock)();

@interface VMTimerLabel : UILabel
@property (nonatomic, assign) NSInteger beginNum;
@property (nonatomic, assign) NSInteger endNum;
@property (nonatomic, assign) NSInteger jumpNum;
@property (nonatomic, copy) TimerLabelFinishBlock block;

-(void)pauseTimer;
-(void)startTimer;

@end
