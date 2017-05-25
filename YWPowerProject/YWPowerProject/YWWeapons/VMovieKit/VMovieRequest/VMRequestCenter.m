//
//  VMRequestCenter.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/2.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "VMRequestCenter.h"

@implementation VMRequestCenter

+(VMRequestCenter *)currentRequestCenter{
    
    static VMRequestCenter *requestCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestCenter = [[VMRequestCenter alloc]init];
    });
    return requestCenter;
}

-(id)init{
    
    self = [super init];
    if (self) {
        
        return self;
    }
    return nil;
}

-(void)test{
    

    
}





@end
