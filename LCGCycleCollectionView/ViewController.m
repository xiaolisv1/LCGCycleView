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
#import "LCGCycleTableView.h"
@interface ViewController ()<LCGCycleCollectionViewDelegate ,LCGCycleCollectionViewDataSource ,LCGCycleTableViewDelegate ,LCGCycleTableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 20;
    flowLayout.itemSize = CGSizeMake(100, 150) ;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    LCGCycleCollectionView * cv = [[LCGCycleCollectionView alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 150) collectionViewLayout:flowLayout];
    cv.delegate = self ;
    cv.dataSource = self ;
    //    cv.autoScroll = NO ;
    //    cv.displacement = 1 ;
    cv.timeInterval = 1;
    cv.pagingEnabled = YES ;
    cv.changePageCount = 1 ;
    [cv registerClass:[CUCollectionViewCell class] forCellWithReuseIdentifier:@"CUCollectionViewCell"] ;
    [self.view addSubview:cv] ;
    
    
    
    LCGCycleTableView * tv = [[LCGCycleTableView alloc]initWithFrame:CGRectMake(10, 300, self.view.frame.size.width - 20, 120)] ;
    tv.delegate = self ;
    tv.dataSource = self ;
    //    cv.autoScroll = NO ;
    //    cv.displacement = 1 ;
    tv.timeInterval = 1;
    tv.pagingEnabled = YES ;
    tv.changePageCount = 1 ;
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"] ;
    [self.view addSubview:tv] ;
        
}

//LCGCycleCollectionView  dataSource
-(NSInteger)cycleCollectionView:(LCGCycleCollectionView *)ycleCollectionView collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10 ;
}

- (__kindof UICollectionViewCell *)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CUCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CUCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell ;
}

//LCGCycleTableView dataSource
-(NSInteger)cycleTableView:(LCGCycleTableView *)cycleTableView tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10 ;
}

-(UITableViewCell *)cycleTableView:(LCGCycleTableView *)cycleTableView tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (indexPath.row%3 == 0) {
        cell.backgroundColor = [UIColor redColor] ;
    }else if (indexPath.row%3 == 1){
        cell.backgroundColor = [UIColor greenColor] ;
    }else{
        cell.backgroundColor = [UIColor blueColor] ;
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter ;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20] ;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell ;
}

@end
