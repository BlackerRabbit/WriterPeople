//
//  UIImage+UIImageScale.m
//  VMovieKit
//
//  Created by Angel on 16/3/24.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "UIImage+UIImageScale.h"

@implementation UIImage (UIImageScale)
- (UIImage *)getSmallImage:(CGRect)rect
{
    CGImageRef smallImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(smallImageRef), CGImageGetHeight(smallImageRef));
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, smallImageRef);
    UIImage *smallImage = [UIImage imageWithCGImage:smallImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}
- (UIImage *)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    float verticalRadio = size.height * 1.0 / height;
    float horizontalRadio = size.width * 1.0 / width;
    float radio = 1.0;
    if (verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else{
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    width = width * radio;
    height = height * radio;
    int xPos = (size.width - width) / 2;
    int yPos = (size.height - height) / 2;
    //创建一个bitmap的context，并把它设为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    //绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    //从当前context中常见一个改变大小的图片
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
    
}
@end
