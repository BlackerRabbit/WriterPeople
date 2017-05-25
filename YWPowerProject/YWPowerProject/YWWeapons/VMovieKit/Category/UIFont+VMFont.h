//
//  UIFont+VMFont.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/18.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIFont(VMFont)
+ (UIFont *)getFZLanTingHeiFont:(float)fontSize;
+ (UIFont *)getHeitiSCFont:(float)fontSize;
+ (UIFont *)getHeitiSCBoldFont:(float)fontSize;
+ (UIFont *)getHiraKakuBlodFont:(float)fontSize;
+ (UIFont *)getHelveticaNeueFont:(float)fontSize;
+ (UIFont *)getHelveticaNeueBoldFont:(float)fontSize;
+ (UIFont *)getCalibriFont:(float)fontSize;
//使用娃娃字体
+ (UIFont *)customFontWithSize:(CGFloat)size;

//使用思源bold
+(UIFont *)getBoldSansFont:(float)fontSize;
+(UIFont *)getRegularSansFont:(float)fontSize;
@end
