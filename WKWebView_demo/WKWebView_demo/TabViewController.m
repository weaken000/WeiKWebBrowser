//
//  TabViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TabViewController.h"
#import "WebViewCollectionViewCell.h"
#import "TabToolbar.h"

#import "TabManager.h"
#import "Tab.h"

@interface TabViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, WebViewCollectionViewCellDelegate, TabToolbarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) TabToolbar *toolbar;

@end

@implementation TabViewController
{
    CGFloat _itemW;
    UIImageView *_maskImageView;
    
    TabManager *_tabManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tabManager = [TabManager sharedInstance];
    
    _toolbar = [[TabToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50) titles:@[@"隐私", @"删除", @"添加"]];
    _toolbar.delegate = self;
    [self.view addSubview:_toolbar];
}

#pragma mark - Public
- (void)reloadItemAtIndex:(NSInteger)index complete:(void (^)(void))complete {
    
    void (^ completed)(void) = [complete copy];
    
    //截图
    _tabManager.tabs[index].corpImage = nil;
    (void)_tabManager.tabs[index].corpImage;
    
    //强制绘制collectionView
    [self.collectionView reloadData];
    [self.view layoutIfNeeded];
    
    //获取目标cell的位置
    NSInteger maxIndex = MAX(index, 0);
    CGRect visiableRect = CGRectMake(0, maxIndex / 2 * (_itemW + 20) + 20, self.view.frame.size.width, _itemW);
    [self.collectionView scrollRectToVisible:visiableRect animated:NO];
    WebViewCollectionViewCell *cell = (WebViewCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    CGRect toRect;
    if (!cell) {
        toRect = CGRectMake(20, 20, _itemW, _itemW);
    }
    else {
        toRect = [cell->_corpImageView convertRect:cell->_corpImageView.bounds toView:self.view];
    }
    
    //添加蒙版
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc] init];
        [self.view addSubview:_maskImageView];
    }
    
    _maskImageView.image = _tabManager.selectTab.corpImage;
    _maskImageView.hidden = NO;
    _maskImageView.alpha = 1.0;
    _maskImageView.frame = _tabManager.selectTab.webView.frame;
    
    //动画
    [UIView animateWithDuration:0.6 animations:^{
        _maskImageView.frame = toRect;
        _maskImageView.alpha = 0.5;
    } completion:^(BOOL finished) {
        _maskImageView.hidden = YES;
        if (completed) {
            completed();
        }
    }];
}

- (void)showViewWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.tabDelegate respondsToSelector:@selector(tabViewController:didShowTab:)]) {
        
        Tab *tab = _tabManager.tabs[indexPath.row];
        _maskImageView.image = tab.corpImage;
        
        WebViewCollectionViewCell *cell = (WebViewCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        CGRect fromRect = [cell->_corpImageView convertRect:cell->_corpImageView.frame toView:self.view];
        _maskImageView.frame = fromRect;
        _maskImageView.hidden = NO;
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.6 animations:^{
            _maskImageView.alpha = 1.0;
            _maskImageView.frame = _tabManager.selectTab.webView.frame;
        } completion:^(BOOL finished) {
            [self.tabDelegate tabViewController:self didShowTab:tab];
            _maskImageView.hidden = YES;
        }];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tabManager.tabs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WebViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"webCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    Tab *tab = _tabManager.tabs[indexPath.row];
    [cell configTitle:tab.webView.title image:tab.corpImage];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showViewWithIndexPath:indexPath];
}

#pragma mark - WebViewCollectionViewCellDelegate
- (void)collectionCell:(WebViewCollectionViewCell *)cell didClickDelete:(UIButton *)sender {
    NSInteger row = [self.collectionView indexPathForCell:cell].row;
    if ([self.tabDelegate respondsToSelector:@selector(tabViewController:didDeleteTab:)]) {
        
        Tab *tab = _tabManager.tabs[row];
        [_tabManager.tabs removeObjectAtIndex:row];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
        [self.tabDelegate tabViewController:self didDeleteTab:tab];
        
    }
    
}

#pragma mark - TabToolbarDelegate
- (void)toolbar:(TabToolbar *)toolBar pressIndex:(NSInteger)index {
    if (index == 0) {
        
    }
    else if (index == 1) {
        
    }
    else {//添加
        if ([self.tabDelegate respondsToSelector:@selector(tabViewController:didCreateTab:)]) {
            [self.tabDelegate tabViewController:self didCreateTab:nil];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_tabManager.tabs.count-1 inSection:0]]];
            [self.view layoutIfNeeded];
            
            [self showViewWithIndexPath:[NSIndexPath indexPathForRow:_tabManager.tabs.count-1 inSection:0]];
        }
    }
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat marginH = 20;
        CGFloat matginV = 20;
        CGFloat itemW = ([UIScreen mainScreen].bounds.size.width - 3 * marginH) / 2.0;
        _itemW = itemW;
        UICollectionViewFlowLayout *newLayout = [UICollectionViewFlowLayout new];
        newLayout.itemSize = CGSizeMake(itemW, itemW);
        newLayout.minimumLineSpacing = matginV;
        newLayout.minimumInteritemSpacing = marginH;
        newLayout.sectionInset = UIEdgeInsetsMake(20, 20, 0, 20);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
                                                                             0, self.view.bounds.size.width, self.view.bounds.size.height-50)
                                             collectionViewLayout:newLayout];
        [_collectionView registerClass:[WebViewCollectionViewCell class] forCellWithReuseIdentifier:@"webCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}


@end
