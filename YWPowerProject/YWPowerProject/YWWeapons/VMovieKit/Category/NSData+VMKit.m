//
//  NSData+VMKit.m
//  VMovieKit
//
//  Created by 蒋正峰 on 16/1/21.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "NSData+VMKit.h"
#import <objc/runtime.h>
#import "NSString+VMKit.h"

static void *mapTableKey =  (void *)@"mapTableKey";
static void *requestDataKey = (void *)@"requestDataKey";
static void *requestHandlerKey = (void *)@"requestHandlerKey";


@implementation NSData(VMKit)


-(void)setRequestData:(NSMutableData *)requestData{
    
    objc_setAssociatedObject(self, &requestDataKey, requestData, OBJC_ASSOCIATION_RETAIN);
}

-(NSMutableData *)requestData{
    NSMutableData *requestData = objc_getAssociatedObject(self, &requestDataKey);
    return requestData;
}

-(void)setMapTable:(NSMapTable *)mapTable{
    objc_setAssociatedObject(self, mapTableKey, mapTable, OBJC_ASSOCIATION_RETAIN);
}

-(NSMapTable *)mapTable{
    NSMapTable *mapTable = objc_getAssociatedObject(self, mapTableKey);
    return mapTable;
}

-(void)setRequestHandler:(RequestCompleteHandler)requestHandler{
    objc_setAssociatedObject(self, requestHandlerKey, requestHandler, OBJC_ASSOCIATION_COPY);
}

-(RequestCompleteHandler )requestHandler{
    RequestCompleteHandler requestHandler = objc_getAssociatedObject(self, requestHandlerKey);
    return requestHandler;
}

+(NSData *)dataWithContentOfURL:(NSString *)URL timeOut:(NSInteger)timeOut withError:(NSError **)error{
    
    
    
    NSString *urlStr = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeOut];
    return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
}

+(NSData *)dataWithContentOfURL:(NSString *)URL timeOut:(NSInteger)timeOut{
    
    NSString *urlStr = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeOut];
    return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

-(void)dataWithContentOfURL:(NSString *)URL timeOut:(NSInteger)timeOut cancelIdentifer:(NSString *)cancelId withCompleteHandler:(RequestCompleteHandler)handeler{
    
    self.mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    if (handeler) {
        self.requestHandler = handeler;
    }
    self.requestData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeOut];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if ([cancelId isValid]) {
        [self.mapTable setObject:connection forKey:cancelId];
    }
    [connection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if (self.requestData == nil) {
        self.requestData = [NSMutableData data];
    }
//    [self.requestData setLength:0];
    [self.requestData resetBytesInRange:NSMakeRange(0, self.requestData.length)];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (data != nil && data.length > 0) {
        [self.requestData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.requestData setLength:0];
    self.requestData = nil;
    self.requestHandler(self.requestData);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.requestHandler(self.requestData);
}

-(void)cancelTheRequestWithIdentifer:(NSString *)identifer{
    if ([self.mapTable objectForKey:identifer]) {
        NSURLConnection *connection = [self.mapTable objectForKey:identifer];
        if (connection) {
            [connection cancel];
        }
    }
}

@end
