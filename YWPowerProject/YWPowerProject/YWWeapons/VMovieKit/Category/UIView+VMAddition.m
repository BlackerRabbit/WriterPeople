//
//  UIView+Addition.m
//  WXWeibo
//
//  Created by JayWon on 14-8-20.
//  Copyright (c) 2014年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import "UIView+VMAddition.h"

@implementation UIView (VMAddition)

- (UIViewController *)viewController
{
    UIResponder* next = [self nextResponder];
    while (next) {
        if([next isKindOfClass:[UIViewController class]]){
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    }
    return nil;
}

@end
