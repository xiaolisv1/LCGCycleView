//
//  CUCollectionViewCell.m
//  LCGCycleCollectionView
//
//  Created by 李传光 on 2019/4/17.
//  Copyright © 2019 李传光. All rights reserved.
//

#import "CUCollectionViewCell.h"

@implementation CUCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter ;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20] ;
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
    }
    return self ;
}

@end
