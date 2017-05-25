//
//  UIFont+VMFont.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/18.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "UIFont+VMFont.h"
#import <CoreText/CoreText.h>

@implementation UIFont(VMFont)

+(UIFont *)getFZLanTingHeiFont:(float)fontSize{
    return [UIFont fontWithName:@"FZLanTingHei-EL-GBK"
                           size:fontSize];
}

+ (UIFont *)getHeitiSCFont:(float)fontSize {
    return [UIFont fontWithName:@"STHeitiSC-Light"
                           size:fontSize];
}

+ (UIFont *)getHeitiSCBoldFont:(float)fontSize {
    return [UIFont fontWithName:@"STHeitiSC-Medium"
                           size:fontSize];
}

+ (UIFont *)getHiraKakuBlodFont:(float)fontSize {
    return [UIFont fontWithName:@"HiraKakuProN-W6"
                           size:fontSize];
}

+ (UIFont *)getHelveticaNeueFont:(float)fontSize {
    return [UIFont fontWithName:@"HelveticaNeue"
                           size:fontSize];
}

+ (UIFont *)getHelveticaNeueBoldFont:(float)fontSize {
    return [UIFont fontWithName:@"HelveticaNeue-Bold"
                           size:fontSize];
}

+ (UIFont *)getCalibriFont:(float)fontSize{
    return [UIFont fontWithName:@"calibri"
                           size:fontSize];
}

+ (UIFont*)customFontWithSize:(CGFloat)size{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"华康娃娃体W5" ofType:@"TTF"];
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}

+(UIFont *)getBoldSansFont:(float)fontSize{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"NotoSans-Bold" ofType:@"ttf"];
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    CGFontRelease(fontRef);
    return font;
}

+(UIFont *)getRegularSansFont:(float)fontSize{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"NotoSans-Regular" ofType:@"ttf"];
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    CGFontRelease(fontRef);
    return font;
}

@end
