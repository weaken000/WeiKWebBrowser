//
//  AbilityTypeViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeViewController.h"

#import "AbilityTypeHomeView.h"
#import "AbilityTypeCollectView.h"
#import "AbilityTypeHistoryView.h"
#import "YZLBiddingTypeView.h"

@interface AbilityTypeViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) AbilityTypeHomeView *homeView;
@property (nonatomic, strong) AbilityTypeCollectView *collectView;
@property (nonatomic, strong) AbilityTypeHistoryView *historyView;
@property (nonatomic, strong) YZLBiddingTypeView *scrollTypeView;;
@end

@implementation AbilityTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_scrollView) {
        [self initSubviews];
    }
}

- (void)initSubviews {
    
    _scrollTypeView = [[YZLBiddingTypeView alloc] initWithTypes:@[@"首页", @"收藏", @"历史"]];
    _scrollTypeView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    [self.view addSubview:_scrollTypeView];
    
    UIView *headLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 1)];
    headLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:headLine];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height-50)];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*3, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _homeView = [[AbilityTypeHomeView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
    _homeView.Index = 0;
    [_scrollView addSubview:_homeView];
    
    _collectView = [[AbilityTypeCollectView alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
    _collectView.Index = 1;
    [_scrollView addSubview:_collectView];
    
    _historyView = [[AbilityTypeHistoryView alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width*2, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
    _historyView.Index = 2;
    [_scrollView addSubview:_historyView];
    
    _homeView.abilityVC = self;
    _collectView.abilityVC = self;
    _historyView.abilityVC = self;
    
    __weak typeof(self) weakSelf = self;
    _scrollTypeView.typeSelectChanged = ^(NSInteger selectIndex) {
        [weakSelf.scrollView setContentOffset:CGPointMake(selectIndex * weakSelf.view.bounds.size.width, 0) animated:YES];
        for (UIView *view in weakSelf.scrollView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                continue;
            }
            [view setValue:@(selectIndex) forKey:@"currentShowIndex"];
        }
    };
}

- (void)subviewDidScroll {
    if ([self.delegate respondsToSelector:@selector(abilitySubViewDidScroll:)]) {
        [self.delegate abilitySubViewDidScroll:self];
    }
}
- (void)subviewDidSelectURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(ability:didClickURL:)]) {
        [self.delegate ability:self didClickURL:url];
    }
}

- (void)abilityHidden:(BOOL)hidden {
    if (!hidden && self.view.isHidden) {
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                continue;
            }
            [view setValue:@(_scrollTypeView.selectIndex) forKey:@"currentShowIndex"];
        }
    }
    self.view.hidden = hidden;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    _scrollTypeView.offsetPercent = offsetX / (2 * [UIScreen mainScreen].bounds.size.width);
}

@end
