//
//  HistoryTableViewController.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/22.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryModel;

@interface HistoryTableViewController : UITableViewController

@property (nonatomic, strong) NSArray<HistoryModel *> *historyList;

@end
