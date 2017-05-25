//
//  YWDataCenterManager.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "YWDataCenterManager.h"

@implementation YWDataCenterManager

+(YWDataCenterManager *)shareManager{
    static YWDataCenterManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YWDataCenterManager alloc]init];
    });
    return manager;
}

-(id)init{

    self = [super init];
    return self;
}


-(void)findBooksWithCompleteHandler:(YWBookRequestHandler)handler{
    

}




@end
