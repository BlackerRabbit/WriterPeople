//
//  NSDate+TCTStringFormatter.h
//  TCTravel_IPhone
//
//  Created by maxfong on 14-10-11.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (TCTStringFormatter)

- (NSString *)stringWithDateFormat:(NSString *)dateFormat;

/**
 *	@brief	按yyyy－MM－dd EE进行输出
 *
 *	@return	如果是昨天/今天/明天/后天 就显示 yyyy－MM－dd 昨天/今天/明天/后天
 不然则显示 yyyy－MM－dd EE
 */
- (NSString *)dateToTTTCustom;

/**
 * 计算指定时间与当前的时间差
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
- (NSString *)stringBeforeDate;

@end
