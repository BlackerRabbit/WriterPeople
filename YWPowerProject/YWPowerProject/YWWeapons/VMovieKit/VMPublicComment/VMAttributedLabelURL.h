//
//  VMAttributedLabelURL.h
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VMAttributedLabelDefines.h"

@interface VMAttributedLabelURL : NSObject

@property (nonatomic,strong)    id      linkData;
@property (nonatomic,assign)    NSRange range;
@property (nonatomic,strong)    UIColor *color;

+ (VMAttributedLabelURL *)urlWithLinkData: (id)linkData
                                     range: (NSRange)range
                                     color: (UIColor *)color;


+ (NSArray *)detectLinks: (NSString *)plainText;

+ (void)setCustomDetectMethod:(VMCustomDetectLinkBlock)block;
@end
