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

#import "BrowsedModel.h"
#import "DataBaseHelper.h"

@interface AbilityTypeHomeView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation AbilityTypeHomeView {
    UICollectionView *_collectionView;
    CGFloat _urlW;
    CGFloat _hotpointW;
    CGFloat _marginX;
    NSArray *_browserList;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        
        _marginX = 10;
        _urlW = (self.bounds.size.width - 5 * _marginX) / 4;
        _hotpointW = self.bounds.size.width - 2 * _marginX;
        [self initSubviews];
        [self initBrowserList];
       
    }
    return self;
}

- (void)initBrowserList {
    
    [DataBaseHelper selectBrowsedWhereCondition:@"where type = 3" complete:^(BOOL success, NSArray *array) {
        if (success) {
            _browserList = array;
            
            if (!_browserList.count) {
                BrowsedModel *model_1 = [BrowsedModel new];
                model_1.title = @"百度";
                model_1.absoluteURL = @"https://m.baidu.com/";
                model_1.type = BrowsedModelTypeHome;
                model_1.createDate = [[NSDate date] timeIntervalSince1970];
                
                BrowsedModel *model_2 = [BrowsedModel new];
                model_2.title = @"搜狐";
                model_2.absoluteURL = @"https://m.sohu.com/";
                model_2.type = BrowsedModelTypeHome;
                model_2.createDate = [[NSDate date] timeIntervalSince1970];
                
                BrowsedModel *model_3 = [BrowsedModel new];
                model_3.title = @"360";
                model_3.absoluteURL = @"https://m.so.com/";
                model_3.type = BrowsedModelTypeHome;
                model_3.createDate = [[NSDate date] timeIntervalSince1970];
                
                BrowsedModel *model_4 = [BrowsedModel new];
                model_4.title = @"网易";
                model_4.absoluteURL = @"http://www.163.com/";
                model_4.type = BrowsedModelTypeHome;
                model_4.createDate = [[NSDate date] timeIntervalSince1970];
                
                BrowsedModel *model_5 = [BrowsedModel new];
                model_5.title = @"新浪新闻";
                model_5.absoluteURL = @"http://news.sina.com.cn/";
                model_5.type = BrowsedModelTypeHome;
                model_5.createDate = [[NSDate date] timeIntervalSince1970];
                
                BrowsedModel *model_6 = [BrowsedModel new];
                model_6.title = @"腾讯新闻";
                model_6.absoluteURL = @"http://news.qq.com/";
                model_6.type = BrowsedModelTypeHome;
                model_6.createDate = [[NSDate date] timeIntervalSince1970];
                
                BrowsedModel *model_7 = [BrowsedModel new];
                model_7.title = @"今日头条";
                model_7.absoluteURL = @"https://m.toutiao.com/";
                model_7.type = BrowsedModelTypeHome;
                model_7.createDate = [[NSDate date] timeIntervalSince1970];
                
                _browserList = @[model_1, model_2, model_3, model_4, model_5, model_6, model_7];
                [DataBaseHelper insertBrowsedRecords:_browserList complete:^(BOOL success) {
                    
                }];
            }
            
            [_collectionView reloadData];
        }
    }];
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

- (void)setCurrentShowIndex:(NSInteger)currentShowIndex {
    _currentShowIndex = currentShowIndex;
    if (currentShowIndex == self.Index) {
        [DataBaseHelper selectBrowsedWhereCondition:@"where type = 3" complete:^(BOOL success, NSArray *array) {
            if (success) {
                _browserList = array;
                [_collectionView reloadData];
            }
        }];
    }
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
        return _browserList.count;
    }
    return 4;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AbilityTypeHomeURLCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"url" forIndexPath:indexPath];
        cell.browserModel = _browserList[indexPath.row];
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
    if (indexPath.section == 0) {
        BrowsedModel *model = _browserList[indexPath.row];
        [self.abilityVC subviewDidSelectURL:[NSURL URLWithString:model.absoluteURL]];
    }
    
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
