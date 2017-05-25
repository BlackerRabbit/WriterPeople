//
//  UIViewController+VMKit.m
//  MagicBox
//
//  Created by 蒋正峰 on 16/7/14.
//  Copyright © 2016年 ZiLiFang. All rights reserved.
//

#import "UIViewController+VMKit.h"

@implementation UIViewController(VMKit)

-(void)indentiferNavBack{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"Group 4"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Group 4"] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"Group 4"] forState:UIControlStateHighlighted];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backItem;
}

-(void)backBtnClicked:(id)sender{
    
    if (self.navigationController.viewControllers.count > 1) {
        [self viewControllerWilPop];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        WEAKSELF
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [weakSelf dismissComplete];
        }];
    }
}

-(void)rightNavWithView:(UIView *)view{
    UIBarButtonItem *rightView = [[UIBarButtonItem alloc]initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = rightView;
}

-(void)dismissComplete{

}

-(void)viewControllerWilPop{

}

@end
