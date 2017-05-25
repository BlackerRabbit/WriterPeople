//
//  VMCyclesScrollview.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/19.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    VMPageControlPositionLeft,
    VMPageControlPositionRight,
    VMPageControlPositionCenter
}VMPageControlPosition;


@interface VMCyclesScrollview : UIView

@property (nonatomic , assign) NSInteger currentPageIndex;

@property (nonatomic , readonly) UIScrollView *scrollView;

/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;

/**
 数据源：获取总的page个数
 **/
@property (nonatomic , copy) NSInteger (^totalPagesCount)(void);
/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);
/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^TapActionBlock)(NSInteger pageIndex);

/**
 *  启动定时器
 */
- (void)startTimer;
/**
 *  暂定定时器
 */
- (void)pauseTimer;
///**
// *  子视图数组
// */
//@property (nonatomic , strong) NSMutableArray *contentViews;
/**
 * @param position                  UIPageControl的位置，左，右，中间
 * @param tintColor                 UIPageControl的currentPageIndicatorTintColor
 * @param pageIndicatorTintColor    UIPageControl的PageIndicatorTintColor
 */
-(void)setPageControlPosition:(VMPageControlPosition)position currentPageTintColor:(UIColor *)tintColor pageIndicatorTintColor:(UIColor *)pageIndicatorTintColor;

@property (nonatomic,assign)float pageControlBottom;

//@property (nonatomic , assign) NSInteger currentPageIndex;
//@property (nonatomic , assign) NSInteger totalPageCount;
@end
