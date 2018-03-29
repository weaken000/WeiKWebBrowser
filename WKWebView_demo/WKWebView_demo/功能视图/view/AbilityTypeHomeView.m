//
//  AbilityTypeHomeView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHomeView.h"

#import "AbilityTypeHomeURLCell.h"
#import "AbilityTypeHomeHotPointCell.h"
#import "AbilityTypeHomeHeaderReusableView.h"

@interface AbilityTypeHomeView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation AbilityTypeHomeView {
    UICollectionView *_collectionView;
    CGFloat _urlW;
    CGFloat _hotpointW;
    CGFloat _marginX;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        
        _marginX = 10;
        _urlW = (self.bounds.size.width - 5 * _marginX) / 4;
        _hotpointW = self.bounds.size.width - 2 * _marginX;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[AbilityTypeHomeURLCell class] forCellWithReuseIdentifier:@"url"];
    [_collectionView registerClass:[AbilityTypeHomeHotPointCell class] forCellWithReuseIdentifier:@"hotpoint"];
    [_collectionView registerClass:[AbilityTypeHomeHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self addSubview:_collectionView];
    
}

- (void)layoutSubviews {
    _urlW = (self.bounds.size.width - 5 * _marginX) / 4;
    _hotpointW = (self.bounds.size.width - 3 * _marginX)/2;
    _collectionView.frame = self.bounds;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 8;
    }
    return 4;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AbilityTypeHomeURLCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"url" forIndexPath:indexPath];
        return cell;
    }
    AbilityTypeHomeHotPointCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hotpoint" forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        AbilityTypeHomeHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        header.titleLab.text = @"热点";
        return header;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.abilityVC subviewDidSelectURL:[NSURL URLWithString:@"https://www.baidu.com"]];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(_urlW, _urlW + 20);
    }
    return CGSizeMake(_hotpointW, _hotpointW);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(self.bounds.size.width, 44.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _marginX;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _marginX;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, _marginX, 0, _marginX);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.abilityVC subviewDidScroll];
}

@end
