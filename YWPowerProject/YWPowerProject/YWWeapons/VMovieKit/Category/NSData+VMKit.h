//
//  NSData+VMKit.h
//  VMovieKit
//
//  Created by 蒋正峰 on 16/1/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestCompleteHandler)(NSMutableData *requestData);

@interface NSData(VMKit)<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) NSMutableData *requestData;
@property (nonatomic, copy) RequestCompleteHandler requestHandler;
+(NSData *)dataWithContentOfURL:(NSString *)URL timeOut:(NSInteger)timeOut withError:(NSError **)error;
+(NSData *)dataWithContentOfURL:(NSString *)URL timeOut:(NSInteger)timeOut;
-(void)dataWithContentOfURL:(NSString *)URL timeOut:(NSInteger)timeOut cancelIdentifer:(NSString *)cancelId withCompleteHandler:(RequestCompleteHandler)handeler;
-(void)cancelTheRequestWithIdentifer:(NSString *)identifer;
@end
