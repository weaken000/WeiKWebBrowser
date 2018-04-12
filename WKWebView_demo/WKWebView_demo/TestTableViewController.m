//
//  TestTableViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/10.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TestTableViewController.h"
#import "WKFlowLayout.h"

@interface TestTableViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *heightArray;

@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _heightArray = [NSMutableArray array];
    [_heightArray addObjectsFromArray:@[[UIColor blueColor], [UIColor greenColor], [UIColor yellowColor], [UIColor redColor], [UIColor grayColor], [UIColor purpleColor]]];
    
    WKFlowLayout *layout = [WKFlowLayout new];
    layout.itemCount = _heightArray.count;
    if (@available(iOS 11.0, *)) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_collectionView];
    
}

- (void)viewWillLayoutSubviews {
    if (@available(iOS 11.0, *)) {
        self.collectionView.frame = CGRectMake(self.view.safeAreaInsets.left+20, self.view.safeAreaInsets.top+10, self.view.bounds.size.width-40, self.view.bounds.size.height-20-self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _heightArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *lab;
    if (!cell.contentView.subviews.count) {
        lab = [UILabel new];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont systemFontOfSize:22.0];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.frame = cell.contentView.bounds;
        [cell.contentView addSubview:lab];
    }
    else {
        lab = cell.contentView.subviews.firstObject;
    }
    cell.backgroundColor = _heightArray[indexPath.item];
    lab.text = [NSString stringWithFormat:@"卡片-%zd", indexPath.item];

    return cell;
}


@end
