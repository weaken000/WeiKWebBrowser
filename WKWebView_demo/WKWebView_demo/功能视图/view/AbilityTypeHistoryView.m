//
//  AbilityTypeHistoryCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHistoryView.h"
#import "AbilityTypeHistoryCell.h"

#import "DataBaseHelper.h"
#import "BrowsedModel.h"

@interface AbilityTypeHistoryView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AbilityTypeHistoryView {
    UITableView *_tableView;
    NSMutableArray *_browserList;
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

- (void)willMoveToWindow:(UIWindow *)newWindow {
    
}

- (UITableViewHeaderFooterView *)setupHeaderForIdentifier:(NSString *)identifier {
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(10, 0, self.bounds.size.width-20, 35);
    [view addSubview:label];
    return view;
}

- (void)setCurrentShowIndex:(NSInteger)currentShowIndex {
    _currentShowIndex = currentShowIndex;
    if (currentShowIndex == self.Index) {
        //当已经查询过一次时，之后只查询今天
        NSString *sql = _browserList.count ? [NSString stringWithFormat:@"where type = 1 and createDate >= %f", [[self zeroOfDate] timeIntervalSince1970]] : @"where type = 1";
        [DataBaseHelper selectBrowsedWhereCondition:sql complete:^(BOOL success, NSArray *array) {
            if (success) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self differentDateFromArray:array];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                    });
                });
                
            }
        }];
    }
}


- (void)differentDateFromArray:(NSArray *)array {
    NSString *currentDateDesc = @"";
    NSMutableArray *totalArr = [NSMutableArray array];
    NSMutableArray *sigleArr;
    for (BrowsedModel *model in array) {
        NSString *dayTitle = [self dayByBrowsedModel:model];
        if (![currentDateDesc isEqualToString:dayTitle]) {//不相等，重新开一个组
            //先将上一个组加入
            if (sigleArr.count) {
                [totalArr addObject:@{@"title": currentDateDesc,
                                      @"list": [sigleArr mutableCopy]
                                      }];
            }
            //设置当前title
            currentDateDesc = dayTitle;
            
            //新建组,加入当前
            sigleArr = [NSMutableArray array];
            [sigleArr addObject:model];
        }
        else {//加到组内
            [sigleArr addObject:model];
        }
    }
    
    //最后一组
    if (sigleArr.count) {
        [totalArr addObject:@{@"title": currentDateDesc,
                              @"list": [sigleArr mutableCopy]
                              }];
    }
    
    if (_browserList.count && totalArr.count) {
        [_browserList replaceObjectAtIndex:0 withObject:totalArr.firstObject];
    }
    else {
        _browserList = totalArr;
    }
}

- (NSString *)dayByBrowsedModel:(BrowsedModel *)browsedModel {
    
    NSDate *date =  [[NSDate alloc] initWithTimeIntervalSince1970:browsedModel.createDate];
    NSDate *nowDate = [NSDate date];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp = [calendar components:unitFlags
                                         fromDate:date
                                           toDate:nowDate
                                          options:NSCalendarWrapComponents];
    
    
    if (comp.day == 0) {
        return @"今天";
    }
    if (comp.day == 1) {
        return @"昨天";
    }
    if (comp.day == 2) {
        return @"前天";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

- (NSDate *)zeroOfDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [calendar dateFromComponents:components];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _browserList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *arr = _browserList[section][@"list"];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AbilityTypeHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    if (!cell) {
        cell = [[AbilityTypeHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
    }
    NSMutableArray *arr = _browserList[indexPath.section][@"list"];
    cell.model = arr[indexPath.row];
    return cell;
}

- (UITableViewHeaderFooterView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!view) {
        view = [self setupHeaderForIdentifier:@"header"];
    }
    UILabel *lab = view.subviews.lastObject;
    lab.text = _browserList[section][@"title"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *arr = _browserList[indexPath.section][@"list"];
    BrowsedModel *model = arr[indexPath.row];
    [self.abilityVC subviewDidSelectURL:[NSURL URLWithString:model.absoluteURL]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.abilityVC subviewDidScroll];

}

@end
