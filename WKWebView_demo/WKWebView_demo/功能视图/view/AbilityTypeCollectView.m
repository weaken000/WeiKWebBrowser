//
//  AbilityTypeCollectView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeCollectView.h"
#import "AbilityTypeCollectCell.h"

#import "BrowsedModel.h"
#import "DataBaseHelper.h"

@interface AbilityTypeCollectView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AbilityTypeCollectView {
    UITableView *_tableView;
    NSArray *_browserList;
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

- (void)setCurrentShowIndex:(NSInteger)currentShowIndex {
    _currentShowIndex = currentShowIndex;
    if (currentShowIndex == self.Index) {
        [DataBaseHelper selectBrowsedWhereCondition:@"where type = 2" complete:^(BOOL success, NSArray *array) {
            if (success) {
                _browserList = array;
                [_tableView reloadData];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _browserList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AbilityTypeCollectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectCell"];
    if (!cell) {
        cell = [[AbilityTypeCollectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"collectCell"];
    }
    cell.model = _browserList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BrowsedModel *model = _browserList[indexPath.row];
    [self.abilityVC subviewDidSelectURL:[NSURL URLWithString:model.absoluteURL]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.abilityVC subviewDidScroll];

}

@end
