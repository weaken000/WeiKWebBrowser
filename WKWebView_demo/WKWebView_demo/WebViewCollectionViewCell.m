//
//  WebViewCollectionViewCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WebViewCollectionViewCell.h"

@implementation WebViewCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitSubviews];
    }
    return self;
}

- (void)commonInitSubviews {
    _titlelab = [UILabel new];
    _titlelab.backgroundColor = [UIColor whiteColor];
    _titlelab.font = [UIFont systemFontOfSize:18];
    _titlelab.textColor = [UIColor blackColor];
    _titlelab.textAlignment = NSTextAlignmentCenter;
    _titlelab.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_titlelab];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.backgroundColor = [UIColor redColor];
    [_deleteButton addTarget:self action:@selector(click_deleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
    _corpImageView = [UIImageView new];
    _corpImageView.layer.masksToBounds = YES;
    _corpImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_corpImageView];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titlelab.frame = CGRectMake(0, 0, self.bounds.size.width-30, 30);
    _deleteButton.frame = CGRectMake(self.bounds.size.width-30, 0, 30, 30);
    _corpImageView.frame = CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height-30);
}

- (void)click_deleteButton:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(collectionCell:didClickDelete:)]) {
        [self.delegate collectionCell:self didClickDelete:sender];
    }
}

- (void)configTitle:(NSString *)title image:(UIImage *)image {
    _titlelab.text = title;
    _corpImageView.image = image;
}

@end
