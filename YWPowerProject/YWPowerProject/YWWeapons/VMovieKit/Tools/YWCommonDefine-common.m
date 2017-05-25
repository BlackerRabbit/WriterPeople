//
//  NSObject_YWCommonDefine.h
//  YWPowerProject
//
//  Created by zhengfeng1 on 2017/3/17.
//  Copyright © 2017年 蒋正峰. All rights reserved.
//


#import "YWCommonDefine.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


BOOL SW_IS_5_5INCH_SCREEN;
BOOL SW_IS_4_7INCH_SCREEN;
BOOL SW_IS_4INCH_SCREEN;
BOOL SW_IS_3_5INCH_SCREEN;

CGFloat SW_OS_VERSION;

CGFloat SW_SCREEN_SCALE;
CGFloat SW_UI_1PX;

void variableInitialize(void)
{
    //里面部分变量如果在initialize中调用会不准，例如iOS 8上的[UIScreen mainScreen].scale
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    SW_IS_5_5INCH_SCREEN=screenBounds.size.height==736.0?YES:NO;
    SW_IS_4_7INCH_SCREEN=screenBounds.size.height==667.0?YES:NO;
    SW_IS_4INCH_SCREEN=screenBounds.size.height==568.0?YES:NO;
    SW_IS_3_5INCH_SCREEN=screenBounds.size.height==480.0?YES:NO;
    SW_OS_VERSION=[[[UIDevice currentDevice] systemVersion] floatValue];
    SW_SCREEN_SCALE=[[UIScreen mainScreen] scale];
    SW_UI_1PX=1.f/[UIScreen mainScreen].scale;
    /*
     if (SW_OS_VERSION >= 9) {
     SWLifeFeedFontName = @"PingFangSC-Regular";
     }
     else {
     SWLifeFeedFontName = @"STHeitiSC-Light";
     }
     */
}


CGFloat FLOAT_DEPEND_SCREEN(CGFloat inch35, CGFloat inch40, CGFloat inch47, CGFloat inch55)
{
    if (SW_IS_3_5INCH_SCREEN) {
        return inch35;
    }
    if (SW_IS_4INCH_SCREEN) {
        return inch40;
    }
    if (SW_IS_4_7INCH_SCREEN) {
        return inch47;
    }
    if (SW_IS_4INCH_SCREEN) {
        return inch55;
    }
    return inch55;
}
