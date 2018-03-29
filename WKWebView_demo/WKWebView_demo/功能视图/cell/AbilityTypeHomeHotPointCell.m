//
//  AbilityTypeHomeHotPointCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHomeHotPointCell.h"

@implementation AbilityTypeHomeHotPointCell {
    UIImageView *_iconImageView;
    UILabel *_urlNameLab;
    UILabel *_detailLab;
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
    _urlNameLab.font = [UIFont systemFontOfSize:12];
    _urlNameLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:_urlNameLab];
    
    _detailLab = [UILabel new];
    _detailLab.text = @"详情详情详情详情详情详情详情详情详情详情详情详情详情详情详情详情详情详情详情";
    _detailLab.numberOfLines = 2;
    _detailLab.font = [UIFont boldSystemFontOfSize:15];
    _detailLab.lineBreakMode =  NSLineBreakByTruncatingTail;
    _detailLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:_detailLab];
}

- (void)layoutSubviews {
    _iconImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width*0.6);
    _urlNameLab.frame = CGRectMake(0, CGRectGetMaxY(_iconImageView.frame)+10, self.bounds.size.width, 18);
    _detailLab.frame = CGRectMake(0, CGRectGetMaxY(_urlNameLab.frame)+10, self.bounds.size.width, self.bounds.size.height-20-CGRectGetMaxY(_urlNameLab.frame));
}

@end
