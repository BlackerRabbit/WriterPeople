//
//  UIView+VMKit.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/4.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "UIView+VMKit.h"

@implementation UIView(VMKit)

- (CGPoint) origin
{
    return self.frame.origin;
}

- (void) setOrigin: (CGPoint) aPoint
{
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}


// Retrieve and set the size
- (CGSize) size
{
    return self.frame.size;
}

- (void) setSize: (CGSize) aSize
{
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

// Query other frame locations
- (CGPoint) bottomRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) bottomLeft
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint) topRight
{
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}


// Retrieve and set height, width, top, bottom, left, right
- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setHeight: (CGFloat) newheight
{
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (void) setWidth: (CGFloat) newwidth
{
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat) top
{
    return self.frame.origin.y;
}

- (void) setTop: (CGFloat) newtop
{
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}

- (CGFloat) left
{
    return self.frame.origin.x;
}

- (void) setLeft: (CGFloat) newleft
{
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (CGFloat) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void) setBottom: (CGFloat) newbottom
{
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat) right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void) setRight: (CGFloat) newright
{
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

-(void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

-(CGFloat)centerX
{
    return self.center.x;
}

-(void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

-(CGFloat)centerY
{
    return self.center.y;
}

-(void)setCornerRadius:(CGFloat )cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.masksToBounds = YES;
    //    if ([UIScreen mainScreen].bounds.size.height>500) {
    //        cornerRadius = cornerRadius * [UIScreen mainScreen].bounds.size.height / 568;
    //    }
    self.layer.cornerRadius = cornerRadius;
}

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

/**
 *  获取到当前view的下一个响应为superClass类的view
 *
 *  @para class ,制定一个类
 */
- (UIView *)superviewWithClass:(Class)superClass
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[superClass class]]) {
            return (UIView*)nextResponder;
        }
    }
    return nil;
}

// Move via offset
- (void) moveBy: (CGPoint) delta
{
    CGPoint newcenter = self.center;
    newcenter.x += delta.x;
    newcenter.y += delta.y;
    self.center = newcenter;
}

// Scaling
- (void) scaleBy: (CGFloat) scaleFactor
{
    CGRect newframe = self.frame;
    newframe.size.width *= scaleFactor;
    newframe.size.height *= scaleFactor;
    self.frame = newframe;
}

// Ensure that both dimensions fit within the given size by scaling down
- (void) fitInSize: (CGSize) aSize
{
    CGFloat scale;
    CGRect newframe = self.frame;
    
    if (newframe.size.height && (newframe.size.height > aSize.height))
    {
        scale = aSize.height / newframe.size.height;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    if (newframe.size.width && (newframe.size.width >= aSize.width))
    {
        scale = aSize.width / newframe.size.width;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    self.frame = newframe;
}

#pragma mark-
#pragma mark------actions------

-(UIImage*)screenShotWithRect:(CGRect)rect save:(BOOL)save
{
    if (NULL != &UIGraphicsBeginImageContextWithOptions)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(rect);
    [self.layer renderInContext:context];
    UIImage *  theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(save)
    {
        UIImageWriteToSavedPhotosAlbum(theImage, nil, nil,nil);
        
    }
    return  theImage;
}

-(void)removeAllSubview{
    NSSet *set = [NSSet setWithArray:[self subviews]];
    for (UIView *subView in set) {
        [subView removeFromSuperview];
    }
}

-(void)cycloView{
    
    self.layer.borderWidth = 2.5;
    self.layer.cornerRadius = CGRectGetHeight([self bounds]) / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.opaque = NO;
}

-(void)cycloViewWithBorderWidth:(CGFloat)width{
    
    self.layer.borderWidth = width;
    self.layer.cornerRadius = CGRectGetHeight([self bounds]) / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.opaque = NO;
}




@end
