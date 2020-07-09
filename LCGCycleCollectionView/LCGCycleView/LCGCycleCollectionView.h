//
//  LCGCycleCollectionView.h
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/17.
//  Copyright © 2019 李传光. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LCGCycleCollectionView ;
@protocol LCGCycleCollectionViewDataSource <NSObject>
@required
//返回cell个数
- (NSInteger)cycleCollectionViewCellNumber:(LCGCycleCollectionView *)cycleCollectionView ;

//返回cell
- (__kindof UICollectionViewCell *)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView cellIndex:(NSInteger)cellIndex cellForItemAtIndex:(NSInteger)index;

@end

@protocol LCGCycleCollectionViewDelegate <NSObject>
@optional
//cell点击
- (void)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView cellIndex:(NSInteger)cellIndex didSelectItemAtIndex:(NSInteger)index;
//cell大小
- (CGSize)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndex:(NSInteger)index;

@end

@interface LCGCycleCollectionView : UIView

@property (nonatomic, weak, nullable) id <LCGCycleCollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <LCGCycleCollectionViewDataSource> dataSource;

/// item大小 如果是横向滑动就是item的宽度  如果是竖向滑动就是高度
@property (nonatomic ,assign)IBInspectable CGFloat itemSize ;
/// 是否是横向滑动
@property (nonatomic ,assign)IBInspectable BOOL isHorizontal ;
/// item间距
@property (nonatomic ,assign)IBInspectable CGFloat itemSpacing ;
/// 是否是分页滑动，默认是yes，no的话就是平滑滑动
@property (nonatomic ,assign)IBInspectable BOOL pagingEnabled;
//是否自动滑动
@property (nonatomic ,assign)IBInspectable BOOL autoScroll;
//定时器调用间隔 分页滑动 最小为1
@property (nonatomic ,assign)IBInspectable CGFloat timeInterval ;
//每次移动距离 默认0.5 如果是负数 方向相反;
@property (nonatomic ,assign)IBInspectable CGFloat displacement ;
//分页滑动的时候 每次改变的页数的数量 默认为1
@property (nonatomic ,assign)IBInspectable NSUInteger changePageCount ;
//注册UICollectionViewCell
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier ;
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forCellIndex:(NSInteger)cellIndex ;
//刷新
-(void)reloadData ;

//关闭定时器  （在页面消失的时候调用）
- (void)invalidateTimer ;

//开始定时器  （在页面显示的时候调用）
- (void)setupTimer ;
@end

NS_ASSUME_NONNULL_END
