//
//  DownloadListViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/2.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "DownloadListViewController.h"
#import "WKDownloadManager.h"
#import "DownloadCell.h"

@interface DownloadListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *urls;

@end

@implementation DownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[WKDownloadManager defaultManager] clearCache];
    
    [self initSubviews];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    _urls = @[@"http://pic.ibaotu.com/00/26/72/06H888piCkJ3.mp4",
              @"http://pic.ibaotu.com/00/17/19/92n888piCEPp.mp4",
              @"http://pic.ibaotu.com/00/42/44/41x888piCftb.mp4",
              @"http://pic.ibaotu.com/00/38/81/22i888piCkMW.mp4",
              @"http://pic.ibaotu.com/00/54/50/118888piCMJe.mp4",
              @"http://pic.ibaotu.com/00/17/04/29q888piCuVi.mp4",
              @"http://pic.ibaotu.com/00/28/78/92q888piCpKU.mp4",
              @"http://bpic.wotucdn.com/27/30/59/2758picOOOPIC3c.mp4",
              @"http://mp4.vjshi.com/2017-08-03/c8d1f344e6f3d87fdf720d0eb48276b3.mp4",
              @"http://mp4.vjshi.com/2016-06-24/8106b276ba0348e19ec8fe925696db2b.mp4"];
    
    [self.tableView reloadData];
}

- (void)initSubviews {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _urls.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DownloadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSString *url = _urls[indexPath.row];
    cell.url = url;
    return cell;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

@end
