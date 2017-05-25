//
//  UITabBar+VMBadge.h
//  MagicBox
//
//  Created by Angel on 16/1/15.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (VMBadge)
- (void)showBadgeOnItemIndex:(int)index;   //显示小红点
- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点
@end
