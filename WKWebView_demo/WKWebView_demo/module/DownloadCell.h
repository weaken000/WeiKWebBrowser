//
//  DownloadCell.h
//  WKWebView_demo
//
//  Created by mc on 2018/4/3.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKDownloadManager.h"

@interface DownloadCell : UITableViewCell

@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic, assign) WKDownloadState state;

@property (nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, copy  ) NSString *url;

@end
