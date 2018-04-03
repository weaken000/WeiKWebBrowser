//
//  DownloadCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/3.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "DownloadCell.h"
#import "Masonry.h"

@interface DownloadCell()<WKDownloadReceiptDelegate>

@end

@implementation DownloadCell {
    UILabel *_stateLab;
    CAShapeLayer *_progressLayer;
    WKDownloadReceipt *_receipt;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    _stateLab = [[UILabel alloc] init];
    _stateLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:_stateLab];
    
    _nameLab = [[UILabel alloc] init];
    _nameLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:_nameLab];
    
    _actionButton = [[UIButton alloc] init];
    _actionButton.layer.borderColor = [UIColor blackColor].CGColor;
    _actionButton.layer.borderWidth = 1.0;
    [_actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_actionButton addTarget:self action:@selector(click_actionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_actionButton];
    
    [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo(100);
    }];
    
    [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-10);
        make.right.equalTo(self.actionButton.mas_left).offset(-15);
    }];
    
    [_stateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(_nameLab);
        make.top.equalTo(self.contentView.mas_centerY).offset(10);
    }];
    
    
}

- (void)layoutSubviews {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = CGRectMake(0, self.bounds.size.height-5, self.bounds.size.width, 3);
        _progressLayer.strokeEnd = 0.0;
        _progressLayer.strokeStart = 0.0;
        _progressLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 5);
        _progressLayer.strokeColor = [UIColor greenColor].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 5;
        [path moveToPoint:CGPointMake(0, self.bounds.size.height-5)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-5)];
        
        _progressLayer.path = path.CGPath;
        [self.contentView.layer addSublayer:_progressLayer];
    }
    
}

- (void)click_actionButton:(UIButton *)sender {
    if (self.state == WKDownloadStateNone ||
        self.state == WKDownloadStateWillResume ||
        self.state == WKDownloadStateSuspened) {
        [[WKDownloadManager defaultManager] resumeWithURL:self.url];
    }
    else if (self.state == WKDownloadStateDownloading) {
        [[WKDownloadManager defaultManager] suspendWithURL:self.url];
    }
    else {
        
    }
}

- (void)setProgress:(NSProgress *)progress {
    _progress = progress;
    _progressLayer.strokeEnd = [[progress valueForKey:@"fractionCompleted"] floatValue];
}
- (void)setState:(WKDownloadState)state {
    _state = state;
    switch (state) {
        case WKDownloadStateNone:
        case WKDownloadStateWillResume:
            _stateLab.text = @"等待...";
            [_actionButton setTitle:@"开始" forState:UIControlStateNormal];
            break;
        case WKDownloadStateSuspened:
            _stateLab.text = @"暂停中";
            [_actionButton setTitle:@"开始" forState:UIControlStateNormal];
            break;
        case WKDownloadStateCompleted:
            _stateLab.text = @"下载完成";
            [_actionButton setTitle:@"清除" forState:UIControlStateNormal];
            break;
        case WKDownloadStateFailed:
            _stateLab.text = @"下载失败";
            [_actionButton setTitle:@"清除" forState:UIControlStateNormal];
            break;
        case WKDownloadStateDownloading:
            _stateLab.text = @"下载中。。。";
            [_actionButton setTitle:@"暂停" forState:UIControlStateNormal];
            break;
    }
}

- (void)setUrl:(NSString *)url {
    
    __weak typeof(self) weakSelf = self;
    [[WKDownloadManager defaultManager] downloadFileWithURL:url progress:^(NSProgress *progress, WKDownloadReceipt *receipt) {
        weakSelf.progress = progress;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *url) {
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    if (![_url isEqualToString:url] || !_url.length) {
        WKDownloadReceipt *re = [[WKDownloadManager defaultManager] receiptForURL:url];
        re.receiptDelegate = self;
        self.state = re.state;
    }
    
    _url = url;
    
}

#pragma mark - delegate
- (void)receipt:(WKDownloadReceipt *)receipt didChangedState:(WKDownloadState)state {
    self.state = state;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

@end
