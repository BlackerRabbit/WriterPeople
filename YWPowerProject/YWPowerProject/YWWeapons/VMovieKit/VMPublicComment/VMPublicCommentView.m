//
//  VMPublicCommentView.m
//  VMComment
//
//  Created by 吴宇 on 15/11/9.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import "VMPublicCommentView.h"
#import "UIView+VMKit.h"

#define UICOLOR_RGB_Alpha(_color,_alpha) [UIColor colorWithRed:((_color>>16)&0xff)/255.0f green:((_color>>8)&0xff)/255.0f blue:(_color&0xff)/255.0f alpha:_alpha]

#define CurrentScreenWidth  [UIScreen mainScreen].bounds.size.width
#define CurrentScreenHeight [UIScreen mainScreen].bounds.size.height

#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?(CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
//
#define UserNickNameFontSize       12.0         //用户名字体
#define UserNickNameFontSizePlus   13.0         //用户名字体6p
#define UserNickNameTop            17.0         //用户名的top（MinY）,旧版的是10

#define CommentFontSize            14.0         //评论字体
#define CommentFontSizePlus        16.0         //评论字体

#define CommentTimeFontSize        10.0         //时间字体
#define CommentTimeToBottomInteval 13.0         //评论时间距离底部的间隔，旧版的是10.0
#define CommentPraiseFontSize      10.0         //点赞数量字体

#define MessageTitleFontSize   13.0         //消息标题字体
#define MessageNewFontSize     13.0         //新消息字体
#define MessageOldFontSize     11.0         //用户评论字体
#define MessageSourceFontSize  11.0         //消息来源字体

//新增的宏定义 #define FACE_ICON_SIZE  70
#define FACE_ICON_SIZE  70

@interface VMPublicCommentView ()
{
    //详情评论界面
    CGFloat commentHeight;              //评论图文高度
    CGFloat viewHeight;                 //控件高度
    
    
    //消息界面需要
    CGFloat replyNameWidth;             //回复用户名字宽度
    CGFloat messageTypeWidth;           //消息状态宽度
    CGFloat timeWidth;                  //时间宽度
    CGFloat oldMessageHeight;           //用户评论高度
    CGFloat newMessageHeight;           //新消息评论高度
    
    
    
    UIImageView *line;                  //底部直线
    
    UIImageView *messageBg;             //用户评论背景
    
    UIButton * _bigPraiseBtn;           //大的点赞按钮
    
    UIButton * _bigCommentCountBtn;     //大的查看更多评论按钮
}

@end

@implementation VMPublicCommentView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initCommentWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommentData];
        
        [self createCommentView];
    }
    return self;
}

- (instancetype)initMessageWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommentData];
        
        [self createMseeageView];
    }
    return self;
}

-(void)initCommentData
{
    /*
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/0.png"   forKey:@"[啪啪啪]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/1.png"   forKey:@"[怪我咯]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/2.png"   forKey:@"[MOTHERFUKER]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/3.png"   forKey:@"[隔壁老王干的]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/4.png"   forKey:@"[为了爱与和平]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/5.png"   forKey:@"[不给红包删你好友哦]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/6.png"   forKey:@"[谢谢老板]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/7.png"   forKey:@"[无知的人类]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/8.png"   forKey:@"[请用钱践踏我的自尊]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/9.png"   forKey:@"[跪下]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/10.png"  forKey:@"[约吗]"];
     [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/11.png"  forKey:@"[不约]"];
     */
    self.faceDic = [NSMutableDictionary dictionary];
    
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/0.png"   forKey:@"[啪啪啪]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/1.png"   forKey:@"[怪我咯]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/2.png"   forKey:@"[MOTHERFUKER]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/3.png"   forKey:@"[隔壁老王干的]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/4.png"   forKey:@"[为了爱与和平]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/5.png"   forKey:@"[不给红包删你好友哦]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/6.png"   forKey:@"[谢谢老板]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/7.png"   forKey:@"[无知的人类]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/8.png"   forKey:@"[请用钱践踏我的自尊]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/9.png"   forKey:@"[跪下]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/10.png"  forKey:@"[约吗]"];
    [self.faceDic setObject:@"http://cs.vmovier.com/magic/mxingren/11.png"  forKey:@"[不约]"];

    id keyBoardDict = [[NSUserDefaults standardUserDefaults]objectForKey:@"EmotionKeyboard"];
    if (keyBoardDict) {
        if ([keyBoardDict isKindOfClass:[NSDictionary class]]) {
            NSArray * emotionArr = keyBoardDict[@"data"];
            //移除所有字典
            [self.faceDic removeAllObjects];
            NSMutableArray * txtArray = [NSMutableArray array];
            for (NSDictionary * subDict in emotionArr) {
                if ([subDict[@"is_show"] integerValue] == 1) {
                    NSString * text = [NSString stringWithFormat:@"[%@]",subDict[@"txt"]];
                    [txtArray addObject:text];
                    [self.faceDic setObject:subDict[@"url"] forKey:text];
                }
            }
        }
    }
}

- (void)createCommentView
{
    //用户头像
    _userHeadImag = [[UIImageView alloc] initWithFrame:CGRectZero];
    _userHeadImag.backgroundColor = [UIColor clearColor];
    _userHeadImag.image = [UIImage imageNamed:@"avatar.png"];
    _userHeadImag.userInteractionEnabled = YES;
    _userHeadImag.layer.masksToBounds = YES;
    _userHeadImag.layer.cornerRadius = 17.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userHeadClicked)];
    [_userHeadImag addGestureRecognizer:tap];
    [self addSubview:_userHeadImag];
    
    
    //用户昵称
    _userNickname = [[UILabel alloc] initWithFrame:CGRectZero];
    _userNickname.backgroundColor = [UIColor clearColor];
    _userNickname.textColor = UICOLOR_RGB_Alpha(0x888888, 1.0);
    _userNickname.textAlignment = NSTextAlignmentLeft;
    _userNickname.font = [UIFont systemFontOfSize:UserNickNameFontSize];
    if (iPhone6plus) {
        _userNickname.font = [UIFont systemFontOfSize:UserNickNameFontSizePlus];
    }
    _userNickname.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_userNickname];
    
    //评论时间
    _commentTime = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentTime.backgroundColor = [UIColor clearColor];
    _commentTime.font = [UIFont systemFontOfSize:CommentTimeFontSize];
    _commentTime.textAlignment = NSTextAlignmentLeft;
    _commentTime.textColor = UICOLOR_RGB_Alpha(0x888888, 1.0);
    [self addSubview:_commentTime];
    
    _praiseLab = [[UILabel alloc] initWithFrame:CGRectZero];
    _praiseLab.backgroundColor = [UIColor clearColor];
    _praiseLab.font = [UIFont systemFontOfSize:CommentPraiseFontSize];
    _praiseLab.textAlignment = NSTextAlignmentLeft;
    _praiseLab.textColor = UICOLOR_RGB_Alpha(0x888888, 1.0);
    [self addSubview:_praiseLab];
    
    //评论点赞按钮
    _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_praiseBtn setImage:[UIImage imageNamed:@"avatar"] forState:UIControlStateNormal];
    [_praiseBtn addTarget:self action:@selector(praiseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_praiseBtn];
    
    _bigPraiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bigPraiseBtn.frame = CGRectMake(0, 0, 42, 34);
    _bigPraiseBtn.backgroundColor = [UIColor clearColor];
    [_bigPraiseBtn addTarget:self action:@selector(praiseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_bigPraiseBtn];
    
    //评论内容
    _commentView = [[VMAttributedLabel alloc] initWithFrame:CGRectZero];
    _commentView.backgroundColor = [UIColor clearColor];
    _commentView.textAlignment = kCTTextAlignmentLeft;
    _commentView.font = [UIFont systemFontOfSize:CommentFontSize];
    if (iPhone6plus) {
        _commentView.font = [UIFont systemFontOfSize:CommentFontSizePlus];
    }
    _commentView.lineSpacing = 3;
    _commentView.textColor = UICOLOR_RGB_Alpha(0x333333, 1.0);
    [self addSubview:_commentView];
    
    //更多评论按钮
    _commentMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_commentMoreBtn addTarget:self action:@selector(commentMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commentMoreBtn];
    
    line = [[UIImageView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.08];
    [self addSubview:line];
    
    
    _commentCountLabel = [[UILabel alloc]init];
    _commentCountLabel.font = self.praiseLab.font;
    _commentCountLabel.textColor = self.praiseLab.textColor;
    [self addSubview:_commentCountLabel];
    
    _commentCountImgView = [[UIImageView alloc]init];
//    _commentCountImgView.image = [UIImage imageNamed:@"details_appreciated_press"];
    [_commentCountImgView sizeToFit];
    [self addSubview:_commentCountImgView];
    
//    _bigCommentCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _bigCommentCountBtn.frame = CGRectMake(0, 0, 42, 34);
//    _bigCommentCountBtn.backgroundColor = [UIColor blueColor];
//    [_bigCommentCountBtn addTarget:self action:@selector(commentMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_bigCommentCountBtn];
    
    _showMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _showMoreBtn.frame = CGRectZero;
    [_showMoreBtn addTarget:self action:@selector(commentMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_showMoreBtn];
    
}



//创建消息提醒点赞界面
- (void)createMseeageView
{
    //用户头像
    _userHeadImag = [[UIImageView alloc] initWithFrame:CGRectZero];
    _userHeadImag.backgroundColor = [UIColor clearColor];
    _userHeadImag.image = [UIImage imageNamed:@"avatar.png"];
    _userHeadImag.userInteractionEnabled = YES;
    _userHeadImag.layer.masksToBounds = YES;
    _userHeadImag.layer.cornerRadius = 17.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userHeadClicked)];
    [_userHeadImag addGestureRecognizer:tap];
    [self addSubview:_userHeadImag];
    
    //用户昵称
    _userNickname = [[UILabel alloc] initWithFrame:CGRectZero];
    _userNickname.backgroundColor = [UIColor clearColor];
    _userNickname.textColor = UICOLOR_RGB_Alpha(0x888888, 1.0);
    _userNickname.textAlignment = NSTextAlignmentLeft;
    _userNickname.font = [UIFont systemFontOfSize:MessageTitleFontSize];
    _userNickname.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_userNickname];
    
    //消息类型
    _messageTypeLab = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageTypeLab.backgroundColor = [UIColor clearColor];
    _messageTypeLab.textColor = UICOLOR_RGB_Alpha(0x666666, 1.0);
    _messageTypeLab.textAlignment = NSTextAlignmentLeft;
    _messageTypeLab.font = [UIFont systemFontOfSize:MessageTitleFontSize];
    [self addSubview:_messageTypeLab];
    
    //用户评论内容
    _messageCommentLab = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageCommentLab.backgroundColor = [UIColor clearColor];
    _messageCommentLab.textAlignment = NSTextAlignmentLeft;
    _messageCommentLab.font = [UIFont systemFontOfSize:MessageOldFontSize];
    _messageCommentLab.numberOfLines = 0;
    _messageCommentLab.textColor = UICOLOR_RGB_Alpha(0x333333, 1.0);
    
    messageBg = [[UIImageView alloc] initWithFrame:CGRectZero];
    messageBg.backgroundColor = [UIColor blueColor];
    [messageBg addSubview:_messageCommentLab];
    [self addSubview:messageBg];
    
    //消息来源
    _messageSourceLab = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageSourceLab.backgroundColor = [UIColor clearColor];
    _messageSourceLab.font = [UIFont systemFontOfSize:MessageSourceFontSize];
    _messageSourceLab.textAlignment = NSTextAlignmentLeft;
    _messageSourceLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _messageSourceLab.textColor = UICOLOR_RGB_Alpha(0x666666, 1.0);
    [self addSubview:_messageSourceLab];
    
    //消息时间
    _commentTime = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentTime.backgroundColor = [UIColor clearColor];
    _commentTime.font = [UIFont systemFontOfSize:CommentTimeFontSize];
    _commentTime.textAlignment = NSTextAlignmentLeft;
    _commentTime.textColor = UICOLOR_RGB_Alpha(0x888888, 1.0);
    [self addSubview:_commentTime];
    
    _messageNewLab = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageNewLab.backgroundColor = [UIColor clearColor];
    _messageNewLab.font = [UIFont systemFontOfSize:MessageNewFontSize];
    _messageNewLab.textAlignment = NSTextAlignmentLeft;
    _messageNewLab.numberOfLines = 0;
    _messageNewLab.textColor = UICOLOR_RGB_Alpha(0x333333, 1.0);
    [self addSubview:_messageNewLab];
    
    line = [[UIImageView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.08];
    [self addSubview:line];
}

#pragma mark - 重写get方法
-(NSMutableArray *)commentArr
{
    if (!_commentArr) {
        _commentArr = [NSMutableArray array];
    }
    return _commentArr;
}


#pragma mark - 计算及返回辅助方法
//计算图文混排的高度
- (CGFloat)commentViewHeight:(VMAttributedLabel *)label withContext:(id)text
{
    //清空上次的数据
    [label setText:@""];
    
    //正则表达式选择之后的评论数组，
    NSMutableArray *temp = nil;
    if ([text isKindOfClass:[NSArray class]]) {
        temp = text;//[]
    }else if([text isKindOfClass:[NSString class]]){
        temp = [label stringFilter:text];
    }
    //保存评论的数组
    [self.commentArr removeAllObjects];
    [self.commentArr addObjectsFromArray:temp];
    
    NSDictionary * emotionDict = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"allEmotionDict"]];
    NSDate * startDate = [NSDate date];
    for (int i = 0; i < temp.count; i++) {
        NSString *str = [temp objectAtIndex:i];
        if ([str hasPrefix:@"["] && [str hasSuffix:@"]"]) {
            
            UIImage * image = nil;
            if (emotionDict) {
//                image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:emotionDict[str]];//此方法是再主线程当中执行的
                
            }
            if (emotionDict[str]) {
                NSLog(@"表情名称是：%@，表情网址是：%@",str,emotionDict[str]);
//                image = [UIImage imageNamed:@"comment_biaoqing_default"];
//                [label appendImage:image
//                           maxSize:CGSizeMake(FACE_ICON_SIZE, FACE_ICON_SIZE)
//                            margin:UIEdgeInsetsZero
//                         alignment:VMImageAlignmentBottom];
//
                //异步加载图片
                int type = 0;
                if (type) {
                    [label appendImageUrl:emotionDict[str] maxSize:CGSizeMake(FACE_ICON_SIZE, FACE_ICON_SIZE) margin:UIEdgeInsetsZero alignment:VMImageAlignmentBottom];
                }else{
                     image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:emotionDict[str]];
                     if (!image) {
                     image = [UIImage imageNamed:@"comment_biaoqing_default"];
                     __block typeof(label) weakLabel = label;
                     if (emotionDict[str]) {
                     [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:self.faceDic[str]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                     
                     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                     }];
                     }else{
                     [label appendText:str];
                     }
                     }
                     [label appendImage:image
                     maxSize:CGSizeMake(FACE_ICON_SIZE, FACE_ICON_SIZE)
                     margin:UIEdgeInsetsZero
                     alignment:VMImageAlignmentBottom];
                }
                continue;
            }else{
                NSLog(@"错误的表情名称是：%@",str);

                [label appendText:str];
                continue;
            }
        }
        else{
            [label appendText:[temp objectAtIndex:i]];
        }
    }
    NSLog(@"评论的content为%@，帅选评论时间为%f",text,[[NSDate date] timeIntervalSinceDate:startDate]);
    switch (self.viewType) {
#pragma mark - 根据self.commentView的宽度来计算高度
        case CommentLevelOne:
        {
            CGFloat commentViewWidth = CurrentScreenWidth - (55+10);
            if (iPhone6plus) {
                commentViewWidth -= 10;
            }
            commentHeight = [label sizeThatFits:CGSizeMake(commentViewWidth, CGFLOAT_MAX)].height;
            NSLog(@"viewtype == 1 ,commentViewWidth == %f",commentViewWidth);
        }
            break;
        case CommentLevelTwo:
        {
            CGFloat commentViewWidth = CurrentScreenWidth - (97+11);
            if (iPhone6plus) {
                commentViewWidth -= 10;
            }
            commentHeight = [label sizeThatFits:CGSizeMake(commentViewWidth, CGFLOAT_MAX)].height;
             NSLog(@"viewtype == 2 ,commentViewWidth == %f",commentViewWidth);
            
        }
            break;
        default:
            break;
    }
    return commentHeight;
}

//消息提醒算布局高和宽
- (void)setMessageContentHeight
{
    //原评论高
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:_messageCommentLab.text];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:5];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [attributedString1 length])];
    [_messageCommentLab setAttributedText:attributedString1];
    
    CGRect oldrect = [_messageCommentLab.attributedText boundingRectWithSize:CGSizeMake(CurrentScreenWidth-85.0, MAXFLOAT)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                     context:nil];
    oldMessageHeight = oldrect.size.height;
    
    
    //消息提醒时间宽度
    CGRect rect = [_commentTime.text boundingRectWithSize:CGSizeMake(MAXFLOAT, CommentTimeFontSize)
                                                  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:CommentTimeFontSize]} context:nil];
    timeWidth = rect.size.width;
    
    //默认回复类型宽度
    CGRect rect1 = [_messageTypeLab.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MessageTitleFontSize)
                                                      options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:MessageTitleFontSize]} context:nil];
    messageTypeWidth = rect1.size.width;
    
    //评论点赞人昵称宽
    CGRect rect2 = [_userNickname.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MessageTitleFontSize)
                                                    options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:MessageTitleFontSize]} context:nil];
    replyNameWidth = rect2.size.width;
    
    if (CurrentScreenWidth -75.0<timeWidth+messageTypeWidth+replyNameWidth) {
        replyNameWidth = CurrentScreenWidth -75.0 - messageTypeWidth - timeWidth;
    }
    
    //回复评论计算回复的高
    if (self.viewType == CommentMessageReply) {
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:_messageNewLab.text];
        [paragraphStyle1 setLineSpacing:5];
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [attributedString2 length])];
        _messageNewLab.attributedText = attributedString2;
        
        CGRect newrect = [_messageNewLab.attributedText boundingRectWithSize:CGSizeMake(CurrentScreenWidth-65.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        newMessageHeight = newrect.size.height;
    }
    
}


- (CGFloat)getViewHeight
{
    
    switch (self.viewType) {
        case CommentLevelOne:
        {
            //根据当前控件高度获得
            viewHeight = 15.0 + UserNickNameFontSize+1.0 + 8.0 + commentHeight + 8.0 +CommentTimeFontSize+10.0;
            if (iPhone6plus) {
                viewHeight = 15.0 + UserNickNameFontSizePlus+1.0 + 8.0 + commentHeight + 8.0 +CommentTimeFontSize+10.0;
            }
        }
            break;
        case CommentLevelTwo:
        {
            viewHeight = 15.0 + UserNickNameFontSize+1.0 + 8.0 + commentHeight + 8.0 +CommentTimeFontSize+10.0;
            if (iPhone6plus) {
                viewHeight = 15.0 + UserNickNameFontSizePlus+1.0 + 8.0 + commentHeight + 8.0 +CommentTimeFontSize+10.0;
            }
        }
            break;
        case CommentMessageReply:
        {
            viewHeight = 10.0+ MessageTitleFontSize+1.0+15.0+newMessageHeight+15.0+oldMessageHeight+20.0+10.0+MessageSourceFontSize+1.0+15.0;
        }
            break;
        case CommentMessageReplyPraise:
        {
            viewHeight = 10.0+ MessageTitleFontSize+1.0+15.0+oldMessageHeight+20.0+10.0+MessageSourceFontSize+1.0+15.0;
        }
            break;
            
        default:
            break;
    }
    if (self.viewType == CommentLevelOne || self.viewType == CommentLevelTwo) {
        CGFloat timeLineInterval = 3;
        viewHeight = viewHeight + timeLineInterval;
    }
    viewHeight += (UserNickNameTop - 10);
    viewHeight += (CommentTimeToBottomInteval - 10.0);
    return viewHeight;
}

#pragma mark - 按钮响应
//点击头像
- (void)userHeadClicked
{
    
    if ([self.delegate respondsToSelector:@selector(userHeadRespond)]) {
        [self.delegate userHeadRespond];
    }
    
}

//点赞按钮响应
- (void)praiseBtnClick
{
    if ([self.delegate respondsToSelector:@selector(commentPraiseRespond)]) {
        [self.delegate commentPraiseRespond];
    }
}

//二级评论展开按钮响应
- (void)commentMoreBtnClick
{
    
    if ([self.delegate respondsToSelector:@selector(commentShowMore)]) {
        [self.delegate commentShowMore];
    }
}


#pragma mark - 视图布局
//根据界面类型进行布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    //设置字体
    if (iPhone6plus) {
        self.userNickname.font = [UIFont systemFontOfSize:UserNickNameFontSizePlus];
        self.commentView.font = [UIFont systemFontOfSize:CommentFontSizePlus];
    }else {
        self.userNickname.font = [UIFont systemFontOfSize:UserNickNameFontSize];
        self.commentView.font = [UIFont systemFontOfSize:CommentFontSize];
    }
#pragma mark - 重新修改的页面
    //头像的top:+3
    CGFloat headerTop = 3.0+4;
    switch (self.viewType) {
        case CommentLevelOne:
        {
            _userHeadImag.frame = CGRectMake(10.0, 10.0+headerTop, 35.0, 35.0);
            
            _userNickname.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, 15.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-20.0,UserNickNameFontSize+1.0);
            if (iPhone6plus) {
                _userNickname.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, 20.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-20.0,UserNickNameFontSizePlus+1.0);
            }
            _commentView.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_userNickname.frame)+8.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-20.0, commentHeight);
            
            CGRect rect = [_commentTime.text boundingRectWithSize:CGSizeMake(MAXFLOAT, CommentTimeFontSize)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]}
                                                          context:nil];
            _commentTime.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_commentView.frame)+8.0, CGRectGetWidth(rect), CGRectGetHeight(rect));
            
            _praiseBtn.frame = CGRectMake(CurrentScreenWidth-10.0-11.0, CGRectGetMaxY(_commentView.frame)+8.0, 9.0, 9.0);
            
            CGRect rect1 = [_praiseLab.text boundingRectWithSize:CGSizeMake(MAXFLOAT, CommentPraiseFontSize)
                                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:CommentPraiseFontSize]} context:nil];
            _praiseLab.frame = CGRectMake(CGRectGetMinX(_praiseBtn.frame)-3.0-CGRectGetWidth(rect1), CGRectGetMaxY(_commentView.frame)+8.0, CGRectGetWidth(rect1), CGRectGetHeight(rect1));
            
            line.frame = CGRectMake(10.0, CGRectGetMaxY(_commentTime.frame)+8.0, CurrentScreenWidth-20.0, 0.4);
            if (iPhone6plus) {
                line.height = 1.0/3;
            }
            _commentMoreBtn.hidden = YES;
            
            _commentCountImgView.hidden = NO;
            _commentCountLabel.hidden = NO;
            _showMoreBtn.hidden = NO;
            
        }
            break;
        case CommentLevelTwo:
        {
            _userHeadImag.frame = CGRectMake(52.0, 10.0+headerTop, 35.0, 35.0);
            
            _userNickname.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, 20.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-20.0,UserNickNameFontSize+1.0);
            if (iPhone6plus) {
                _userNickname.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, 20.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-20.0,UserNickNameFontSizePlus+1.0);
            }
            _commentView.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_userNickname.frame)+8.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-21.0, commentHeight);
            
            CGRect rect = [_commentTime.text boundingRectWithSize:CGSizeMake(MAXFLOAT, CommentTimeFontSize)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9.0]}
                                                          context:nil];
            
            _commentTime.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_commentView.frame)+8.0, CGRectGetWidth(rect), CGRectGetHeight(rect));
            
            _praiseBtn.frame = CGRectMake(CurrentScreenWidth-10.0-11.0, CGRectGetMaxY(_commentView.frame)+8.0, 9.0, 9.0);
            
            CGRect rect1 = [_praiseLab.text boundingRectWithSize:CGSizeMake(MAXFLOAT, CommentPraiseFontSize)
                                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:CommentPraiseFontSize]} context:nil];
            _praiseLab.frame = CGRectMake(CGRectGetMinX(_praiseBtn.frame)-3.0-CGRectGetWidth(rect1), CGRectGetMaxY(_commentView.frame)+8.0, CGRectGetWidth(rect1), CGRectGetHeight(rect1));
            
            _commentMoreBtn.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
            _commentMoreBtn.backgroundColor = [UIColor greenColor];
            
            line.frame = CGRectMake(50.0, CGRectGetMaxY(_commentTime.frame)+8.0, CurrentScreenWidth-9.0-50, 0.4);
            if (iPhone6plus) {
                line.height = 1.0/3;
            }
            _commentCountImgView.hidden = YES;
            _commentCountLabel.hidden = YES;
            _showMoreBtn.hidden = YES;
            NSLog(@"二级评论，评论宽度 == %f",self.commentView.width);
        }
            break;
        case CommentMessageReply:
        {
            _userHeadImag.frame = CGRectMake(10.0, 10.0, 35.0, 35.0);
            
            _userNickname.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, 10.0, replyNameWidth, MessageTitleFontSize+1.0);
            
            _messageTypeLab.frame = CGRectMake(CGRectGetMaxX(_userNickname.frame)+5.0, 10.0, messageTypeWidth, MessageTitleFontSize+1.0);
            
            _commentTime.frame = CGRectMake(CurrentScreenWidth-10.0-timeWidth, 14.0, timeWidth, CommentTimeFontSize);
            
            _messageNewLab.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_userNickname.frame)+15.0, CurrentScreenWidth-65.0, newMessageHeight);
            
            messageBg.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_messageNewLab.frame)+15.0, CurrentScreenWidth-65.0, oldMessageHeight+20.0);
            
            _messageCommentLab.frame = CGRectMake(10.0, 10.0, CGRectGetWidth(messageBg.frame)-20.0, oldMessageHeight);
            
            _messageSourceLab.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(messageBg.frame)+10.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-10.0-10.0, MessageSourceFontSize+1.0);
            
            line.frame = CGRectMake(10.0, CGRectGetMaxY(_messageSourceLab.frame)+15.0, CurrentScreenWidth-20.0, 0.4);
            if (iPhone6plus) {
                line.height = 1.0/3;
            }
        }
            break;
        case CommentMessageReplyPraise:
        {
            _userHeadImag.frame = CGRectMake(10.0, 10.0, 35.0, 35.0);
            
            _userNickname.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, 10.0, replyNameWidth, MessageTitleFontSize+1.0);
            
            _messageTypeLab.frame = CGRectMake(CGRectGetMaxX(_userNickname.frame)+5.0, 10.0, messageTypeWidth, MessageTitleFontSize+1.0);
            
            _commentTime.frame = CGRectMake(CurrentScreenWidth-10.0-timeWidth, 14.0, timeWidth, CommentTimeFontSize);
            
            messageBg.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(_userNickname.frame)+15.0, CurrentScreenWidth-65.0, oldMessageHeight+20.0);
            
            _messageCommentLab.frame = CGRectMake(10.0, 10.0, CGRectGetWidth(messageBg.frame)-20.0, oldMessageHeight);
            
            _messageSourceLab.frame = CGRectMake(CGRectGetMaxX(_userHeadImag.frame)+10.0, CGRectGetMaxY(messageBg.frame)+10.0, CurrentScreenWidth-CGRectGetMaxX(_userHeadImag.frame)-10.0-10.0, MessageSourceFontSize+1.0);
            
            line.frame = CGRectMake(10.0, CGRectGetMaxY(_messageSourceLab.frame)+15.0, CurrentScreenWidth-20.0, 0.4);
            if (iPhone6plus) {
                line.height = 1.0/3;
            }
            
        }
            break;
            
        default:
            break;
    }
    _bigPraiseBtn.center = _praiseBtn.center;
    
#pragma mark - 重新设置坐标
    self.userNickname.top = UserNickNameTop;
    self.commentView.top = self.userNickname.bottom + 8;
    self.commentTime.top = self.commentView.bottom + 8;
    self.praiseBtn.top = self.commentTime.top;
    self.praiseLab.top = self.commentTime.top;
    self.userNickname.left = self.userHeadImag.right + 10;
    if (iPhone6plus) {
        self.commentView.left += 5;
        self.commentView.width -= 5;
        self.userNickname.left += 5;
        self.commentTime.left += 5;
        self.userHeadImag.left += 5;
        self.userNickname.left = self.userHeadImag.right + 15;
        self.commentTime.left = self.userHeadImag.right + 15;
        self.commentView.left = self.userHeadImag.right + 15;
        self.commentView.width -= 5;
    }
}

//新增的属性
-(UIView *)lineView
{
    return line;
}

- (void)dealloc
{
    
}
@end
