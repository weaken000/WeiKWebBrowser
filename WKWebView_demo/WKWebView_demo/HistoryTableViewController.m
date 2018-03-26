
//
//  HistoryTableViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/22.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "HistoryCell.h"
#import "HistoryModel.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    if (!cell) {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"historyCell"];
    }
    cell.historyInfo = _historyList[indexPath.row];
    return cell;
}



@end
