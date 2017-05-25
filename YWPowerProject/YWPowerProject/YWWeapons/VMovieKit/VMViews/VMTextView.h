//
//  VMTextView.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/27.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor  *placeholderColor;
@property (nonatomic, strong) UIFont   *placeholderFont;
@property (nonatomic, assign) CGPoint  placeholderPoint;

@end
