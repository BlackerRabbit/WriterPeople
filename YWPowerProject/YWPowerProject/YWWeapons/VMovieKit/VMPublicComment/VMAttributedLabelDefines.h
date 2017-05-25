//
//  VMAttributedLabelDefines.h
//  VMComment
//
//  Created by 吴宇 on 15/11/5.
//  Copyright © 2015年 吴宇. All rights reserved.
//

#ifndef VMAttributedLabelDefines_h
#define VMAttributedLabelDefines_h


typedef enum
{
    VMImageAlignmentTop,
    VMImageAlignmentCenter,
    VMImageAlignmentBottom
} VMImageAlignment;

@class VMAttributedLabel;

@protocol VMAttributedLabelDelegate <NSObject>
- (void)VMAttributedLabel:(VMAttributedLabel *)label
             clickedOnLink:(id)linkData;

@end

typedef NSArray *(^VMCustomDetectLinkBlock)(NSString *text);


//如果文本长度小于这个值,直接在UI线程做Link检测,否则都dispatch到共享线程
#define VMMinAsyncDetectLinkLength 50

#define VMIOS7 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)

#endif

