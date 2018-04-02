//
//  DownloadListViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/2.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "DownloadListViewController.h"
#import "WKDownloadManager.h"

@interface DownloadListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *urls;

@end

@implementation DownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[WKDownloadManager defaultManager] clearCache];
    
//    _urls = @[@"https://github.com/ReactiveX/RxJava.git",
//              @"https://github.com/TextureGroup/Texture.git",
//              @"https://github.com/realm/realm-cocoa.git"];
    
    _urls = @[
              @"https://images.unsplash.com/photo-1496361328949-40f91ca2fcef?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=01faa5d3f58a7b5999a664d2303a4815&auto=format&fit=crop&w=634&q=80",
              @"https://images.unsplash.com/photo-1516046827393-be7eb3d379b9?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=71a7e1ba58dfd30bf682b7fc2fed6a19&auto=format&fit=crop&w=1301&q=80",
              @"https://images.unsplash.com/photo-1522093243371-296c79a66df4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=c5df6bb1f7e73b7621f64a4da294fea0&auto=format&fit=crop&w=700&q=80",
              @"https://images.unsplash.com/photo-1507506892840-60a3825a6161?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=ceb21ff26d5ac8c78b87a9f569e90712&auto=format&fit=crop&w=634&q=80",
              @"https://images.unsplash.com/photo-1514234827276-c4504accd778?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=b06e09a12ce1ef9f02c99d9ec9255fc5&auto=format&fit=crop&w=634&q=80",
              @"https://images.unsplash.com/photo-1516598212795-27ca49821c62?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=f5802f71f8c02cc75836acf5deab1736&auto=format&fit=crop&w=634&q=80"];
    
    [self initSubviews];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)initSubviews {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    for (NSString *url in _urls) {
        [[WKDownloadManager defaultManager] downloadFileWithURL:url progress:^(NSProgress *progress, WKDownloadReceipt *receipt) {
            NSLog(@"| ---- %@: %@  ----|\n", receipt.url, [progress valueForKey:@"fractionCompleted"]);
        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *url) {
            //NSLog(@"success:| ----  %@: %@  ----|\n", url.absoluteString, response);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            //NSLog(@"failure:| ----  %@: %@  ----|\n", url, error.description);
        }];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _urls.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end
