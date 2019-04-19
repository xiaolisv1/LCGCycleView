# LCGCycleCollectionView
一个轻量级无限轮播的CollectionView和tableview，可以方便的设置自己的cell和数据源，可以自定义各种跑马灯，或者轮播效果。基于UICollectionView，UITableview的封装。
可以实现分页滚动和连续滚动效果

![预览图加载失败](https://github.com/xiaolisv1/LCGCycleView/blob/master/%E9%A2%84%E8%A7%88.gif)

## usege demo
* init 
```objc
//-----collectionView 类型
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

//-----tableView 类型
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
```
###实现相关代理，返回自己的cell即可
* delegate
```objc
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
```
### Contact
if you find bug，please pull reqeust me <br>
