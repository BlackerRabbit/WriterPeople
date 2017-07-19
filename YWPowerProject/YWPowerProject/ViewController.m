//
//  ViewController.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/1.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "VMovieKit.h"
#import "SWWeiBoEmotionManager.h"
#import "SWWeiBoAttObj.h"

#import "TestViewController.h"
#import "YWBookObject.h"
#import "YWReadView.h"



#define APPKEYFORWEIBOPLATFORM @"1464649506"
#define APPSECRETFORWEIBOPLATFORM @"451cfed0ec4b661bd5809b9ac53834a6"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong, readwrite) UITableView *mainTB;
@property (nonatomic, strong, readwrite) NSMutableArray *dataAry;


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    NSDate *date = [NSDate date];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"沙僧" ofType:@"txt"];
    NSString *normal = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    normal = [VMTools dealWithregularString:normal];
    YWBookObject *book = [YWBookObject bookWithPath:path];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];

    float xoffset = 20;
    for (NSValue *value in book.pageArray) {
        NSRange range = [value rangeValue];
        NSString *word = [book.words substringWithRange:range];
        
        YWReadView *readView = [[YWReadView alloc]initWithFrame:BOOK_DRAW_RECT];
        readView.left = xoffset;
        readView.top = 40;
        readView.content = word;
        [scrollView addSubview:readView];
        xoffset += self.view.width;
        readView.backgroundColor = [UIColor whiteColor];
        readView.backgroundColor = [UIColor lightGrayColor];
    }
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(book.pageArray.count * SCREEN_WIDTH, self.view.height);
    NSTimeInterval time = [date timeIntervalSinceDate:date];
    NSLog(@"时间是%fld",time);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- tableview datasource and delegate------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataAry.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UITableViewCell new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mrak - lazying actions ------

-(UITableView *)mainTB{
    if (_mainTB == nil) {
        _mainTB = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTB.delegate = self;
        _mainTB.dataSource = self;
    }
    return _mainTB;
}



@end
