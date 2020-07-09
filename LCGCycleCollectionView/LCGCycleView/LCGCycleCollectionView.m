//
//  LCGCycleCollectionView.m
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/17.
//  Copyright © 2019 李传光. All rights reserved.
//

#import "LCGCycleCollectionView.h"
@interface LCGCycleCollectionView ()<UICollectionViewDataSource ,UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout>

@property (nonatomic ,weak) NSTimer *timer;
@property (nonatomic ,strong) UICollectionViewFlowLayout *flowLayout;
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

-(UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
         _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (void)awakeFromNib{
    [super awakeFromNib];    
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
        self.isHorizontal = YES ;
        self.itemSpacing = 5 ;
        self.canAutoScroll = YES ;
        self.autoScroll = YES ;
        self.timeInterval = 1 ;
        self.displacement = 0.5 ;
        self.changePageCount = 1 ;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        [self setupUI];
        
        self.isHorizontal = YES ;
        self.itemSpacing = 5 ;
        self.canAutoScroll = YES ;
        self.autoScroll = YES ;
        self.timeInterval = 1 ;
        self.displacement = 0.5 ;
        self.changePageCount = 1 ;
    }
    return self;
}

-(void)setupUI{
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollsToTop = NO;
    collectionView.frame = self.bounds ;
    [self addSubview:collectionView];
    self.collectionView = collectionView ;
    
}

-(void)setItemSize:(CGFloat)itemSize{
    _itemSize = itemSize ;
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        self.flowLayout.itemSize = CGSizeMake(itemSize, self.frame.size.height) ;
    }else{
        self.flowLayout.itemSize = CGSizeMake(self.frame.size.width, itemSize) ;
    }
}

-(void)setIsHorizontal:(BOOL)isHorizontal{
    _isHorizontal = isHorizontal ;
    if (_isHorizontal) {
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    }else{
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical ;
    }
}


-(void)reloadData{
    [self invalidateTimer] ;
    self.totalItemsCount = [self.dataSource cycleCollectionViewCellNumber:self] ;
    
    if (self.totalItemsCount<=0) {
        [_collectionView reloadData] ;
        return ;
    }
    CGFloat ch = 0 ;
    self.canAutoScroll = NO ;
    for (int i = 0; i<self.totalItemsCount; i++) {
        
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal){
            if ([self.delegate respondsToSelector:@selector(cycleCollectionView:layout:sizeForItemAtIndex:)]){
                ch = ch + [self.delegate cycleCollectionView:self layout:self.flowLayout sizeForItemAtIndex:i] ;
            }else{
                ch = ch + self.flowLayout.itemSize.width ;
            }
            if (ch >= self.collectionView.frame.size.width) {
                self.canAutoScroll = YES ;
                break;
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(cycleCollectionView:layout:sizeForItemAtIndex:)]) {
                ch = ch + [self.delegate cycleCollectionView:self layout:self.flowLayout sizeForItemAtIndex:i] ;
            }else{
                ch = ch + self.flowLayout.itemSize.height ;
            }
            if (ch >= self.collectionView.frame.size.height) {
                self.canAutoScroll = YES ;
                break;
            }
        }
        
    }
    
    [self.collectionView reloadData];
    
    if (self.canAutoScroll) {
        [self setupTimer];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(afterDelayHandle) object:nil];
        [self performSelector:@selector(afterDelayHandle) withObject:nil afterDelay:0.2] ;
    }else{
        [self invalidateTimer];
    }
}

-(void)afterDelayHandle{
    //设置初始偏移量
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.totalItemsCount inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }else{
        //设置初始偏移量 需在参数设置之后
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.totalItemsCount inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds ;
    if (_isHorizontal) {
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    }else{
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical ;
    }
    
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal){
        self.flowLayout.itemSize = CGSizeMake(self.itemSize, self.collectionView.frame.size.height) ;
    }else{
        self.flowLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.itemSize) ;
    }
    
    [self reloadData] ;
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
    
    if (_autoScroll) {
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
        
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            if (self.collectionView.contentSize.width >= self.collectionView.frame.size.width) {
                NSArray * indexs = [self.collectionView indexPathsForVisibleItems];
                indexs = [self inserSort:indexs] ;
                NSIndexPath * currentFirstIndexpath = indexs.firstObject ;
                
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentFirstIndexpath.row+self.changePageCount inSection:currentFirstIndexpath.section]  atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            }
        }else{
            if (self.collectionView.contentSize.height >= self.collectionView.frame.size.height) {
                NSArray * indexs = [self.collectionView indexPathsForVisibleItems];
                indexs = [self inserSort:indexs] ;
                NSIndexPath * currentFirstIndexpath = indexs.firstObject ;
                
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentFirstIndexpath.row+self.changePageCount inSection:currentFirstIndexpath.section]  atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        }
                
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
        CGFloat contentValue = 0 ;
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            contentoffset = self.collectionView.contentOffset.x ;
            contentValue = self.collectionView.contentSize.width/3.0 ;
            
            if (contentoffset>=contentValue*2) {
                [self.collectionView setContentOffset:CGPointMake(contentValue ,0 )]  ;
            }else if(contentoffset <= contentValue - self.collectionView.frame.size.width){
                [self.collectionView setContentOffset:CGPointMake(contentValue * 2 -  self.collectionView.frame.size.width , 0)]  ;
            }
        }else{
            contentoffset = self.collectionView.contentOffset.y ;
            contentValue = self.collectionView.contentSize.height/3.0 ;
            
            if (contentoffset>=contentValue*2) {
                [self.collectionView setContentOffset:CGPointMake(0 ,contentValue )]  ;
            }else if(contentoffset <= contentValue - self.collectionView.frame.size.height){
                [self.collectionView setContentOffset:CGPointMake(0 ,contentValue * 2 -  self.collectionView.frame.size.height)]  ;
            }
        }
    
    }
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier] ;
}

- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forCellIndex:(NSInteger)cellIndex{
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]] ;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.canAutoScroll == NO) {
        return self.totalItemsCount ;
    }
    return self.totalItemsCount * 3 ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource cycleCollectionView:self cellIndex:indexPath.row cellForItemAtIndex:[self indexTransformWithIndex:indexPath]] ;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(cycleCollectionView:cellIndex:didSelectItemAtIndex:)]) {
        [self.delegate cycleCollectionView:self cellIndex:indexPath.row didSelectItemAtIndex:[self indexTransformWithIndex:indexPath]] ;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(cycleCollectionView:layout:sizeForItemAtIndex:)]) {
        CGFloat value = [self.delegate cycleCollectionView:self layout:collectionViewLayout sizeForItemAtIndex:[self indexTransformWithIndex:indexPath]];
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal){
            return CGSizeMake(value, collectionView.frame.size.height);
        }else{
            return CGSizeMake(collectionView.frame.size.width, value);
        }
    }
    return self.flowLayout.itemSize ;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        return _itemSpacing;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (self.flowLayout.scrollDirection != UICollectionViewScrollDirectionHorizontal) {
        return _itemSpacing;
    }
    return 0;
}

-(NSInteger)indexTransformWithIndex:(NSIndexPath *)indexPath{
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
    return newIndexPath.row ;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
