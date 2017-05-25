//
//  BezerView.m
//  Animation
//
//  Created by Angel on 15/12/8.
//  Copyright © 2015年 lq. All rights reserved.
//

#import "BezerView.h"
#define KDuration 0.5f
#define KCLEARCOLOR [UIColor clearColor];

@interface BezerView()
{
    CAShapeLayer *_shapLayer;
    short _count;
    BOOL _bool;
    BOOL _isbool;
    NSTimer * _timer;
    UIButton *_button;
    CABasicAnimation *_anim;
    CALayer *_layer;
}
@property (nonatomic, assign) float progress;
@end

@implementation BezerView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.total = 0;
    self.duration = -1;
    self.r = -1;
    self.backgroundColor = [UIColor clearColor];
    return self;
    
}
-(void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!_shapLayer) {
        // 圆圈半径
        if (self.r == -1) {
            self.r = 48;
        }
        // 画圆圈啦 还有方块信息
        double startAng = -M_PI_2;
        double endang = 3*M_PI_2;
        CGPoint o = CGPointMake(rect.size.width/2.f,rect.size.height/2.f);
        
        // 画外圈的圆，不带动画
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = self.layer.bounds;
        pathLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:pathLayer];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:o radius:2*self.r startAngle:0 endAngle:2*M_PI clockwise:YES];
        pathLayer.path = path.CGPath;
        pathLayer.lineWidth = 3;
        pathLayer.strokeColor = [UIColor whiteColor].CGColor;
        
        [[UIColor darkGrayColor] set];
        UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:o radius:self.r startAngle:startAng endAngle:endang clockwise:YES];
        bezier.lineWidth = 2*self.r;
        bezier.lineCapStyle = kCGLineCapButt;
        bezier.lineJoinStyle = kCGLineCapSquare;
        [bezier stroke];
        
        
        _shapLayer = [CAShapeLayer layer];
        _shapLayer.path = bezier.CGPath;
        _shapLayer.lineWidth = 2*self.r;
        _shapLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _shapLayer.fillColor = [UIColor clearColor].CGColor;
        _shapLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_shapLayer];
        
        if (self.total>0) {
            _count = self.total;
        }else{
            NSLog(@"总数赋值错误！");
            return;
        }
        
        //button 显示倒计时
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = self.bounds;
        
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;
        _button.titleLabel.textColor = [UIColor whiteColor];
        [_button setTitle:[NSString stringWithFormat:@"%d",_count-1] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont boldSystemFontOfSize:self.r];
        _button.backgroundColor = [UIColor clearColor];
        _button.titleLabel.center = o;
        [_button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        self.userInteractionEnabled = YES;
        
        if (self.duration==-1) {
            self.duration = 1;
        }
        [self drawLineAnimation:_shapLayer duration:self.duration];
        [self startTimer];
        
    }else{
        [self drawLineAnimation:_shapLayer duration:self.duration];
    }
}

/*
 给layer加动画的方法
 */
-(void)drawLineAnimation:(CALayer*)layer duration:(float)t
{
    _anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _anim.duration = t;
    _anim.delegate = self;
    _anim.repeatCount = self.total;
    _anim.fromValue = [NSNumber numberWithInteger:0];
    _anim.toValue = [NSNumber numberWithInteger:1];
    [layer addAnimation:_anim forKey:@"circle"];
    _layer = layer;
}

/*
 button点击事件
 */
-(void)btnClick
{
    if(!_bool)
    {
        NSLog(@"暂停");
        [self stopTimer];
        //暂停动画
         CFTimeInterval pausedTime = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
        _layer.speed = 0.0;
        _layer.timeOffset = pausedTime;
        if ([_delegate respondsToSelector:@selector(bezerViewClickStop)]) {
            [_delegate  bezerViewClickStop];
        }
    }
    else
    {
        NSLog(@"重新开始");
         [self startTimer];
        //恢复动画
        CFTimeInterval pausedTime2 = _layer.timeOffset;
        _layer.speed = 1.0;
        _layer.timeOffset = 0.0;
        _layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [_layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime2;
        _layer.beginTime = timeSincePause;
        
        if ([_delegate respondsToSelector:@selector(bezerViewClickReStart)]) {
            [_delegate bezerViewClickReStart];
        }
    }
    _bool=!_bool;
}
-(void)startTimer
{
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(changeNum) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [_timer invalidate];
}

/*
 单独写更改倒计时数字  因为动画的repeat次数获取不到
 */
- (void)changeNum{
    _progress = _progress + 0.01;
    if ((int)_progress == 1) {
        _progress = 0;
        _count --;
        if (_count == 0) {
            _progress = 1;
            [self stopTimer];
            _button.enabled = NO;
            return;
        }
        NSLog(@"第%d秒",_count);
        [_button setTitle:[NSString stringWithFormat:@"%d",_count-1] forState:UIControlStateNormal];
        if ([_delegate respondsToSelector:@selector(bezerViewPreSecondEnd)]) {
            [_delegate bezerViewPreSecondEnd];
        }
    }
}

#pragma mark - Animation delegate
- (void)animationDidStart:(CAAnimation *)anim
{
    
    if ([_delegate respondsToSelector:@selector(bezerViewAnimalStart)]) {
        [_delegate bezerViewAnimalStart];
    }
    NSLog(@"动画开始了");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([_delegate respondsToSelector:@selector(bezerViewAnimalFinish)]) {
        [_delegate bezerViewAnimalFinish];
    }
    NSLog(@"动画结束了");
}

@end
