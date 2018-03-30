//
//  AbilityTypeCollectCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeCollectCell.h"
#import "BrowsedModel.h"

@implementation AbilityTypeCollectCell {
    UIImageView *_imageView;
    UILabel *_titleLab;
    UIView *_lineView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initSubviews];
    return self;
}

- (void)initSubviews {
    _imageView = [UIImageView new];
    _imageView.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:_imageView];
    
    _titleLab = [UILabel new];
    _titleLab.font = [UIFont systemFontOfSize:15.0];
    _titleLab.text = @"火狐主页";
    _titleLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:_titleLab];
    
    _lineView = [UIView new];
    _lineView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_lineView];
}

- (void)layoutSubviews {
    _imageView.frame = CGRectMake(15, 5, 30, 30);
    _titleLab.frame = CGRectMake(60, 0, self.bounds.size.width-75, self.bounds.size.height-1);
    _lineView.frame = CGRectMake(60, self.bounds.size.height-1, self.bounds.size.width-60, 1);
}

- (void)setModel:(BrowsedModel *)model {
    _model = model;
    _titleLab.text = model.title;
}

@end
