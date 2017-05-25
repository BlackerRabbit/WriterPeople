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
    return book;
}

-(id)init{
    self = [super init];
    self.currentStatus = OffsetStatusUnknown;
    self.statusAry = [@[]mutableCopy];
    self.pageArray = [@[]mutableCopy];
    return self;
}


-(NSString *)loadFile:(NSString *)path withOffset:(unsigned long long)offset{
    if ([path isValid] == NO) {
        return @"";
    }
    self.fileHandler = [NSFileHandle fileHandleForReadingAtPath:path];
    if (offset > 0) {
        [self.fileHandler seekToFileOffset:offset];
    }
    NSData *data = [self.fileHandler readDataOfLength:offset];
    NSString *fileContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return fileContent;
}

-(NSString *)stringFromOffset:(unsigned long long )offset{

    NSFileHandle *handler = [NSFileHandle fileHandleForReadingAtPath:self.path];
    [handler seekToFileOffset:offset];
    NSData *data = [handler readDataOfLength:offset];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    for (int i = 0; i < 10; i ++) {
        NSData *tempData = [handler readDataOfLength:offset++];
        NSString *str = [[NSString alloc]initWithData:tempData encoding:NSUTF8StringEncoding];
        
        if ([str isValid]) {
            NSLog(@"%llu %@",offset,str);
        }
    }
    return str;
}

-(NSString *)stringOfPage:(NSUInteger)index
{
    NSUInteger local = [_pageArray[index] integerValue];
    NSUInteger length;
    if (index<self.pageCount-1) {
        length=  [_pageArray[index+1] integerValue] - [_pageArray[index] integerValue];
    }
    else{
        length = self.words.length - [_pageArray[index] integerValue];
    }
    return [self.words substringWithRange:NSMakeRange(local, length)];
}

-(void)paginateWithBounds:(CGRect)bounds
{
    [_pageArray removeAllObjects];
    NSAttributedString *attrString;
    CTFramesetterRef frameSetter;
    CGPathRef path;
    NSMutableAttributedString *attrStr;
    attrStr = [[NSMutableAttributedString alloc] initWithString:self.words];
    NSDictionary *attribute = [self attDiconary];
    [attrStr setAttributes:attribute range:NSMakeRange(0, attrStr.length)];
    attrString = [attrStr copy];
    frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    path = CGPathCreateWithRect(bounds, NULL);
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            
            ++samePlaceRepeatCount;
        } else {
            samePlaceRepeatCount = 0;
        }
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (_pageArray.count == 0) {
                [_pageArray addObject:@(currentOffset)];
            }
            else {
                
                NSUInteger lastOffset = [[_pageArray lastObject] integerValue];
                if (lastOffset != currentOffset) {
                    [_pageArray addObject:@(currentOffset)];
                }
            }
            break;
        }
        [_pageArray addObject:@(currentOffset)];
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        
        CFRange range = CTFrameGetVisibleStringRange(frame);
        
        if ((range.location + range.length) != attrString.length) {
            
            currentOffset += range.length;
            currentInnerOffset += range.length;
        }else{
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    CGPathRelease(path);
    CFRelease(frameSetter);
    self.pageCount = self.pageArray.count;
}

-(NSString *)offsetWithAtt:(NSDictionary *)att withMAXSize:(CGSize)size range:(NSRange)range{
    
    //每次都需要检查一下对应的状态，如果说满足条件了，直接返回相应的offset;
    BookObjectOffsetStatus preiousStatus = self.currentStatus;
    if (range.length + range.location > self.words.length) {
        return [self.words substringWithRange:NSMakeRange(range.location, self.words.length - range.location)];
    }
    NSString *string = [self.words substringWithRange:range];
    string = [self deleteMoreBlankLines:string];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:att context:nil];
    NSRange newRange = range;
    if (rect.size.height < size.height) {
        self.currentStatus = OffsetStatusSmaller;
        //如果比最大的高度小，那offset向后移动，重新计算
        newRange = NSMakeRange(range.location, ++range.length);
        
    }else if (rect.size.height > size.height){
        self.currentStatus = OffsetStatusBigger;
        newRange = NSMakeRange(range.location, --range.length);
    }else if (rect.size.height == size.height){
        self.currentStatus = OffsetStatusEquals;
        newRange = NSMakeRange(range.location,  ++range.length);
    }
    if (preiousStatus == OffsetStatusBigger && self.currentStatus == OffsetStatusEquals) {
        //ok的，且返回当前的offset
        NSLog(@"======>>>>%@",string);
        return [self.words substringWithRange:newRange];
    }
    if (preiousStatus == OffsetStatusEquals && self.currentStatus == OffsetStatusBigger) {
        //ok的，返回offset--
        NSLog(@"======>>>> %@",string);
        newRange = NSMakeRange(range.location, --range.length);
        return [self.words substringWithRange:newRange];
    }
    
    if (preiousStatus == OffsetStatusBigger && self.currentStatus == OffsetStatusSmaller) {
        newRange = NSMakeRange(range.location, --range.length);
        return [self.words substringWithRange:newRange];
    }
    return  [self offsetWithAtt:att withMAXSize:size range:newRange];
}

-(NSArray *)loadBookWithPagesSimple{
    
    if ([self.words isValid] == NO) {
        return nil;
    }
    self.attStringAry = [@[]mutableCopy];
    CGRect rect = BOOK_DRAW_RECT;
    [self paginateWithBounds:rect];
    
    for (int i = 0; i < self.pageArray.count; i++) {

        NSString *str = [self stringOfPage:i];
        NSString *strEasy = [self deleteMoreBlankLines:str];
        if ([strEasy hasPrefix:@"\n"]) {
            strEasy = [strEasy stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        if ([strEasy hasSuffix:@"\n"]) {
            strEasy = [strEasy stringByReplacingCharactersInRange:NSMakeRange(strEasy.length - 1, 1) withString:@""];
        }
        NSAttributedString *att =  [[NSAttributedString alloc]initWithString:strEasy attributes:[self attDiconary]];
        [self.attStringAry addObject:att];
        NSLog(@"index %d的内容是\n %@",i,att);
    }
    return self.attStringAry;
}

-(NSString *)deleteMoreBlankLines:(NSString *)string{
    NSString *value = nil;
    if ([string containSubstring:@"\n\n"]) {
        value = [string replaceString:@"\n\n" withString:@"\n"];
        return [self deleteMoreBlankLines:value];
    }
    if ([string hasPrefix:@"\n"]) {
        return value = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    if ([string hasSuffix:@"\n"]) {
        return value = [string stringByReplacingCharactersInRange:NSMakeRange(string.length - 1, 1) withString:@""];
    }
    return value = string;
}

#pragma mark - lazy actions -------

-(NSString *)words{
    if (_words == nil) {
        if (self.path == nil) {
            _words = nil;
        }else{
            NSString *originString = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
            _words = [self deleteMoreBlankLines:originString];
        }
    }
    return _words;
}

-(NSDictionary *)attDiconary{
    NSMutableParagraphStyle *pragrah = [[NSMutableParagraphStyle alloc]init];
    pragrah.lineSpacing = 10;
    pragrah.paragraphSpacing = 14;
    pragrah.firstLineHeadIndent = 0;
//    pragrah.lineBreakMode = 
    pragrah.alignment = NSTextAlignmentJustified;
    NSDictionary *attDic = @{
                             NSParagraphStyleAttributeName  : pragrah,
                             NSFontAttributeName            : [UIFont systemFontOfSize:14],
                             NSForegroundColorAttributeName : COLOR(61, 61, 61),
                             };
    return attDic;
}

@end
