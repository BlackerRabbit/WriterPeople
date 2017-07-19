//
//  YWReadView.m
//  YWPowerProject
//
//  Created by zhengfeng1 on 2017/6/6.
//  Copyright © 2017年 蒋正峰. All rights reserved.
//

#import "YWReadView.h"
#import "YWbookObject.h"

@interface YWReadView ()


@end

@implementation YWReadView

-(void)setContent:(NSString *)content{
    _content = content;
    if (content != nil && content.length > 0) {
        self.frameRef = [YWBookObject frameRefWith:content];
    }
}

-(void)setFrameRef:(CTFrameRef)frameRef{
    _frameRef = frameRef;
    if (_frameRef != nil) {
        [self setNeedsDisplay];
    }
}

-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CTFrameDraw(self.frameRef, context);
}




@end
