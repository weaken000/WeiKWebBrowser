
//
//  InputURLView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "InputURLView.h"
#import "Masonry.h"

@implementation InputURLView {
    
    UIView *_normalStateBgView;
    UILabel *_normalURLLab;//普通情况下显示地址
    UIButton *_collectButton;//收藏按钮
    
    UIView *_foucesStateBgView;
    UIButton *_backButton;//取消按钮
    UITextField *_urlTextField;//输入框
    UIButton *_scanButton;//扫描
    UIView *_boardView;//边框
    
    BOOL _isOnFoucs;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self initSuviews];
        [self makeConstraints];
    }
    return self;
}

- (void)setCurrentURL:(NSURL *)currentURL {
    _currentURL = currentURL;
    if (!currentURL) {
        _normalURLLab.text = @"";
        _urlTextField.text = @"";
        return;
    }
    
    if (currentURL.resourceSpecifier.length <= 2 || !currentURL.resourceSpecifier.length) {
        _normalURLLab.text = currentURL.absoluteString;
    }
    else {
        _normalURLLab.text = [currentURL.resourceSpecifier substringFromIndex:2];
    }
    _urlTextField.text = currentURL.absoluteString;
}

- (void)initSuviews {
    _foucesStateBgView = [UIView new];
    _foucesStateBgView.hidden = YES;
    [self addSubview:_foucesStateBgView];
    
    _backButton = [[UIButton alloc] init];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(click_backButton:) forControlEvents:UIControlEventTouchUpInside];
    [_foucesStateBgView addSubview:_backButton];
    
    _scanButton = [[UIButton alloc] init];
    [_scanButton setTitle:@"扫一扫" forState:UIControlStateNormal];
    [_scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_foucesStateBgView addSubview:_scanButton];
    
    _boardView = [UIView new];
    _boardView.layer.masksToBounds = YES;
    _boardView.layer.borderColor = [UIColor purpleColor].CGColor;
    _boardView.layer.borderWidth = 3.0;
    _boardView.layer.cornerRadius = 5.0;
    _boardView.backgroundColor = [UIColor whiteColor];
    [_foucesStateBgView addSubview:_boardView];
    
    _urlTextField = [UITextField new];
    _urlTextField.placeholder = @"请输入地址";
    _urlTextField.hidden = YES;
    _urlTextField.returnKeyType = UIReturnKeyGo;
    _urlTextField.delegate = self;
    [_boardView addSubview:_urlTextField];
    
    _normalStateBgView = [UIView new];
    _normalStateBgView.layer.masksToBounds = YES;
    _normalStateBgView.layer.borderColor = [UIColor grayColor].CGColor;
    _normalStateBgView.layer.borderWidth = 1.0;
    _normalStateBgView.layer.cornerRadius = 5.0;
    [self addSubview:_normalStateBgView];
    
    _normalURLLab = [UILabel new];
    _normalURLLab.font = [UIFont systemFontOfSize:15.0];
    _normalURLLab.textColor = [UIColor blackColor];
    _normalURLLab.userInteractionEnabled = YES;
    [_normalURLLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_normalLab:)]];
    [_normalStateBgView addSubview:_normalURLLab];
    
    _collectButton = [UIButton new];
    [_collectButton setTitle:@"收藏" forState:UIControlStateNormal];
    [_collectButton setTitle:@"已收藏" forState:UIControlStateSelected];
    [_collectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_collectButton addTarget:self action:@selector(click_collectButton:) forControlEvents:UIControlEventTouchUpInside];
    [_normalStateBgView addSubview:_collectButton];
}

- (void)makeConstraints {
    [_foucesStateBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 10, 0, 10));
    }];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(44);
    }];
    [_scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(60);
    }];
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    [_urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.top.mas_equalTo(5);
        make.left.equalTo(_backButton.mas_right).offset(10);
        make.right.equalTo(_scanButton.mas_left).offset(-10);
    }];
    
    
    
    [_normalStateBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(_foucesStateBgView);
    }];
    [_collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.width.mas_equalTo(60);
    }];
    [_normalURLLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(20);
        make.right.equalTo(_collectButton.mas_left);
    }];
}

- (void)tap_normalLab:(UITapGestureRecognizer *)gesture {
    
    if (_isOnFoucs) return;
    
    _normalStateBgView.hidden = YES;
    _foucesStateBgView.hidden = NO;
    _isOnFoucs = YES;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _boardView.alpha = 1.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _urlTextField.hidden = NO;
        [_urlTextField becomeFirstResponder];
        [_urlTextField selectAll:nil];
        
        if ([self.delegate respondsToSelector:@selector(inputURLView:didIntoFocus:)]) {
            [self.delegate inputURLView:self didIntoFocus:YES];
        }
        
    }];
    
}

- (void)click_backButton:(UIButton *)sender {
    if (!_isOnFoucs) return;
    
    _isOnFoucs = NO;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _boardView.alpha = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _urlTextField.hidden = YES;
        _foucesStateBgView.hidden = YES;
        _normalStateBgView.hidden = NO;
        [_urlTextField resignFirstResponder];
        if ([self.delegate respondsToSelector:@selector(inputURLView:didIntoFocus:)]) {
            [self.delegate inputURLView:self didIntoFocus:NO];
        }
    }];
}

- (void)click_collectButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(inputURLView:didClickCollect:)]) {
        [self.delegate inputURLView:self didClickCollect:sender];
    }
}

- (void)updateConstraints {
    if (_isOnFoucs) {
        [_boardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(44);
            make.right.mas_equalTo(-60);
        }];
    }
    else {
        [_boardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
    [super updateConstraints];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (!textField.text.length) return NO;
    
    if ([self.delegate respondsToSelector:@selector(inputURLView:didClickDone:)]) {
        [_urlTextField resignFirstResponder];
        _normalURLLab.text = textField.text;
        [self click_backButton:_backButton];
        [self.delegate inputURLView:self didClickDone:textField.text];
    }
    return YES;
}

- (void)setIsOnFocus:(BOOL)isOnFocus {
    if (isOnFocus) {
        [self tap_normalLab:nil];
    }
    else {
        [self click_backButton:_backButton];
    }
}

- (void)setIsCollect:(BOOL)isCollect {
    _isCollect = isCollect;
    _collectButton.selected = isCollect;
}

@end
