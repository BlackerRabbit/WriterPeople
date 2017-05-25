//
//  VMPageControl.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/30.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMPageControl : UIControl

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, assign) BOOL hidesForSinglePage;

@property (nonatomic, strong) UIPageControl *page;


@end
