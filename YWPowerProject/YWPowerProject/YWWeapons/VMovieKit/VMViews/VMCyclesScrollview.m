//
//  VMCyclesScrollview.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/19.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMCyclesScrollview.h"
#import "NSTimer+VMKit.h"
#import "UIColor+VMColor.h"
@interface VMBasePageControl :UIPageControl
@end
@implementation VMBasePageControl

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        self.hidesForSinglePage = YES;
        self.userInteractionEnabled = NO;
        self.numberOfPages = 3;
        self.currentPage = 0;
    }
    return self;
}
@end


@interface VMCyclesScrollview ()<UIScrollViewDelegate>
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic , strong) NSTimer *animationTimer;
@property (nonatomic , assign) NSTimeInterval animationDuration;
@property (nonatomic, strong)  VMBasePageControl *pageControl;
@end


@implementation VMCyclesScrollview
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    self.pageControl.currentPage = _currentPageIndex;
}
- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    _totalPageCount = totalPagesCount();
    _pageControl.numberOfPages = totalPagesCount();
    if (_totalPageCount > 0) {
        [self configContentViews];
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
        [_pageControl setHidden:NO];
        if (_totalPageCount < 2) {
//            [_pageControl removeFromSuperview];
            [_pageControl setHidden:YES];
        }
    }
}

- (void)startTimer
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    
}

- (void)pauseTimer
{
    [self.animationTimer pauseTimer];
    
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.animationTimer pauseTimer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        self.currentPageIndex = 0;
        
        self.pageControl = [[VMBasePageControl alloc]initWithFrame:CGRectMake(self.frame.size.width - 45, self.frame.size.height - 20, 40, 20)];
        
        if ([self.pageControl respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)]) {
            UIColor *tintColor = [UIColor whiteColor];
            [self.pageControl setCurrentPageIndicatorTintColor:[tintColor colorWithAlphaComponent:0.6]];
            
            UIColor *pageIndicatorColor = [UIColor colorWithRed:255/255.0f green:190/255.f blue:146/255.0f alpha:.6f];
            [self.pageControl setPageIndicatorTintColor:pageIndicatorColor];
//            [self.pageControl setPageIndicatorTintColor: rgb(255, 190, 146, .6f)];
        }
        _pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:self.pageControl];
        self.pageControl.enabled = NO;
        self.pageControl.currentPage = self.currentPageIndex;
        self.pageControl.transform = CGAffineTransformMakeScale(.8f, .8f);
        //        CGAffineTransformScale(transform, -1.0, 1.0);
        //        是缩放的。
    }
    return self;
}
#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    //后续需要重新修改逻辑
//    if (self.contentViews.count == self.totalPageCount) {
//        self.scrollView.contentInset = rearPageIndex % 3;
//        return;
//    }
    [self.contentViews removeAllObjects];
    self.contentViews = nil;
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }

    if (self.fetchContentViewAtIndex) {
        [self.contentViews addObject:self.fetchContentViewAtIndex(previousPageIndex)];
        [self.contentViews addObject:self.fetchContentViewAtIndex(_currentPageIndex)];
        [self.contentViews addObject:self.fetchContentViewAtIndex(rearPageIndex)];
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int contentOffsetX = scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        _pageControl.currentPage = self.currentPageIndex;
        [self configContentViews];
    }
    if(contentOffsetX <= 0)
    {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        _pageControl.currentPage = self.currentPageIndex;
        [self configContentViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _pageControl.currentPage = self.currentPageIndex;
}
#pragma mark -
#pragma mark - 响应事件

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGFloat offSetIndex = ceil(self.scrollView.contentOffset.x/CGRectGetWidth(self.scrollView.frame));
    CGFloat oldOffSetX = offSetIndex*CGRectGetWidth(self.scrollView.frame);
//    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), 0);//已摒弃,计算方法有问题
    CGPoint newOffset = CGPointMake(oldOffSetX + CGRectGetWidth(self.scrollView.frame), 0);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

/**
 * @param position                  UIPageControl的位置，左，右，中间
 * @param tintColor                 UIPageControl的currentPageIndicatorTintColor
 * @param pageIndicatorTintColor    UIPageControl的PageIndicatorTintColor
 */
-(void)setPageControlPosition:(VMPageControlPosition)position currentPageTintColor:(UIColor *)tintColor pageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
{
    CGRect frame = self.pageControl.frame;
    if (position == VMPageControlPositionLeft)
    {
        frame.origin.x = 45;
        self.pageControl.frame = frame;
    }
    if (position == VMPageControlPositionRight)
    {
        frame.origin.x = self.frame.size.width - 45;
        self.pageControl.frame = frame;
    }
    if (position == VMPageControlPositionCenter)
    {
        self.pageControl.center = CGPointMake(self.center.x, self.pageControl.center.y);
    }
    
    self.pageControl.currentPageIndicatorTintColor = tintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}
-(void)setPageControlBottom:(float)pageControlBottom
{
    CGRect newframe = self.pageControl.frame;
    newframe.origin.y = pageControlBottom - newframe.size.height;
    self.pageControl.frame = newframe;
}
-(float)pageControlBottom
{
    return self.pageControl.frame.origin.y + self.pageControl.frame.size.height;
}

@end
