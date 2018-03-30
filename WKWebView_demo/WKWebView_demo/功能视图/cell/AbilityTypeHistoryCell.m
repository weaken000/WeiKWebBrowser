//
//  AbilityTypeHistoryCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "AbilityTypeHistoryCell.h"
#import "BrowsedModel.h"

@implementation AbilityTypeHistoryCell {
    UIImageView *_imageView;
    UILabel *_titleLab;
    UIView *_lineView;
    UILabel *_urlLab;
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
    
    _urlLab = [UILabel new];
    _urlLab.font = [UIFont systemFontOfSize:12.0];
    _urlLab.text = @"http://www.baidu.com";
    _urlLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:_urlLab];
    
    _lineView = [UIView new];
    _lineView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_lineView];
}

- (void)layoutSubviews {
    _imageView.frame = CGRectMake(15, 5, 30, 30);
    _titleLab.frame = CGRectMake(60, 3, self.bounds.size.width-75, self.bounds.size.height-9-12);
    _urlLab.frame = CGRectMake(60, CGRectGetMaxY(_titleLab.frame)+3, self.bounds.size.width-75, 12);
    _lineView.frame = CGRectMake(60, self.bounds.size.height-1, self.bounds.size.width-60, 1);
}

- (void)setModel:(BrowsedModel *)model {
    _model = model;
    _titleLab.text = model.title;
    _urlLab.text = model.absoluteURL;
}

@end
