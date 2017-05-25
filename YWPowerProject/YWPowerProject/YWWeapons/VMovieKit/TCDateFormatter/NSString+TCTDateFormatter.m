//
//  NSString+TCTDateFormatter.m
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-11.
//
//

#import "NSString+TCTDateFormatter.h"
#import "TCTFormatter.h"

@implementation NSString (TCTDateFormatter)

- (NSDate *)dateWithDateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [TCTFormatter sharedDateFormatter];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter dateFromString:self];
}

@end
