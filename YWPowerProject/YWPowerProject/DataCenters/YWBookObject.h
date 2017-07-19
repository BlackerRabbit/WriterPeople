//
//  YWBookObject.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#define BOOK_DRAW_RECT CGRectMake(0, 0, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 80)


@interface YWBookObject : NSObject
@property (nonatomic, strong, readwrite) NSString *authorName;
@property (nonatomic, strong, readwrite) NSString *path;
@property (nonatomic, strong, readwrite) NSString *bookTitle;
@property (nonatomic, strong, readwrite) NSString *bookDes;
/** 字数
 */
@property (nonatomic, assign, readwrite) NSUInteger bookLength;
@property (nonatomic, strong, readwrite) NSString *bookCoverImg;

@property (nonatomic, strong, readwrite) NSString *words;



+(YWBookObject *)bookWithPath:(NSString *)path;

+(YWBookObject *)currentBook;


@property (nonatomic, strong, readwrite) NSMutableArray *pageArray;
@property (nonatomic, strong, readwrite) NSMutableArray *attStringAry;

+(NSDictionary *)attDiconary;
+(CTFrameRef )frameRefWith:(NSString *)content;
@end
