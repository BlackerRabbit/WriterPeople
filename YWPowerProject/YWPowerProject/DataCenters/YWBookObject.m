//
//  YWBookObject.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "YWBookObject.h"
#import "VMovieKit.h"
#import "VMTools.h"
#import "VMovieDefine.h"


typedef NS_ENUM(NSInteger, BookObjectOffsetStatus){
    OffsetStatusUnknown     = 1 << 0,
    OffsetStatusBigger      = 1 << 1,
    OffsetStatusSmaller     = 1 << 2,
    OffsetStatusEquals      = 1 << 3,
};

@interface YWBookObject()
@property (nonatomic, strong, readwrite) NSFileHandle *fileHandler;
@property (nonatomic, assign, readwrite) BookObjectOffsetStatus currentStatus;
@property (nonatomic, strong, readwrite) NSMutableArray *statusAry;

//一般标准的offset
@property (nonatomic, assign, readwrite) NSInteger normalOffset;
@property (nonatomic, assign, readwrite) NSUInteger pageCount;

@end

@implementation YWBookObject

+(YWBookObject *)bookWithPath:(NSString *)path{
    if ([path isValid] == NO) {
        return nil;
    }
    YWBookObject *book = [[YWBookObject alloc]init];
    book.path = path;
    book.currentStatus = OffsetStatusUnknown;
    book.pageArray = [[book getPageRangeWithBounds:BOOK_DRAW_RECT] mutableCopy];
    return book;
}

-(id)init{
    self = [super init];
    self.currentStatus = OffsetStatusUnknown;
    self.statusAry = [@[]mutableCopy];
    self.pageArray = [@[]mutableCopy];
    return self;
}

-(NSArray *)getPageRangeWithBounds:(CGRect)bounds{
    NSMutableArray *rangeAry = [@[]mutableCopy];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.words attributes:[YWBookObject attDiconary]];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attString);
    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
    CFRange range = CFRangeMake(0, 0);
    NSInteger rangeOffset = 0;
    do {
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(rangeOffset, 0), path, nil);
        range = CTFrameGetVisibleStringRange(frame);
        [rangeAry addObject:[NSValue valueWithRange:NSMakeRange(rangeOffset, range.length)]];
        rangeOffset += range.length;
    } while (range.location + range.length < attString.length);
    return [rangeAry copy];
}

+(CTFrameRef )frameRefWith:(NSString *)content{
    CGRect bounds = BOOK_DRAW_RECT;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:content attributes:[YWBookObject attDiconary]];
    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
    return frameRef;
}

#pragma mark - lazy actions -------

-(NSString *)words{
    if (_words == nil) {
        if (self.path == nil) {
            _words = nil;
        }else{
            NSString *originString = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
            _words = [VMTools dealWithregularString:originString];
        }
    }
    return _words;
}

+(NSDictionary *)attDiconary{
    NSMutableParagraphStyle *pragrah = [[NSMutableParagraphStyle alloc]init];
    pragrah.lineSpacing = 10;
    pragrah.paragraphSpacing = 14;
    pragrah.firstLineHeadIndent = 0;
    pragrah.alignment = NSTextAlignmentJustified;
    pragrah.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attDic = @{
                             NSParagraphStyleAttributeName  : pragrah,
                             NSFontAttributeName            : [UIFont systemFontOfSize:14],
                             NSForegroundColorAttributeName : COLOR(61, 61, 61),
                             };
    return attDic;
}

@end
