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
@interface ViewController ()<LCGCycleCollectionViewDelegate ,LCGCycleCollectionViewDataSource ,LCGCycleTableViewDelegate ,LCGCycleTableViewDataSource >
{
    LCGCycleTableView *tableView ;
    NSInteger tableViewCount ;
    
    LCGCycleCollectionView *collectionView ;
    NSInteger collectionViewCount ;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//     Do any additional setup after loading the view.
   
    LCGCycleCollectionView * cv = [[LCGCycleCollectionView alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 150)];
    cv.itemSpacing = 20;
    cv.itemSize = 100;
    cv.isHorizontal = YES ;
    cv.delegate = self ;
    cv.dataSource = self ;
//        cv.autoScroll = NO ;
    //    cv.displacement = 1 ;
    cv.timeInterval = 0.02;
    cv.displacement = 1 ;
    cv.pagingEnabled = NO ;
    cv.changePageCount = 1 ;
    cv.tag = 1000 ;
    [cv registerClass:[CUCollectionViewCell class] forCellWithReuseIdentifier:@"CUCollectionViewCell"] ;
    [self.view addSubview:cv] ;
    collectionView = cv ;
    collectionViewCount = 50 ;
    
    
    LCGCycleTableView * tv = [[LCGCycleTableView alloc]initWithFrame:CGRectMake(10, 300, self.view.frame.size.width - 20, 120)] ;
    tv.delegate = self ;
    tv.dataSource = self ;
    //    cv.autoScroll = NO ;
    //    cv.displacement = 1 ;
    tv.timeInterval = 1;
    tv.pagingEnabled = YES ;
    tv.changePageCount = 1 ;
    tv.tag = 1001 ;
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"] ;
    [self.view addSubview:tv] ;
    tableView = tv ;
    tableViewCount = 50;
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    collectionViewCount = arc4random()% 20;
    NSLog(@"*-*-*-*-*-**-*-*-*-   %ld" , (long)collectionViewCount);
    LCGCycleCollectionView * cv = [self.view viewWithTag:1000] ;
    [cv reloadData];
    
    tableViewCount = arc4random()% 20;
    NSLog(@"*-*-*-*-*-**-*-*-*-22   %ld" , (long)tableViewCount);
    LCGCycleTableView * tv = [self.view viewWithTag:1001] ;
    [tv reloadData] ;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LCGCycleCollectionView * cv = [self.view viewWithTag:1000] ;
    LCGCycleTableView * tv = [self.view viewWithTag:1001] ;
    [cv setupTimer];
    [tv setupTimer];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    LCGCycleCollectionView * cv = [self.view viewWithTag:1000] ;
    LCGCycleTableView * tv = [self.view viewWithTag:1001] ;
    [cv invalidateTimer];
    [tv invalidateTimer];
}

//LCGCycleCollectionView  dataSource

-(NSInteger)cycleCollectionViewCellNumber:(LCGCycleCollectionView *)cycleCollectionView{
    return collectionViewCount;
}

- (__kindof UICollectionViewCell *)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView cellIndex:(NSInteger)cellIndex cellForItemAtIndex:(NSInteger)index{
    CUCollectionViewCell * cell = [cycleCollectionView dequeueReusableCellWithReuseIdentifier:@"CUCollectionViewCell" forCellIndex:cellIndex];
    cell.backgroundColor = [UIColor blueColor];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)index];
    return cell ;
}

//LCGCycleTableView dataSource
-(NSInteger)cycleTableViewCellNumber:(LCGCycleTableView *)cycleTableView{
    return tableViewCount ;
}

-(UITableViewCell *)cycleTableView:(LCGCycleTableView *)cycleTableView cellIndex:(NSInteger)cellIndex cellForRowAtIndex:(NSInteger)index{
    UITableViewCell * cell = [cycleTableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forCellIndex:cellIndex];
    if (index%3 == 0) {
        cell.backgroundColor = [UIColor redColor] ;
    }else if (index%3 == 1){
        cell.backgroundColor = [UIColor greenColor] ;
    }else{
        cell.backgroundColor = [UIColor blueColor] ;
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter ;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20] ;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)index];
    return cell ;
}

@end
