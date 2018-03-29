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
#import "WebViewTranstion.h"

@interface TabViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, WebViewCollectionViewCellDelegate, TabToolbarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) TabToolbar *toolbar;

@end

@implementation TabViewController {
    CGFloat _itemW;
    
    NSIndexPath *_selectIndexPath;
    TabManager *_tabManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tabManager = [TabManager sharedInstance];
    [self initSubviews];
}

#pragma mark - private
- (void)initSubviews {
    _toolbar = [[TabToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50) titles:@[@"隐私", @"删除", @"添加"]];
    _toolbar.backgroundColor = [UIColor whiteColor];
    _toolbar.delegate = self;
    [self.view addSubview:_toolbar];
}

- (void)showViewWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.tabDelegate respondsToSelector:@selector(tabViewController:didShowTab:)]) {
        [self.tabDelegate tabViewController:self didShowTab:_tabManager.tabs[indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Public
- (CGRect)reloadItem {
    //截图
    _tabManager.selectTab.corpImage = nil;
    (void)_tabManager.selectTab.corpImage;
    
    //强制绘制collectionView
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_tabManager.selectIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [self.view layoutIfNeeded];
    
    WebViewCollectionViewCell *cell = (WebViewCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_tabManager.selectIndex inSection:0]];
    
    CGRect toRect;
    if (!cell) {
        toRect = CGRectMake(20, 20, _itemW, _itemW);
    }
    else {
        toRect = [self.collectionView convertRect:cell.frame toView:self.view];
    }
    toRect.origin.y += 20;
    return toRect;
}

- (WebViewCollectionViewCell *)transitionFrameCell {
    return (WebViewCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_selectIndexPath];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tabManager.tabs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WebViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"webCell" forIndexPath:indexPath];
    Tab *tab = _tabManager.tabs[indexPath.row];
    cell.delegate = self;
    [cell configTitle:tab.webView.title image:tab.corpImage];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectIndexPath = indexPath;
    [self showViewWithIndexPath:indexPath];
}


#pragma mark - WebViewCollectionViewCellDelegate
- (void)collectionCell:(WebViewCollectionViewCell *)cell didClickDelete:(UIButton *)sender {
    NSInteger row = [self.collectionView indexPathForCell:cell].row;
    if ([self.tabDelegate respondsToSelector:@selector(tabViewController:didDeleteTab:)]) {
        Tab *tab = _tabManager.tabs[row];
        [self.tabDelegate tabViewController:self didDeleteTab:tab];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
    }
}

#pragma mark - TabToolbarDelegate
- (void)toolbar:(TabToolbar *)toolBar pressIndex:(NSInteger)index {
    if (index == 0) {
        
    }
    else if (index == 1) {
        
    }
    else {//添加
        if ([self.tabDelegate respondsToSelector:@selector(tabViewControllerDidCreateTab:)]) {
            [self.tabDelegate tabViewControllerDidCreateTab:self];
            
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_tabManager.tabs.count-1 inSection:0]]];
            [self.view layoutIfNeeded];
            
            _selectIndexPath = [NSIndexPath indexPathForRow:_tabManager.tabs.count-1 inSection:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showViewWithIndexPath:[NSIndexPath indexPathForRow:_tabManager.tabs.count-1 inSection:0]];
            });
        }
    }
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    if (operation == UINavigationControllerOperationPush) {
        return [WebViewTranstion transtionForType:TranstionTypeShow complete:^{
            
        }];
    }
    
    if (operation == UINavigationControllerOperationPop) {
        return [WebViewTranstion transtionForType:TranstionTypeDismiss complete:^{
            
        }];
    }
    return nil;
    
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
