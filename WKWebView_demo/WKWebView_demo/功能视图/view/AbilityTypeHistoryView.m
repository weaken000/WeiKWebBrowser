//
//  AbilityTypeHistoryCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHistoryView.h"
#import "AbilityTypeHistoryCell.h"

@interface AbilityTypeHistoryView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AbilityTypeHistoryView {
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initSubviews];
    return self;
}

- (void)initSubviews {
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.rowHeight = 40;
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
}

- (UITableViewHeaderFooterView *)setupHeaderForIdentifier:(NSString *)identifier {
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
    UILabel *label = [UILabel new];
    label.text = @"今天";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(10, 0, self.bounds.size.width-20, 35);
    [view addSubview:label];
    return view;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section + 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AbilityTypeHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    if (!cell) {
        cell = [[AbilityTypeHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
    }
    return cell;
}

- (UITableViewHeaderFooterView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!view) {
        view = [self setupHeaderForIdentifier:@"header"];
    }
    return view;
}
- (UITableViewHeaderFooterView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.abilityVC subviewDidScroll];

}

@end
