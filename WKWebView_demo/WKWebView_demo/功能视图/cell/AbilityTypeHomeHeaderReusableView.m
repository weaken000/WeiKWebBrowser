//
//  AbilityTypeHomeHeaderReusableView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHomeHeaderReusableView.h"

@implementation AbilityTypeHomeHeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initSubviews];
    return self;
}

- (void)initSubviews {
    _titleLab = [UILabel new];
    _titleLab.textColor = [UIColor lightGrayColor];
    _titleLab.font = [UIFont systemFontOfSize:17];
    [self addSubview:_titleLab];
}
- (void)layoutSubviews {
    _titleLab.frame = CGRectMake(10, 0, self.bounds.size.width-10, self.bounds.size.height);
}

@end
