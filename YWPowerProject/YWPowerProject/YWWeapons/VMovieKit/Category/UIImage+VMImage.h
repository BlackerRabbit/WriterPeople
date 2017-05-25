//
//  UIImage+VMImage.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/18.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import "NSData+VMKit.h"


@interface UIImage(VMImage)
+(UIImage*)imageNamed:(NSString *)name withBundleName:(NSString*)bundleName;
-(NSString *)base64String;
- (UIImage*)transformWidth:(CGFloat)width
                    height:(CGFloat)height;

//毛玻璃效果
-(UIImage *)blurredImageWithRadius:(CGFloat)radius
                        iterations:(NSUInteger)iterations
                         tintColor:(UIColor *)tintColor;

/**同步方法
 */
+(UIImage *)imageWithURL:(NSString *)url timeOut:(NSInteger)timeOut;
+(UIImage *)imageWithURL:(NSString *)url inDocumentFolder:(NSString *)folder;
+(UIImage *)imageWithURL:(NSString *)url inDocumentFolder:(NSString *)folder autoDownload:(BOOL)download;


- (UIImage *) imageWithTintColor:(UIColor *)tintColor;

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

+ (UIImage *)changeWhiteColorTransparent: (UIImage *)image;




/**
 *给uiimage添加一个颜色萌层
 */
+ (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color ;

+(UIImage *)imageWithBGColor:(UIColor *)bgColor image:(UIImage *)img;
@end
