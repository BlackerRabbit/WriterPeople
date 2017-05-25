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
    NSString *path = [[NSBundle mainBundle]pathForResource:@"海涅" ofType:@"txt"];
    NSString *normal = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [VMTools dealWithregularString:normal];
    
    UILabel *label = [UILabel new];
    label.width = self.view.width - 40;
    label.height = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    label.text = normal;
    [label sizeToFit];
    

    YWBookObject *book = [YWBookObject bookWithPath:path];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    /*
    NSArray *array = [book loadBookWithPagesSimple];
    float xoffset = 10;
    for (NSAttributedString *str in book.attStringAry) {
        UILabel *bookLabel = [[UILabel alloc]initWithFrame:CGRectMake(xoffset, 40, self.view.width - 20, SCREEN_HEIGHT - 80)];
        bookLabel.numberOfLines = 0;
        NSString *attStr = str.string;
        NSAttributedString *finalAtt = [[NSAttributedString alloc]initWithString:attStr attributes:[book attDiconary]];
        bookLabel.attributedText = finalAtt;
        [scrollView addSubview:bookLabel];
        xoffset += self.view.width;
    }
    */
    
    [scrollView addSubview:label];
    scrollView.pagingEnabled = YES;
//    scrollView.contentSize = CGSizeMake(array.count * SCREEN_WIDTH, self.view.height);
    scrollView.contentSize = CGSizeMake(self.view.width, label.height + 20);
    NSTimeInterval time = [date timeIntervalSinceDate:date];
    NSLog(@"时间是%fld",time);
    
    label.top = 0;
    label.left = 20;
    
    
    
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
