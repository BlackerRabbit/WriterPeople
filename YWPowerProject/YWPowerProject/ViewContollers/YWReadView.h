//
//  YWReadView.h
//  YWPowerProject
//
//  Created by zhengfeng1 on 2017/6/6.
//  Copyright © 2017年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@interface YWReadView : UIView
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, assign, readwrite) CTFrameRef frameRef;
@end
