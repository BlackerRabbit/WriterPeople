//
//  YWBookListCell.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "YWBookListCell.h"
#import "YWBookObject.h"
#import "VMovieKit.h"

@implementation YWBookListCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.coverImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.desLabel];
        [self addSubview:self.authorLabel];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)loadData:(YWBookObject *)book{
    if (book == nil) {
        return;
    }
    
    UIImage *image = [UIImage imageNamed:book.bookCoverImg];
    self.titleLabel.text = book.bookTitle;
    self.desLabel.text = book.bookDes;
    
    NSString *authorString = [NSString stringWithFormat:@"%@    总字数：%lu",book.authorName, (unsigned long)book.bookLength];
    
    self.authorLabel.text = authorString;
    
    
    
    
}

#pragma mark - lazy actions ------

-(UIImageView *)coverImageView{
    
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _coverImageView.layer.cornerRadius = 4.f;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

-(UILabel *)desLabel{
    if (_desLabel == nil) {
        _desLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _desLabel.backgroundColor = WHITE;
        _desLabel.font = [UIFont systemFontOfSize:13];
        _desLabel.textColor = COLOR(60, 60, 60);
        _desLabel.numberOfLines = 2;
    }
    return _desLabel;
}

-(UILabel *)authorLabel{
    if (_authorLabel == nil) {
        _authorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _authorLabel.backgroundColor = WHITE;
        _authorLabel.font = [UIFont systemFontOfSize:10];
        _authorLabel.textColor = COLOR(70, 70, 70);
        _authorLabel.numberOfLines = 2;
    }
    return _authorLabel;
}


-(UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = WHITE;
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = COLOR(70, 70, 70);
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}






@end
