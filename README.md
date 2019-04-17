# LCGCycleCollectionView
一个轻量级无限轮播的CollectionView，可以方便的设置自己的cell和数据源


### usege demo

* init 
```objc
UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
flowLayout.minimumLineSpacing = 20;
flowLayout.itemSize = CGSizeMake(100, 150) ;
flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
LCGCycleCollectionView * cv = [[LCGCycleCollectionView alloc]initWithFrame:CGRectMake(10, 200, self.view.frame.size.width - 20, 150) collectionViewLayout:flowLayout];
cv.delegate = self ;
cv.dataSource = self ;
[cv registerClass:[CUCollectionViewCell class] forCellWithReuseIdentifier:@"CUCollectionViewCell"] ;
[self.view addSubview:cv] ;
```
* delegate
```objc
-(NSInteger)cycleCollectionView:(LCGCycleCollectionView *)ycleCollectionView collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10 ;
}

- (__kindof UICollectionViewCell *)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CUCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CUCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell ;
}
```
### Contact
if you find bug，please pull reqeust me <br>
