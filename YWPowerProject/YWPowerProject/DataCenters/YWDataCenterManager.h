//
//  YWDataCenterManager.h
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YWBookObject.h"
#import "VMovieKit.h"


typedef void(^YWBookRequestHandler)(NSArray *array, VMError *error);

@interface YWDataCenterManager : NSObject
+(YWDataCenterManager *)shareManager;
-(YWBookObject *)currentBook;
-(void)findBooksWithCompleteHandler:(YWBookRequestHandler)handler;
@end
