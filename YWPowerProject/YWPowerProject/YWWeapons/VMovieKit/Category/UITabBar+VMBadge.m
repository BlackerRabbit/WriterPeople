//
//  UITabBar+VMBadge.m
//  MagicBox
//
//  Created by Angel on 16/1/15.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "UITabBar+VMBadge.h"
#import "UIColor+VMColor.h"

#define TabbarItemNums 3.0

@implementation UITabBar (VMBadge)
- (void)showBadgeOnItemIndex:(int)index{
    
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 4;
    badgeView.clipsToBounds = YES;
//    [badgeView cycloViewWithBorderWidth:0];
    badgeView.backgroundColor = [UIColor colorWithHexString:@"#f85353"];
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
//    float percentX = (index +0.6) / TabbarItemNums;
    float percentX = (index +0.55) / TabbarItemNums;
    
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height) + 1;
    badgeView.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:badgeView];
    
}

- (void)hideBadgeOnItemIndex:(int)index{
    
    //移除小红点
    [self removeBadgeOnItemIndex:index];
    
}

- (void)removeBadgeOnItemIndex:(int)index{
    
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        
        if (subView.tag == 888+index) {
            
            [subView removeFromSuperview];
            
        }
    }
}

@end
