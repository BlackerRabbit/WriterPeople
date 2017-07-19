//
//  YWReadController.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2017/1/17.
//  Copyright © 2017年 蒋正峰. All rights reserved.
//

#import "YWPowerProject-Swift.h"
#import "YWReadController.h"
#import "YWBookObject.h"
#import "VMCyclesScrollview.h"
#import "YWReadCell.h"


static NSString *const readCellReuseIdentifer = @"readCellReuseIdentifer";

@interface YWReadController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong, readwrite) NSArray *bookStrings;
@property (nonatomic, strong, readwrite) UICollectionView *mainCollectionView;
@end

@implementation YWReadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(void)builUIWithContent:(NSArray *)array{
    if (array == nil) {
        return;
    }
    self.bookStrings = array;
    [self.mainCollectionView reloadData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionview actions ------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.bookStrings.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [self.mainCollectionView dequeueReusableCellWithReuseIdentifier:@"haha" forIndexPath:indexPath];
    return cell;
}

#pragma mark - collectionview layout delegate ------

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return (CGSize){
        0,0
    };
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{


}



#pragma mark - lazy actions ------

-(UICollectionView *)mainCollectionView{
    if (_mainCollectionView == nil) {
        UICollectionViewLayout *layout = [[UICollectionViewLayout alloc]init];
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        [_mainCollectionView registerClass:[YWReadCell class] forCellWithReuseIdentifier:@"haha"];
    }
    return _mainCollectionView;
}

@end
