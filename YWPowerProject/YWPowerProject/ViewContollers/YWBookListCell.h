//
//  YWBookListCell.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWBookListCell : UITableViewCell

@property (nonatomic, strong, readwrite) UIImageView *coverImageView;
@property (nonatomic, strong, readwrite) UILabel *authorLabel;
@property (nonatomic, strong, readwrite) UILabel *desLabel;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@end
