//
//  NSMutableAttributedString+VM.h
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (VM)
- (void)setTextColor:(UIColor*)color;

- (void)setTextColor:(UIColor*)color range:(NSRange)range;

- (void)setFont:(UIFont*)font;

- (void)setFont:(UIFont*)font range:(NSRange)range;

- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier;

- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range;
@end
