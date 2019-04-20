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
    CGFloat _backValue ;
    //前面的临界点
    CGFloat _frontValue ;
    //滑动到后面的临界点偏移量设置值
    CGPoint _backOffsetPoint ;
    //滑动到前面的临界点偏移量设置值
    CGPoint _frontOffsetPoint ;
    
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
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)flowLayout{
    if (self = [super initWithFrame:frame]) {
        self.flowLayout = flowLayout ;
        UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.scrollsToTop = NO;
        [self addSubview:collectionView];
        self.collectionView = collectionView ;
        self.canAutoScroll = YES ;
        self.autoScroll = YES ;
        self.timeInterval = 1 ;
        self.displacement = 0.5 ;
        self.changePageCount = 1 ;
    }
    return self ;
}

-(void)reloadData{
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _setingAutoScroll];
    });
}

-(void)layoutSubviews{
    [super layoutSubviews];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.collectionView.frame = self.bounds ;
        [self _setingAutoScroll];
    });
}

-(void)_setingAutoScroll{
    if (self.totalItemsCount<=0 || !self.collectionView) {
        return ;
    }
    //实际内容的容量宽度
    CGFloat contentW = (self.collectionView.contentSize.width - self.flowLayout.minimumLineSpacing * 2)/3.0 ;
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        if (contentW>=self.collectionView.frame.size.width) {
            self.canAutoScroll = YES ;
            
            //计算后面的临界点
            _backValue = contentW * 2 + self.flowLayout.minimumLineSpacing*2 ;
            //计算前面的临界点
            _frontValue = contentW + self.flowLayout.minimumLineSpacing - self.collectionView.frame.size.width ;
            
            _backOffsetPoint = CGPointMake(contentW + self.flowLayout.minimumLineSpacing, 0) ;
            _frontOffsetPoint = CGPointMake(contentW * 2 + self.flowLayout.minimumLineSpacing, 0) ;
            //设置初始偏移量
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.totalItemsCount inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            [self setupTimer];
            
        }else{
            self.canAutoScroll = NO ;
            [self invalidateTimer];
            [self.collectionView reloadData];
        }
    }else{
        if (contentW>=self.collectionView.frame.size.height) {
            self.canAutoScroll = YES ;
            
            //实际内容的容量高度
            CGFloat contentH = (self.collectionView.contentSize.height - self.flowLayout.minimumInteritemSpacing * 2)/3.0 ;
            //计算后面的临界点
            _backValue = contentH * 2 + self.flowLayout.minimumInteritemSpacing*2 ;
            //计算前面的临界点
            _frontValue = contentH + self.flowLayout.minimumInteritemSpacing - self.collectionView.frame.size.height ;
            _backOffsetPoint = CGPointMake(0, contentH + self.flowLayout.minimumInteritemSpacing) ;
            _frontOffsetPoint = CGPointMake(0, contentH * 2 + self.flowLayout.minimumInteritemSpacing) ;
            
            //设置初始偏移量 需在参数设置之后
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.totalItemsCount inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            
              [self setupTimer];
        }else{
            self.canAutoScroll = NO ;
            [self invalidateTimer];
            [self.collectionView reloadData];
        }
    }
    
}

#pragma mark - 插入升序排序
- (NSArray *)inserSort:(NSArray *)array
{
    NSMutableArray * returnArray = [NSMutableArray arrayWithArray:array] ;
    for (NSInteger i = 1; i < returnArray.count; i ++) {
        NSIndexPath *temp = returnArray[i];
        for (NSInteger j = i - 1; j >= 0 && temp.row < [returnArray[j] row]; j --) {
            returnArray[j + 1] = returnArray[j];
            returnArray[j] = temp ;
        }
    }
    return returnArray ;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.canAutoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.canAutoScroll && _autoScroll) {
        [self setupTimer];
    }
}

- (void)setupTimer
{
    [self invalidateTimer];
    // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    if (_autoScroll && _backValue>0) {
        if (_pagingEnabled && _timeInterval<1) {
            _timeInterval = 1 ;
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(_automaticScroll) userInfo:nil repeats:YES];
        _timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)_automaticScroll
{
    if (_pagingEnabled) {
        NSArray * indexs = [self.collectionView indexPathsForVisibleItems];
        indexs = [self inserSort:indexs] ;
        NSIndexPath * currentFirstIndexpath = indexs.firstObject ;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentFirstIndexpath.row+self.changePageCount inSection:currentFirstIndexpath.section]  atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }else{
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + _displacement, 0)]  ;
        }else{
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + _displacement)]  ;
        }
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.canAutoScroll) {
        CGFloat contentoffset = 0;
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            contentoffset = self.collectionView.contentOffset.x ;
        }else{
            contentoffset = self.collectionView.contentOffset.y ;
        }
        if (contentoffset>=_backValue) {
            [self.collectionView setContentOffset:_backOffsetPoint]  ;
        }else if(contentoffset <= _frontValue){
            [self.collectionView setContentOffset:_frontOffsetPoint]  ;
        }
    }
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier] ;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    self.totalItemsCount = [self.dataSource cycleCollectionView:self collectionView:collectionView numberOfItemsInSection:section] ;
    if (self.canAutoScroll == NO) {
        return self.totalItemsCount ;
    }
    return self.totalItemsCount * 3 ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource cycleCollectionView:self collectionView:collectionView cellForItemAtIndexPath:[self indexTransformWithIndex:indexPath]] ;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(cycleCollectionView:collectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate cycleCollectionView:self collectionView:collectionView didSelectItemAtIndexPath:[self indexTransformWithIndex:indexPath]] ;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(cycleCollectionView:collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [self.delegate cycleCollectionView:self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:[self indexTransformWithIndex:indexPath]] ;
    }
    return self.flowLayout.itemSize ;
}

-(NSIndexPath *)indexTransformWithIndex:(NSIndexPath *)indexPath{
    NSIndexPath * newIndexPath ;
    if (self.canAutoScroll == NO) {
        newIndexPath = indexPath ;
    }else{
        if (self.totalItemsCount*2>indexPath.row && indexPath.row>= self.totalItemsCount) {
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - self.totalItemsCount inSection:0] ;
        }else if(self.totalItemsCount>indexPath.row){
            newIndexPath = indexPath ;
        }else{
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - self.totalItemsCount * 2 inSection:0] ;
        }
    }
    return newIndexPath ;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
