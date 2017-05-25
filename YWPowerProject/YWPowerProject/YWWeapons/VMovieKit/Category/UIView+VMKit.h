//
//  UIView+VMKit.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/4.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIView(VMKit)

@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

@property CGFloat centerX;
@property CGFloat centerY;

-(void)setCornerRadius:(CGFloat )cornerRadius;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;

/**
 *  获取到当前view的下一个响应为superClass类的view
 *
 *  @para class ,制定一个类
 */
- (UIView *)superviewWithClass:(Class)superClass;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

#pragma mark-
#pragma mark------操作性的方法------

-(UIImage*)screenShotWithRect:(CGRect)rect save:(BOOL)save;

//模糊效果
- (UIImage *)blurredImageWithRadius:(CGFloat)radius
                         iterations:(NSUInteger)iterations
                          tintColor:(UIColor *)tintColor;

-(void)removeAllSubview;

-(void)cycloView;
-(void)cycloViewWithBorderWidth:(CGFloat)width;

@end
