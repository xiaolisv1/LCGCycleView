//
//  LCGCycleTableView.m
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/19.
//  Copyright © 2019 李传光. All rights reserved.
//

#import "LCGCycleTableView.h"
@interface LCGCycleTableView()<UITableViewDelegate ,UITableViewDataSource>
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
@property (nonatomic ,strong) UITableView * tableView ;
@property (nonatomic ,weak) NSTimer *timer;
//item总个数
@property (nonatomic ,assign) NSInteger totalItemsCount;
//是否可以自动滑动
@property (nonatomic ,assign) BOOL canAutoScroll;
@end
@implementation LCGCycleTableView

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self ;
}

-(instancetype)init{
    if (self = [super init]) {
        [self setUI];
    }
    return self ;
}

-(void)setUI{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
    if (@available(iOS 9.0, *)) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    } else {
        // Fallback on earlier versions
    }
    tableView.delegate = self ;
    tableView.dataSource = self ;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.estimatedRowHeight = 0 ;
    tableView.estimatedSectionFooterHeight = 0 ;
    tableView.estimatedSectionHeaderHeight = 0 ;
    [self addSubview:tableView];
    self.tableView = tableView ;
    self.canAutoScroll = YES ;
    self.autoScroll = YES ;
    self.timeInterval = 1 ;
    self.displacement = 0.5 ;
    self.changePageCount = 1 ;
}

-(void)reloadData{
    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _setingAutoScroll];
    });
}

-(void)layoutSubviews{
    [super layoutSubviews];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.frame = self.bounds ;
        [self _setingAutoScroll];
    });
}

-(void)_setingAutoScroll{
    if (self.totalItemsCount<=0 || !_tableView) {
        return ;
    }
    //实际内容的容量宽度
    CGFloat contentH = self.tableView.contentSize.height/3.0 ;
    
    if (contentH>=self.tableView.frame.size.height) {
        self.canAutoScroll = YES ;
        //计算后面的临界点
        _backValue = contentH * 2 ;
        //计算前面的临界点
        _frontValue = contentH - self.tableView.frame.size.height ;
        _backOffsetPoint = CGPointMake(0 ,contentH) ;
        _frontOffsetPoint = CGPointMake(0 ,contentH * 2) ;
        //设置初始偏移量 需在参数设置之后
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.totalItemsCount+1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [self setupTimer];
    }else{
        self.canAutoScroll = NO ;
        [self invalidateTimer];
        [self.tableView reloadData];
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
    if (self.canAutoScroll && self.autoScroll) {
        [self setupTimer];
    }
}

- (void)setupTimer
{
    [self invalidateTimer];
    // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    if (self.autoScroll) {
        if (_pagingEnabled && self.timeInterval<1) {
            self.timeInterval = 1 ;
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(_automaticScroll) userInfo:nil repeats:YES];
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
        NSArray * indexs = [self.tableView indexPathsForVisibleRows];
        indexs = [self inserSort:indexs] ;
        NSIndexPath * currentFirstIndexpath = indexs.firstObject ;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentFirstIndexpath.row+self.changePageCount inSection:currentFirstIndexpath.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + self.displacement)]  ;
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.canAutoScroll) {
        if (self.tableView.contentOffset.y>=_backValue) {
            [self.tableView setContentOffset:_backOffsetPoint]  ;
        }else if(self.tableView.contentOffset.y <= _frontValue){
            [self.tableView setContentOffset:_frontOffsetPoint]  ;
        }
    }
}

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier{
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier] ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.totalItemsCount = [self.dataSource cycleTableView:self tableView:tableView numberOfRowsInSection:section] ;
    if (self.canAutoScroll == NO) {
        return self.totalItemsCount ;
    }
    return self.totalItemsCount * 3 ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource cycleTableView:self tableView:tableView cellForRowAtIndexPath:[self indexTransformWithIndex:indexPath]] ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cycleTableView:tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate cycleTableView:self tableView:tableView heightForRowAtIndexPath:[self indexTransformWithIndex:indexPath]];
    }else{
        return 44 ;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cycleTableView:tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate cycleTableView:self tableView:tableView didSelectRowAtIndexPath:[self indexTransformWithIndex:indexPath]] ;
    }
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
