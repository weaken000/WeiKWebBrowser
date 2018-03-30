//
//  YZLBiddingTypeView.m
//  HaveCar
//
//  Created by yzl on 17/9/27.
//  Copyright © 2017年 lwk. All rights reserved.
//

#import "YZLBiddingTypeView.h"
#import "Masonry.h"

static const CGFloat kLineWidth = 80;

@interface YZLBiddingTypeView()
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *currentButton;
@end

@implementation YZLBiddingTypeView {
    NSArray *_types;
    CGFloat _screenW;
}

- (instancetype)initWithTypes:(NSArray *)types {
    if (self == [super init]) {
        _types = types;
        _screenW = [UIScreen mainScreen].bounds.size.width;
        [self yzl_setupViews];
    }
    return self;
}

//- (void)layoutSubviews {
//    for (UIView *sub in self.subviews) {
//        if ([sub isKindOfClass:[UIButton class]]) {
//            UIButton *btn = (UIButton *)sub;
//            [btn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:3];
//        }
//    }
//}

- (void)yzl_setupViews {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    BOOL isImage = [_types.firstObject isKindOfClass:[NSDictionary class]];
    
    for (id item in _types) {
        NSString *title;
        UIImage *image;
        UIImage *select_Image;
        if (isImage) {
            title = item[@"title"];
            image = [UIImage imageNamed:item[@"image"]];
            select_Image = [UIImage imageNamed:item[@"image_select"]];
        } else {
            title = item;
        }
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        [button setTitleColor:[UIColor purpleColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setImage:select_Image forState:UIControlStateSelected];
        [button setImage:image forState:UIControlStateNormal];
        button.tag = [_types indexOfObject:item];
        [button addTarget:self action:@selector(click_types:) forControlEvents:UIControlEventTouchUpInside];
        if (button.tag == 0) {
            _currentButton = button;
            _currentButton.selected = YES;
        }
        [self addSubview:button];
    }
    
    [self.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [self.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
    
    _lineView = [UIView new];
    _lineView.backgroundColor = [UIColor purpleColor];
    [self addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(3);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(kLineWidth);
    }];
    self.offsetPercent = 0.0;
}

- (void)rebackFirst {
    
    if (_offsetPercent != 0) {
        _offsetPercent = 0;
        self.selectIndex = 0;
        UIButton *btn = self.subviews.firstObject;
        _currentButton.selected = NO;
        btn.selected = YES;
        
        CGFloat perOffset = _screenW / (_types.count * 2);
        CGFloat totalOffsetW = perOffset * (_types.count - 1) * 2;
        CGFloat realX = totalOffsetW * _offsetPercent + perOffset - kLineWidth/2.0;
        
        [_lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(realX);
        }];
    }
}

- (void)setOffsetPercent:(CGFloat)offsetPercent {
    _offsetPercent = offsetPercent;
    
    CGFloat perOffset = _screenW / (_types.count * 2);
    CGFloat totalOffsetW = perOffset * (_types.count - 1) * 2;
    CGFloat realX = totalOffsetW * offsetPercent + perOffset - kLineWidth/2.0;
    
    [_lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(realX);
    }];
    
    if ([self judgeDivisibleWithFirstNumber:offsetPercent andSecondNumber:1.0 / (_types.count - 1)]) {
        float f = offsetPercent / (1.0 / (_types.count - 1));
        int i = (int)f;
        
        if (i <= self.subviews.count - 1) {
            UIButton *sender = self.subviews[i];
            [self click_types:sender];
            
            
        }
    }
}

- (void)setNoEffectOffsetPercent:(CGFloat)noEffectOffsetPercent {
    _noEffectOffsetPercent = noEffectOffsetPercent;
    
    CGFloat perOffset = _screenW / (_types.count * 2);
    CGFloat totalOffsetW = perOffset * (_types.count - 1) * 2;
    CGFloat realX = totalOffsetW * noEffectOffsetPercent + perOffset - kLineWidth/2.0;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [_lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(realX);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)setIsHiddenLine:(BOOL)isHiddenLine {
    _lineView.hidden = isHiddenLine;
}

- (void)click_types:(UIButton *)sender {
    self.selectIndex = sender.tag;
    if (sender.isSelected) return;
    
    sender.selected = YES;
    _currentButton.selected = NO;
    _currentButton = sender;
    if (self.typeSelectChanged) {
        self.typeSelectChanged(sender.tag);
    }
}

- (void)reloadSelctColor:(UIColor *)selectColor normalColor:(UIColor *)normalColor {
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            [btn setTitleColor:selectColor forState:UIControlStateSelected];
            [btn setTitleColor:normalColor forState:UIControlStateNormal];
        }
    }
    _lineView.backgroundColor = selectColor;
}

- (BOOL)judgeDivisibleWithFirstNumber:(CGFloat)firstNumber andSecondNumber:(CGFloat)secondNumber {
    // 默认记录为整除
    BOOL isDivisible = YES;
    
    if (secondNumber == 0) {
        return NO;
    }
    CGFloat result = firstNumber / secondNumber;
    // NSString * resultStr = @"10062.0038";
    NSString * resultStr = [NSString stringWithFormat:@"%f", result];
    NSRange range = [resultStr rangeOfString:@"."];
    
    NSString * subStr = [resultStr substringFromIndex:range.location + 1];
    for (NSInteger index = 0; index < subStr.length; index ++) {
        unichar ch = [subStr characterAtIndex:index];
        
        // 后面的字符中只要有一个不为0，就可判定不能整除，跳出循环
        if ('0' != ch) {
            isDivisible = NO;
            break;
        }
    }
    
    // YBLog(@"可以整除");
    return isDivisible;
}

@end
