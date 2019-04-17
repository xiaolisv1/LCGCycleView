//
//  ViewController.m
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/17.
//  Copyright © 2019 李传光. All rights reserved.
//

#import "ViewController.h"
#import "LCGCycleCollectionView.h"
#import "CUCollectionViewCell.h"

@interface ViewController ()<LCGCycleCollectionViewDelegate ,LCGCycleCollectionViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 20;
    flowLayout.itemSize = CGSizeMake(100, 150) ;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    LCGCycleCollectionView * cv = [[LCGCycleCollectionView alloc]initWithFrame:CGRectMake(10, 200, self.view.frame.size.width - 20, 150) collectionViewLayout:flowLayout];
    cv.delegate = self ;
    cv.dataSource = self ;
    //    cv.autoScroll = NO ;
    //    cv.timeInterval = 0.1;
    //    cv.displacement = 1 ;
    [cv registerClass:[CUCollectionViewCell class] forCellWithReuseIdentifier:@"CUCollectionViewCell"] ;
    [self.view addSubview:cv] ;
}

-(NSInteger)cycleCollectionView:(LCGCycleCollectionView *)ycleCollectionView collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10 ;
}

- (__kindof UICollectionViewCell *)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CUCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CUCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell ;
}


@end
