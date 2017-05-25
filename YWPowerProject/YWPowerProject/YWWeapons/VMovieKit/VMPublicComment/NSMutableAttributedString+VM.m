//
//  NSMutableAttributedString+VM.m
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import "NSMutableAttributedString+VM.h"

@implementation NSMutableAttributedString (VM)

- (void)setTextColor:(UIColor*)color
{
    [self setTextColor:color range:NSMakeRange(0, [self length])];
}

- (void)setTextColor:(UIColor*)color range:(NSRange)range
{
    if (color.CGColor)
    {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
    
}


- (void)setFont:(UIFont*)font
{
    [self setFont:font range:NSMakeRange(0, [self length])];
}

- (void)setFont:(UIFont*)font range:(NSRange)range
{
    if (font)
    {
        [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (nil != fontRef)
        {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
{
    [self setUnderlineStyle:style
                   modifier:modifier
                      range:NSMakeRange(0, self.length)];
}

- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range
{
    [self removeAttribute:(NSString *)kCTUnderlineColorAttributeName range:range];
    [self addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                 value:[NSNumber numberWithInt:(style|modifier)]
                 range:range];
    
}
@end
