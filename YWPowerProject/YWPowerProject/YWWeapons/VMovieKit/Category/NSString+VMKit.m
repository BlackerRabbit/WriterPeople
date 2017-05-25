//
//  NSString+MMDFoundation.m
//  MMDUIKit
//
//  Created by bennyguan on 14-10-6.
//  Copyright (c) 2014年 MMD. All rights reserved.
//

#import "NSString+VMKit.h"

@implementation NSString (VMKit)

-(NSString*) toPinyin
{
    NSMutableString *pinyin = [[NSMutableString alloc] initWithString:self];
    
    CFStringTransform((__bridge CFMutableStringRef)pinyin, 0,kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, 0,kCFStringTransformStripDiacritics, NO);
    return pinyin;
}

-(NSString*) toTrim
{
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

-(BOOL) isBlank
{
    return ([[self toTrim] isEqualToString:@""]) ? YES : NO;
}

-(BOOL) isValid
{
    return ([[self class]isSubclassOfClass:[NSNull class]] || [[self toTrim] isEqualToString:@""] || self == nil || [self isEqualToString:@"(null)"] || [self isEqualToString:@"null"] || [self isEqualToString:@"<null>"]) ? NO :YES;
}

-(BOOL) containSubstring:(NSString *)subString
{
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}

-(BOOL) containSubstring:(NSString *)subString ignoreCase:(BOOL)ignore
{
    if(ignore)
    {
        NSString* orgin = [self lowercaseString];
        return [orgin containSubstring:[subString lowercaseString]];
    }
    else
    {
        return [self containSubstring:subString];
    }
}

-(BOOL) isBeginWith:(NSString *)string
{
    return ([self hasPrefix:string]) ? YES : NO;
}

-(BOOL) isEndWith:(NSString *)string
{
    return ([self hasSuffix:string]) ? YES : NO;
}

-(NSString*)replaceString:(NSString *)olderString withString:(NSString *)newerString
{
    return  [self stringByReplacingOccurrencesOfString:olderString withString:newerString];
}

-(NSString*) getSubstringFrom:(NSInteger)begin to:(NSInteger)end
{
    NSRange r;
    r.location = begin;
    r.length = end - begin;
    return [self substringWithRange:r];
}

-(NSString*) addString:(NSString *)string
{
    if(![string isValid])
        return self;
    
    return [self stringByAppendingString:string];
}

-(NSString*) removeSubstring:(NSString *)subString
{
    if ([self containSubstring:subString])
    {
        NSRange range = [self rangeOfString:subString];
        return  [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

-(NSUInteger) indexOfString:(NSString*)string
{
    if(![self containSubstring:string])
    {
        return NSNotFound;
    }
    
    return [self rangeOfString:string].location;
}

-(NSUInteger) indexOfString:(NSString *)string
                 ignoreCase:(BOOL)ignore
{
    if(ignore)
    {
        NSString* orgin = [self lowercaseString];
        return [orgin indexOfString:[string lowercaseString]];
    }
    else
    {
        return [self indexOfString:string];
    }
}

-(NSArray*) splitWith:(NSString*)separater
{
    return [self componentsSeparatedByString:separater];
}

-(NSString*) stringByAppendingUrlComponent:(NSString*)string{
    
    NSString* urlhost = [self toTrim];
    if([string isBeginWith:@"/"]){
        
        if([urlhost isEndWith:@"/"])
        {
            urlhost = [urlhost substringToIndex:urlhost.length - 1];
        }
    }
    else
    {
        if([urlhost isEndWith:@"/"] == NO)
        {
            urlhost = [urlhost stringByAppendingString:@"/"];
        }
    }
    return [urlhost stringByAppendingString:string];
}


-(id)jsonObject
{
    NSError *error = nil;
    if ([self isValid] == NO) {
        NSLog(@"string is invalid");
        return nil;
    }
    id result = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error || [NSJSONSerialization isValidJSONObject:result] == NO)
    {
        NSLog(@"json is %@",self);
        return nil;
    }
    
    return result;
}

+(NSString *)jsonStringFrom:(id)dic{
    
    NSError *error;
    NSString *jsonStr = nil;
    if ([[dic class]isSubclassOfClass:[NSNull class]]) {
        return @"";
    }
    if (dic) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            jsonData = nil;
            return nil;
        }else
            jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonStr;
}

- (float) heightWithFont: (UIFont *) font withinWidth: (float) width
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    //NSStringDrawingUsesLineFragmentOrigin
    //NSStringDrawingUsesFontLeading
//    CGSize size = [self sizeWithAttributes:@{NSFontAttributeName:font,
//                               NSParagraphStyleAttributeName:paragraphStyle}];
    NSLog(@"%@",self);
    CGRect textRect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:font,
                                                   NSParagraphStyleAttributeName:paragraphStyle}
                                         context:nil];
    
    
    return ceil(textRect.size.height);
}

- (float) widthWithFont: (UIFont *) font
{
    CGRect textRect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, font.pointSize)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    
    return ceil(textRect.size.width);
}

-(BOOL)isAsiiCode{
    if ([self characterAtIndex:0] > 0 && [self characterAtIndex:0] < 127) {
        return YES;
    }
    return NO;
}

-(NSInteger)gongtingMaLength{
    
    NSInteger gongtingLength = 0;
    NSInteger length = self.length;
    for (int i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subStr = [self substringWithRange:range];
        if ([subStr isAsiiCode]) {
            gongtingLength ++;
        }else
            gongtingLength += 2;
    }
    return gongtingLength;
}

@end
