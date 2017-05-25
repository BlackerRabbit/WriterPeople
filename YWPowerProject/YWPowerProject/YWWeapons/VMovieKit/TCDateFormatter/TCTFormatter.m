//
//  TCTFormatter.m
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-11.
//
//

#import "TCTFormatter.h"

@implementation TCTFormatter

+ (instancetype)sharedFormatter
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

+ (NSDateFormatter *)sharedDateFormatter
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = NSDateFormatter.new;
        [NSTimeZone resetSystemTimeZone];
        [instance setTimeZone:[NSTimeZone systemTimeZone]];
        [instance setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    });
    return instance;
}

@end
