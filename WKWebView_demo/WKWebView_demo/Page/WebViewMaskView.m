//
//  WebViewMaskView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WebViewMaskView.h"

@implementation WebViewMaskView
{
    UIVisualEffectView *_effectView;
    UIImageView *_corpImageView;
    UILabel *_titlelab;
    UIButton *_deleteButton;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitSubviews];
    }
    return self;
}

- (void)commonInitSubviews {
    
    _corpImageView = [UIImageView new];
    [self addSubview:_corpImageView];
    
    _header = [UIView new];
    _header.layer.anchorPoint = CGPointZero;
    [self addSubview:_header];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [_header addSubview:_effectView];
    
    _titlelab = [UILabel new];
    _titlelab.font = [UIFont systemFontOfSize:18];
    _titlelab.textColor = [UIColor blackColor];
    [_header addSubview:_titlelab];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.backgroundColor = [UIColor redColor];
    [_header addSubview:_deleteButton];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _header.frame = CGRectMake(0, 0, self.bounds.size.width, 30);
    _effectView.frame = _header.bounds;
    _titlelab.frame = CGRectMake(0, 0, self.bounds.size.width-30, 30);
    _deleteButton.frame = CGRectMake(self.bounds.size.width-30, 0, 30, 30);
    _corpImageView.frame = self.bounds;
}


- (void)configTitle:(NSString *)title image:(UIImage *)image {
    _titlelab.text = title;
    _corpImageView.image = image;
}

@end
