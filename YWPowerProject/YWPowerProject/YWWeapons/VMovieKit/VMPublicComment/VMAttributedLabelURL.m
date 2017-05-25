//
//  VMAttributedLabelURL.m
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import "VMAttributedLabelURL.h"

static NSString *urlExpression = @"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";

static VMCustomDetectLinkBlock customDetectBlock = nil;

@implementation VMAttributedLabelURL
+ (VMAttributedLabelURL *)urlWithLinkData: (id)linkData
                                     range: (NSRange)range
                                     color: (UIColor *)color
{
    VMAttributedLabelURL *url  = [[VMAttributedLabelURL alloc]init];
    url.linkData                = linkData;
    url.range                   = range;
    url.color                   = color;
    return url;
    
}


+ (NSArray *)detectLinks: (NSString *)plainText
{
    //提供一个自定义的解析接口给
    if (customDetectBlock)
    {
        return customDetectBlock(plainText);
    }
    else
    {
        NSMutableArray *links = nil;
        if ([plainText length])
        {
            links = [NSMutableArray array];
            NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:urlExpression
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:nil];
            [urlRegex enumerateMatchesInString:plainText
                                       options:0
                                         range:NSMakeRange(0, [plainText length])
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                        NSRange range = result.range;
                                        NSString *text = [plainText substringWithRange:range];
                                        VMAttributedLabelURL *link = [VMAttributedLabelURL
                                                                         urlWithLinkData:text
                                                                                                       range:range
                                                                                                       color:nil];
                                        [links addObject:link];
                                    }];
        }
        return links;
    }
}

+ (void)setCustomDetectMethod:(VMCustomDetectLinkBlock)block
{
    customDetectBlock = [block copy];
}

@end
