//
//  TCDateFormatter.h
//  TCTravel_IPhone
//
//  Created by ZhuYanJun on 12-11-28.
//
//

#import <Foundation/Foundation.h>

static NSString *const def_YearMonthDayWeekChn              = @"yyyy年MM月dd日 EEEE";
static NSString *const def_YearMonthDayWeekChn_DF           = @"yyyy年MM月dd日 EE";
static NSString *const def_Year1Month1DayWeekChn_DF         = @"yyyy年M月d日 EE";
static NSString *const def_Year1Month1Day_DF                = @"yyyy年M月d日";
static NSString *const def_YearMonthDayChn_DF               = @"yyyy年MM月dd日";
static NSString *const def_MonthYearChn_DF                  = @"MM月/yyyy年";
static NSString *const def_YearWeekChn_DF                   = @"yyyy年 EEEE";
static NSString *const def_MonthDayWeekTwoChn_DF            = @"MM月dd日 EE";
static NSString *const def_MonthDayWeekChn_DF               = @"M月d日 EE";
static NSString *const def_WeekMonthDayChn_DF               = @"EE M月d日";
static NSString *const def_MonthDayChn_DF                   = @"M月d日";
static NSString *const def_YearMonthDayHourMinuteChn_DF     = @"yyyy年MM月dd日 HH:mm";
static NSString *const def_YearMonthDayHourMinuteSecChn_DF  = @"yyyy年MM月dd日 HH:mm:ss";
static NSString *const def_GangYearMonthDayHourMinute_DF    = @"yyyy/MM/dd HH:mm";
static NSString *const def_YearMonthDayHourMinute_DF        = @"yyyy-MM-dd HH:mm";
static NSString *const def_YearMonthDayHourMinuteSec_DF     = @"yyyy-MM-dd HH:mm:ss";
static NSString *const def_YearMonthDayWeek                 = @"yyyy-MM-dd EEEE";
static NSString *const def_YearMonthDayWeek_DF              = @"yyyy-MM-dd EE";
static NSString *const def_YearMonthDay                     = @"yyyyMMdd";
static NSString *const def_YearMonthDay_DF                  = @"yyyy-MM-dd";
static NSString *const def_MonthDayChn_DFSELFTRIP           = @"yyyy-MM-dd";
static NSString *const def_YearMonthDayHourMinute           = @"yyyy-M-d HH:mm";
static NSString *const def_WeekYearMonthDay_DF              = @"EE yyyy-MM-dd";
static NSString *const def_Year1Month1Day                   = @"yyyy-M-d";
static NSString *const def_YearMonth                        = @"yyyy-MM";
static NSString *const def_HourMinuteSecond_DF              = @"HH:mm:ss";
static NSString *const def_HourMinute_DF                    = @"HH:mm";
static NSString *const def_MonthYear                        = @"MM/YY";
static NSString *const def_MonthDay_DF                      = @"MM/dd";
static NSString *const def_MonthDayPoint_DF                 = @"MM.dd";
static NSString *const def_MonthDayLine_DF                  = @"MM-dd";
static NSString *const def_JustWeek_DF                      = @"EE";
static NSString *const def_Month                            = @"M";
static NSString *const def_MonthDayHourMS_DF                = @"MM月d日 HH:mm";

@interface TCDateFormatter : NSObject

+ (NSString *)dateToTTTCustom:(NSDate *)_date;

+ (NSString *)dateToStringCustom:(NSDate *)date formatString:(NSString *)formatString;
+ (NSDate *)stringToDateCustom:(NSString *)dateString formatString:(NSString *)formatString;

@end
