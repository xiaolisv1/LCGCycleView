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
- (NSInteger)cycleCollectionView:(LCGCycleCollectionView *)ycleCollectionView collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

//返回cell
- (__kindof UICollectionViewCell *)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol LCGCycleCollectionViewDelegate <NSObject>
@optional
//cell点击
- (void)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//cell大小
- (CGSize)cycleCollectionView:(LCGCycleCollectionView *)cycleCollectionView collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LCGCycleCollectionView : UIView
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)flowLayout ;
@property (nonatomic, weak, nullable) id <LCGCycleCollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <LCGCycleCollectionViewDataSource> dataSource;
//是否自动滑动
@property (nonatomic ,assign) BOOL autoScroll;
//定时器调用间隔 默认0.01
@property (nonatomic ,assign) NSTimeInterval timeInterval ;
//每次移动距离 默认0.5 如果是负数 方向相反;
@property (nonatomic ,assign) CGFloat displacement ;

//注册UICollectionViewCell
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier ;

//刷新
-(void)reloadData ;
@end

NS_ASSUME_NONNULL_END
