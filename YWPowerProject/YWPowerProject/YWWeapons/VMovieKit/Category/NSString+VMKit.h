//
//  NSString+MMDFoundation.h
//  MMDUIKit
//
//  Created by bennyguan on 14-10-6.
//  Copyright (c) 2014年 MMD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (VMKit)

-(NSString*) toPinyin;

-(NSString*) toTrim;

-(BOOL) isBlank;

-(BOOL) isValid;

-(BOOL) containSubstring:(NSString *)subString;

-(BOOL) containSubstring:(NSString *)subString
              ignoreCase:(BOOL)ignore;

-(BOOL) isBeginWith:(NSString *)string;

-(BOOL) isEndWith:(NSString *)string;

-(NSString*) replaceString:(NSString *)olderString
                withString:(NSString *)newerString;

-(NSString*) getSubstringFrom:(NSInteger)begin
                           to:(NSInteger)end;

-(NSString*) addString:(NSString *)string;

-(NSString*) removeSubstring:(NSString *)subString;

-(NSUInteger) indexOfString:(NSString*)string;

-(NSUInteger) indexOfString:(NSString *)string
                 ignoreCase:(BOOL)ignore;

-(NSArray*) splitWith:(NSString*)separater;

-(NSString*) stringByAppendingUrlComponent:(NSString*)string;

-(id)jsonObject;

+(NSString *)jsonStringFrom:(id)dic;


- (float) heightWithFont: (UIFont *) font withinWidth: (float) width;
- (float) widthWithFont: (UIFont *) font;

//限制输入长度
- (NSString *)stringLengthLimit:(NSString *)string number:(NSInteger)number;

-(BOOL)isAsiiCode;

-(NSInteger)gongtingMaLength;


//正则匹配相关





@end
