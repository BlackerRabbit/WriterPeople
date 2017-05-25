//
//  VMAttributedLabelAttachment.h
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VMAttributedLabelDefines.h"

//新增
#import "SDImageCache.h"
#import "SDWebImageManager.h"   //下载图片

void deallocCallback(void* ref);
CGFloat ascentCallback(void *ref);
CGFloat descentCallback(void *ref);
CGFloat widthCallback(void* ref);

typedef void(^CallBack)(id object);

@interface VMAttributedLabelAttachment : NSObject

@property (nonatomic,strong)    id                  content;
@property (nonatomic,assign)    UIEdgeInsets        margin;
@property (nonatomic,assign)    VMImageAlignment   alignment;
@property (nonatomic,assign)    CGFloat             fontAscent;
@property (nonatomic,assign)    CGFloat             fontDescent;
@property (nonatomic,assign)    CGSize              maxSize;


+ (VMAttributedLabelAttachment *)attachmentWith: (id)content
                                          margin: (UIEdgeInsets)margin
                                       alignment: (VMImageAlignment)alignment
                                         maxSize: (CGSize)maxSize;

- (CGSize)boxSize;
//异步加载图片失败
-(void)addActionWithLoadImageBlocks:(CallBack)callBack;

@end
