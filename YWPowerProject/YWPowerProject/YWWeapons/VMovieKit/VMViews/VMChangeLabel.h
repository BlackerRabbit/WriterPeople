//
//  VMChangeLabel.h
//  VMovieKit
//
//  Created by 蒋正峰 on 16/2/16.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *好吧。我也知道这个名字很诡异，change个毛线啊。只是。。timerlabel被封装成狗了。没有办法了。将就着用吧，以后有时间了在改
 */

@interface VMChangeLabel : UILabel
/**
 *需要轮播的内容，按顺序轮播
 */
@property (nonatomic, strong) NSArray *changeTextArray;

/**
 *每次轮播的间隔，默认为1秒
 */
@property (nonatomic, assign) CGFloat durations;

/**
 *是否需要重复播放，默认为yes
 */
@property (nonatomic, assign) BOOL needRepeat;

/**
 *是否开启轮播功能,如果为no的时候，则跟普通的label一样使用
 */
@property (nonatomic, assign) BOOL needChange;



@end
