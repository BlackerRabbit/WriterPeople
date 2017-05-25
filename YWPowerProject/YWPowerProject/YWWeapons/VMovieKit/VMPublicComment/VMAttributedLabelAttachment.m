//
//  VMAttributedLabelAttachment.m
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import "VMAttributedLabelAttachment.h"

void deallocCallback(void* ref)
{
    
}

CGFloat ascentCallback(void *ref)
{
    VMAttributedLabelAttachment *image = (__bridge VMAttributedLabelAttachment *)ref;
    CGFloat ascent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case VMImageAlignmentTop:
            ascent = image.fontAscent;
            break;
        case VMImageAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            ascent = height / 2 + baseLine;
        }
            break;
        case VMImageAlignmentBottom:
            ascent = height - image.fontDescent;
            break;
        default:
            break;
    }
    return ascent;
}

CGFloat descentCallback(void *ref)
{
    VMAttributedLabelAttachment *image = (__bridge VMAttributedLabelAttachment *)ref;
    CGFloat descent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case VMImageAlignmentTop:
        {
            descent = height - image.fontAscent;
            break;
        }
        case VMImageAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            descent = height / 2 - baseLine;
        }
            break;
        case VMImageAlignmentBottom:
        {
            descent = image.fontDescent;
            break;
        }
        default:
            break;
    }
    
    return descent;
    
}

CGFloat widthCallback(void* ref)
{
    VMAttributedLabelAttachment *image  = (__bridge VMAttributedLabelAttachment *)ref;
    return [image boxSize].width;
}

#pragma mark - VMAttributedLabelImage
@interface VMAttributedLabelAttachment ()
- (CGSize)calculateContentSize;
- (CGSize)attachmentSize;
@end

@implementation VMAttributedLabelAttachment
{
    CallBack _callBack;
}



+ (VMAttributedLabelAttachment *)attachmentWith: (id)content
                                          margin: (UIEdgeInsets)margin
                                       alignment: (VMImageAlignment)alignment
                                         maxSize: (CGSize)maxSize
{
    VMAttributedLabelAttachment *attachment    = [[VMAttributedLabelAttachment alloc]init];
    if ([content isKindOfClass:[UIImage class]]) {
         attachment.content                          = content;
    }else if([content isKindOfClass:[NSString class]]){
        //这是一个图片网址，需要异步加载
        attachment.content = [UIImage imageNamed:@"comment_biaoqing_default"];
        //异步加载
        __block VMAttributedLabelAttachment * weakSelf = attachment;
        [[SDImageCache sharedImageCache]queryDiskCacheForKey:content done:^(UIImage *image, SDImageCacheType cacheType) {
            if (image) {
                attachment.content = image;
                [weakSelf blockCallBackWithObject:nil];
            }else{
                //从网络上面下载
            }
        }];
        
    }
    attachment.margin                           = margin;
    attachment.alignment                        = alignment;
    attachment.maxSize                          = maxSize;
    return attachment;
}


- (CGSize)boxSize
{
    CGSize contentSize = [self attachmentSize];
    if (_maxSize.width > 0 &&_maxSize.height > 0 &&
        contentSize.width > 0 && contentSize.height > 0)
    {
        contentSize = [self calculateContentSize];
    }
    return CGSizeMake(contentSize.width + _margin.left + _margin.right,
                      contentSize.height+ _margin.top  + _margin.bottom);
}


#pragma mark - 辅助方法
- (CGSize)calculateContentSize
{
    CGSize attachmentSize   = [self attachmentSize];
    CGFloat width           = attachmentSize.width;
    CGFloat height          = attachmentSize.height;
    CGFloat newWidth        = _maxSize.width;
    CGFloat newHeight       = _maxSize.height;
    if (width <= newWidth &&
        height<= newHeight)
    {
        return attachmentSize;
    }
    CGSize size;
    if (width / height > newWidth / newHeight)
    {
        size = CGSizeMake(newWidth, newWidth * height / width);
    }
    else
    {
        size = CGSizeMake(newHeight * width / height, newHeight);
    }
    return size;
}

- (CGSize)attachmentSize
{
    CGSize size = CGSizeZero;
    if ([_content isKindOfClass:[UIImage class]])
    {
        size = [((UIImage *)_content) size];
    }
    else if ([_content isKindOfClass:[UIView class]])
    {
        size = [((UIView *)_content) bounds].size;
    }
    return size;
}

-(void)addActionWithLoadImageBlocks:(CallBack)callBack
{
    _callBack = callBack;
}
-(void)blockCallBackWithObject:(id)object
{
    if (_callBack) {
        _callBack(object);
    }
}
@end
