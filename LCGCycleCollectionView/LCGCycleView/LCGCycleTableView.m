//
//  LCGCycleTableView.m
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/19.
//  Copyright © 2019 李传光. All rights reserved.
//

#import "LCGCycleTableView.h"
@interface LCGCycleTableView()<UITableViewDelegate ,UITableViewDataSource>

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
    [self invalidateTimer];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)awakeFromNib{
    [super awakeFromNib] ;
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

-(instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        [self setUI];
    }
    return self;
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
    tableView.backgroundColor = UIColor.clearColor ;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.estimatedRowHeight = 0 ;
    tableView.estimatedSectionFooterHeight = 0 ;
    tableView.estimatedSectionHeaderHeight = 0 ;
    [tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil] ;
    [self addSubview:tableView];
    self.tableView = tableView ;
    self.canAutoScroll = YES ;
    self.autoScroll = YES ;
    self.timeInterval = 1 ;
    self.displacement = 0.5 ;
    self.changePageCount = 1 ;
    
}

-(void)reloadData{
    [self invalidateTimer];
    
    self.totalItemsCount = [self.dataSource cycleTableViewCellNumber:self] ;
    
    if (self.totalItemsCount<=0) {
        [_tableView reloadData] ;
        return ;
    }
    CGFloat ch = 0 ;
    self.canAutoScroll = NO ;
    for (int i = 0; i<self.totalItemsCount; i++) {
        if ([self.delegate respondsToSelector:@selector(cycleTableView:heightForRowAtIndex:)]) {
            ch = ch + [self.delegate cycleTableView:self heightForRowAtIndex:i] ;
        }else{
            ch = ch + 44 ;
        }
        if (ch >= self.tableView.frame.size.height) {
            self.canAutoScroll = YES ;
            break;
        }
    }
    
    
    if (self.canAutoScroll) {
        //设置初始偏移量 需在参数设置之后
        [self setupTimer];
    }else{
        [self invalidateTimer];
    }
    [self.tableView reloadData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds ;
    [self reloadData] ;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.tableView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            CGSize tableViewContentSize = [change[@"new"] CGSizeValue];
            CGSize oldTableViewContentSize = [change[@"old"] CGSizeValue];
            if (tableViewContentSize.height != oldTableViewContentSize.height) {
                if (self.canAutoScroll){
                    self.tableView.contentOffset = CGPointMake(0, tableViewContentSize.height / 3) ;
                }
            }
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
    if ([self.tableView numberOfRowsInSection:0] <= 0) {
        return;
    }
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
        //实际内容的容量宽度
        CGFloat contentH = self.tableView.contentSize.height/3.0 ;
        if (self.tableView.contentOffset.y>=contentH * 2) {
            [self.tableView setContentOffset:CGPointMake(0 ,contentH )]  ;
        }else if(self.tableView.contentOffset.y <= contentH - self.tableView.frame.size.height){
            [self.tableView setContentOffset:CGPointMake(0 ,contentH * 2 - self.tableView.frame.size.height)]  ;
        }
    }
}

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier{
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier] ;
    
}

- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier{
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier] ;
}

- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forCellIndex:(NSInteger)cellIndex{
    return [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:0]] ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.canAutoScroll == NO) {
        return self.totalItemsCount ;
    }
    return self.totalItemsCount * 3 ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource cycleTableView:self cellIndex:indexPath.row cellForRowAtIndex:[self indexTransformWithIndex:indexPath]] ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cycleTableView:heightForRowAtIndex:)]) {
        return [self.delegate cycleTableView:self heightForRowAtIndex:[self indexTransformWithIndex:indexPath]];
    }else{
        return 44 ;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cycleTableView:cellIndex:didSelectRowAtIndex:)]) {
        [self.delegate cycleTableView:self cellIndex:indexPath.row didSelectRowAtIndex:[self indexTransformWithIndex:indexPath]] ;
    }
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
