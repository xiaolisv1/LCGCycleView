//
//  LCGCycleCollectionView.m
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/17.
//  Copyright © 2019 李传光. All rights reserved.
//

#import "LCGCycleCollectionView.h"
@interface LCGCycleCollectionView ()<UICollectionViewDataSource ,UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout>
{
    //后面的临界点
    CGFloat backValue ;
    //前面的临界点
    CGFloat frontValue ;
    //滑动到后面的临界点偏移量设置值
    CGPoint backOffsetPoint ;
    //滑动到前面的临界点偏移量设置值
    CGPoint frontOffsetPoint ;
}
@property (nonatomic ,weak) NSTimer *timer;
@property (nonatomic ,weak) UICollectionViewFlowLayout *flowLayout;
//item总个数
@property (nonatomic ,assign) NSInteger totalItemsCount;
//是否可以自动滑动
@property (nonatomic ,assign) BOOL canAutoScroll;
@property (nonatomic ,strong) UICollectionView * collectionView ;
@end
@implementation LCGCycleCollectionView

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)flowLayout{
    if (self = [super initWithFrame:frame]) {
        _flowLayout = flowLayout ;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollsToTop = NO;
        [self addSubview:_collectionView];
        _canAutoScroll = YES ;
        _autoScroll = YES ;
        _timeInterval = 0.01 ;
        _displacement = 0.5 ;
    }
    return self ;
}

-(void)reloadData{
    [_collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setAutoScrollState];
    });
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _collectionView.frame = self.bounds ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setAutoScrollState];
    });
}

-(void)setAutoScrollState{
    if (_totalItemsCount<=0) {
        return ;
    }
    
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        if (self.collectionView.contentSize.width>=self.collectionView.frame.size.width) {
            _canAutoScroll = YES ;
            //设置初始偏移量
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_totalItemsCount inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            //实际内容的容量宽度
            CGFloat contentW = (self.collectionView.contentSize.width - self.flowLayout.minimumLineSpacing * 2)/3.0 ;
            //计算后面的临界点
            backValue = contentW * 2 + self.flowLayout.minimumLineSpacing*2 ;
            //计算前面的临界点
            frontValue = contentW + self.flowLayout.minimumLineSpacing - self.collectionView.frame.size.width ;
            
            backOffsetPoint = CGPointMake(contentW + self.flowLayout.minimumLineSpacing, 0) ;
            frontOffsetPoint = CGPointMake(contentW * 2 + self.flowLayout.minimumLineSpacing, 0) ;
            [self setupTimer];
        }else{
            _canAutoScroll = NO ;
            [self invalidateTimer];
            [self.collectionView reloadData];
        }
    }else{
        if (self.collectionView.contentSize.height>=self.collectionView.frame.size.height) {
            _canAutoScroll = YES ;
            //设置初始偏移量
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_totalItemsCount inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            //实际内容的容量高度
            CGFloat contentH = (self.collectionView.contentSize.height - self.flowLayout.minimumInteritemSpacing * 2)/3.0 ;
            //计算后面的临界点
            backValue = contentH * 2 + self.flowLayout.minimumInteritemSpacing*2 ;
            //计算前面的临界点
            frontValue = contentH + self.flowLayout.minimumInteritemSpacing - self.collectionView.frame.size.height ;
            
            backOffsetPoint = CGPointMake(0, contentH + self.flowLayout.minimumInteritemSpacing) ;
            frontOffsetPoint = CGPointMake(0, contentH * 2 + self.flowLayout.minimumInteritemSpacing) ;
              [self setupTimer];
        }else{
            _canAutoScroll = NO ;
            [self invalidateTimer];
            [self.collectionView reloadData];
        }
    }
    
}

-(void)setTimeInterval:(NSTimeInterval)timeInterval{
    _timeInterval = timeInterval ;
    if (_canAutoScroll && _autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_canAutoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_canAutoScroll && _autoScroll) {
        [self setupTimer];
    }
}

- (void)setupTimer
{
    [self invalidateTimer];
    // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    if (_autoScroll) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
        _timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll
{
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + _displacement, 0)]  ;
    }else{
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + _displacement)]  ;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_canAutoScroll) {
        CGFloat contentoffset = 0;
        if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            contentoffset = self.collectionView.contentOffset.x ;
        }else{
            contentoffset = self.collectionView.contentOffset.y ;
        }
        if (contentoffset>=backValue) {
            [self.collectionView setContentOffset:backOffsetPoint]  ;
        }else if(contentoffset <= frontValue){
            [self.collectionView setContentOffset:frontOffsetPoint]  ;
        }
    }
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier] ;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    _totalItemsCount = [self.dataSource cycleCollectionView:self collectionView:collectionView numberOfItemsInSection:section] ;
    if (_canAutoScroll == NO) {
        return _totalItemsCount ;
    }
    return _totalItemsCount * 3 ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_canAutoScroll == NO) {
        return [self.dataSource cycleCollectionView:self collectionView:collectionView cellForItemAtIndexPath:indexPath] ;
    }else{
        if (_totalItemsCount*2>indexPath.row && indexPath.row>= _totalItemsCount) {
            return [self.dataSource cycleCollectionView:self collectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - _totalItemsCount inSection:0]] ;
        }else if(_totalItemsCount>indexPath.row){
            return [self.dataSource cycleCollectionView:self collectionView:collectionView cellForItemAtIndexPath:indexPath] ;
        }else{
            return [self.dataSource cycleCollectionView:self collectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - _totalItemsCount * 2 inSection:0]] ;
        }
    }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    NSIndexPath * newIndexPath ;
    if (_canAutoScroll == NO) {
        newIndexPath = indexPath ;
    }else{
        if (_totalItemsCount*2>indexPath.row && indexPath.row>= _totalItemsCount) {
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - _totalItemsCount inSection:0] ;
        }else if(_totalItemsCount>indexPath.row){
            newIndexPath = indexPath ;
        }else{
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - _totalItemsCount * 2 inSection:0] ;
        }
    }
    
    
    if ([self.delegate respondsToSelector:@selector(cycleCollectionView:collectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate cycleCollectionView:self collectionView:collectionView didSelectItemAtIndexPath:newIndexPath] ;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath * newIndexPath ;
    if (_canAutoScroll == NO) {
        newIndexPath = indexPath ;
    }else{
        if (_totalItemsCount*2>indexPath.row && indexPath.row>= _totalItemsCount) {
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - _totalItemsCount inSection:0] ;
        }else if(_totalItemsCount>indexPath.row){
            newIndexPath = indexPath ;
        }else{
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - _totalItemsCount * 2 inSection:0] ;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(cycleCollectionView:collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [self.delegate cycleCollectionView:self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:newIndexPath] ;
    }
    return self.flowLayout.itemSize ;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
