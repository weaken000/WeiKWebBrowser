//
//  AbilityTypeCollectView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeCollectView.h"
#import "AbilityTypeCollectCell.h"

@interface AbilityTypeCollectView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AbilityTypeCollectView {
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initSubviews];
    return self;
}

- (void)initSubviews {
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.rowHeight = 40;
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AbilityTypeCollectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectCell"];
    if (!cell) {
        cell = [[AbilityTypeCollectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"collectCell"];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.abilityVC subviewDidScroll];

}

@end
