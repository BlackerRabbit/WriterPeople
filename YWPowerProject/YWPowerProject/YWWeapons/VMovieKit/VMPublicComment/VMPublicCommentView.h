//
//  VMPublicCommentView.h
//  VMComment
//
//  Created by 吴宇 on 15/11/9.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VMAttributedLabel.h"


//新增的类
#import "SDImageCache.h"
#import "SDWebImageManager.h"   //下载图片
//新增的类

typedef NS_ENUM(NSInteger,CommentType) {
    CommentLevelOne                 = 0,        //视频详情1级评论
    CommentLevelTwo                 = 1,        //视频详情2级评论
    CommentMessageReply             = 2,        //消息提醒评论
    CommentMessageReplyPraise       = 3         //消息提醒点赞
    
};

@protocol VMPublicCommentViewDelegate <NSObject>
@required
- (void)userHeadRespond;

- (void)commentPraiseRespond;;

@optional
- (void)commentShowMore;

@end

@interface VMPublicCommentView : UIView
/*
 详情评论
 */
@property (nonatomic,strong) UIImageView *userHeadImag;             //用户头像
@property (nonatomic,strong) UILabel *userNickname;                 //用户昵称
@property (nonatomic,strong) UILabel *userReplyLab;                 //用户回复用户
@property (nonatomic,strong) VMAttributedLabel *commentView;        //评论及回复内容
@property (nonatomic,strong) UILabel *commentTime;                  //评论及回复时间
@property (nonatomic,strong) UILabel *praiseLab;                    //点赞数
@property (nonatomic,strong) UIButton *praiseBtn;                   //点赞按钮
@property (nonatomic,strong) UIButton *commentMoreBtn;              //展开更多评论按钮
//新增的视图
@property (nonatomic,strong)UILabel * commentCountLabel;            //总评论个数标签
@property (nonatomic,strong)UIImageView * commentCountImgView;      //总评论图片视图
@property (nonatomic,strong)UIButton * showMoreBtn;//现实更多评论的按钮

@property (nonatomic,assign) CommentType viewType;                  //界面展现类型
/*
 消息提醒
 */
@property (nonatomic,strong) UILabel *messageNewLab;                //原评论信息
@property (nonatomic,strong) UILabel *messageSourceLab;             //消息来源
@property (nonatomic,strong) UILabel *messageTypeLab;               //消息类型
@property (nonatomic,strong) UILabel *messageCommentLab;            //收到回复评论
@property (nonatomic,weak)   id<VMPublicCommentViewDelegate> delegate;

@property (nonatomic,strong,readonly)UIView * lineView;
/**
 *  盛放表情的字典
 *  key:评论图片的形容  value:评论图片的URL
 */
@property (nonatomic,strong)NSMutableDictionary * faceDic;

/**
 *  盛放评论详情的数组
 *  内容为经过正则计算之后的评论详情分为文字与表情
 */
@property (nonatomic,strong)NSMutableArray * commentArr;

//评论界面初始化
- (instancetype)initCommentWithFrame:(CGRect)frame;

//消息提醒界面初始化
- (instancetype)initMessageWithFrame:(CGRect)frame;

//消息提醒计算高
- (void)setMessageContentHeight;

//获得当前界面的高
- (CGFloat)getViewHeight;

//计算图文混排的高度
- (CGFloat)commentViewHeight:(VMAttributedLabel *)label withContext:(id)text;


@end

