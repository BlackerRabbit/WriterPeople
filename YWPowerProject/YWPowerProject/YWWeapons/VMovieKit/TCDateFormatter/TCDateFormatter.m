//
//  TCDateFormatter.m
//  TCTravel_IPhone
//
//  Created by ZhuYanJun on 12-11-28.
//
//

#import "TCDateFormatter.h"
#import "NSString+TCTDateFormatter.h"
#import "NSDate+TCTStringFormatter.h"

@implementation TCDateFormatter

+ (NSString *)dateToTTTCustom:(NSDate *)_date
{
    return [_date dateToTTTCustom];
}

+ (NSString *) dateToStringCustom:(NSDate *)date formatString:(NSString *)formatString
{
    return [date stringWithDateFormat:formatString];
}

+ (NSDate *)stringToDateCustom:(NSString *)dateString formatString:(NSString *)formatString
{
    return [dateString dateWithDateFormat:formatString];
}

@end
