//
//  UIImage+UIImageScale.h
//  VMovieKit
//
//  Created by Angel on 16/3/24.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageScale)
//裁剪图片
- (UIImage *)getSmallImage:(CGRect)rect;
//缩放图片
- (UIImage *)scaleToSize:(CGSize)size;
@end
