//
//  TCTFormatter.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-11.
//
//

#import <Foundation/Foundation.h>

@interface TCTFormatter : NSObject

+ (instancetype)sharedFormatter;

+ (NSDateFormatter *)sharedDateFormatter;

@end
