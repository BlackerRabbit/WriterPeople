//
//  UIViewController+VMKit.h
//  MagicBox
//
//  Created by 蒋正峰 on 16/7/14.
//  Copyright © 2016年 ZiLiFang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMovieKit.h"

@interface UIViewController(VMKit)
@property (nonatomic, strong, readwrite) NSString *trackName;
-(void)indentiferNavBack;
-(void)rightNavWithView:(UIView *)view;
-(void)dismissComplete;
-(void)viewControllerWilPop;

@end
