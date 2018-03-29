//
//  AbilityTypeHomeURLCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHomeURLCell.h"
#import "Masonry.h"

@implementation AbilityTypeHomeURLCell {
    UIImageView *_iconImageView;
    UILabel *_urlNameLab;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    _iconImageView = [UIImageView new];
    _iconImageView.backgroundColor = [UIColor purpleColor];
    _iconImageView.layer.cornerRadius = 5.0;
    [self.contentView addSubview:_iconImageView];
    
    _urlNameLab = [UILabel new];
    _urlNameLab.text = @"百度";
    _urlNameLab.font = [UIFont systemFontOfSize:15.0];
    _urlNameLab.textColor = [UIColor blackColor];
    _urlNameLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_urlNameLab];
    
}

- (void)layoutSubviews {
    CGFloat w = MIN(self.bounds.size.width, self.bounds.size.height);
    _iconImageView.frame = CGRectMake(0, 0, w, w);
    _urlNameLab.frame = CGRectMake(0, w, w, self.bounds.size.height-w);
}

@end
