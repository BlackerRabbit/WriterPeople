//
//  SWWeiBoDataManager.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/15.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWWeiBoAttObj : NSObject




-(NSMutableAttributedString *)attStringFrom:(NSDictionary *)infoDic withLocation:(BOOL)location completeHandler:(void(^)(NSMutableAttributedString *att, BOOL needUpdate,NSError *error))handler;


-(NSAttributedString *)attStringFrom:(NSDictionary *)infoDic hasLocation:(BOOL)location;


@end
