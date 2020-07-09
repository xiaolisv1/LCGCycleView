# LCGCycleView
一个轻量级无限轮播的CollectionView和tableview，可以方便的设置自己的cell和数据源，可以自定义各种跑马灯，或者轮播效果。基于UICollectionView，UITableview的封装。
通过设置pagingEnabled可以实现分页滚动或者连续滚动效果
displacement和timeInterval控制滑动速度
![预览图加载失败](https://github.com/xiaolisv1/LCGCycleView/blob/master/%E9%A2%84%E8%A7%88.gif)

## usege demo
* init 
```objc
//-----collectionView 类型
LCGCycleCollectionView * cv = [[LCGCycleCollectionView alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 150)];
cv.itemSpacing = 20;
cv.itemSize = 100;
cv.isHorizontal = YES ;
cv.delegate = self ;
cv.dataSource = self ;
//       cv.autoScroll = NO ;
//    cv.displacement = 1 ;
cv.timeInterval = 0.02;
cv.displacement = 1 ;
cv.pagingEnabled = NO ;
cv.changePageCount = 1 ;
cv.tag = 1000 ;
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
### 实现相关代理，返回自己的cell即可
* delegate
```objc
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
```
### Contact
if you find bug，please pull reqeust me <br>
