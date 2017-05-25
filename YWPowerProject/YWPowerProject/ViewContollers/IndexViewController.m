//
//  IndexViewController.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/20.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "IndexViewController.h"
#import "YWDataCenterManager.h"
#import "YWBookObject.h"

@interface IndexViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong, readwrite) NSMutableArray *dataAry;
@property (nonatomic, strong, readwrite) UITableView *mainTableView;
@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mainTableView];
    
    YWDataCenterManager *dataCenter = [YWDataCenterManager shareManager];
    
    
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
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UITableViewCell new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - lazy actions -----

//TODO: lazy actions

-(UITableView *)mainTableView{
    if (_mainTableView == nil) {
        
        _mainTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
    }
    return _mainTableView;
}


@end
