//
//  YWCommonDefine.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define WHITE   [UIColor whiteColor]
#define BLUE    [UIColor blueColor]
#define BLACK   [UIColor blackColor]
#define RED     [UIColor redColor]
#define YELLOW  [UIColor yellowColor]
#define GREEN   [UIColor greenColor]

#define COLOR(R,G,B) [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:1]
#define COLORA(R,G,B,A) [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height



#define FONT(SIZE) [UIFont fon]

void variableInitialize(void);

extern BOOL SW_IS_5_5INCH_SCREEN;
extern BOOL SW_IS_4_7INCH_SCREEN;
extern BOOL SW_IS_4INCH_SCREEN;
extern BOOL SW_IS_3_5INCH_SCREEN;
extern CGFloat SW_UI_1PX;
extern CGFloat SW_SCREEN_SCALE;
CGFloat FLOAT_DEPEND_SCREEN(CGFloat inch35, CGFloat inch40, CGFloat inch47, CGFloat inch55);

