//
//  TabToolbar.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TabToolbar.h"

@interface TabToolbar()

@end

@implementation TabToolbar {
    
    UIStackView *_backgroundView;
    
    UIButton *_backButton;
    UIButton *_forwardButton;
    UIButton *_loadButton;
    UIButton *_tabButton;
    UIButton *_listButton;
    
    UIButton *_privateButton;
    UIButton *_deleteButton;
    UIButton *_addButton;
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles {
    if (self == [super initWithFrame:frame]) {
        [self setupSubviews:titles];
    }
    return self;
}


- (void)setupSubviews:(NSArray *)titles {
    
    if (titles.count == 5) {
        _backButton = [self setupButtonWithTitle:titles[0]];
        _backButton.enabled = NO;
        _backButton.tag = 0;
        
        _forwardButton = [self setupButtonWithTitle:titles[1]];
        _forwardButton.enabled = NO;
        _forwardButton.tag = 1;
        
        _loadButton = [self setupButtonWithTitle:titles[2]];
        _loadButton.enabled = NO;
        _loadButton.tag = 2;
        
        _tabButton = [self setupButtonWithTitle:titles[3]];
        _tabButton.tag = 3;
        
        _listButton = [self setupButtonWithTitle:titles[4]];
        _listButton.tag = 4;
        
        _backgroundView = [[UIStackView alloc] initWithArrangedSubviews:@[_backButton, _forwardButton, _loadButton, _tabButton, _listButton]];
    }
    else {
        _privateButton = [self setupButtonWithTitle:titles[0]];
        _privateButton.tag = 0;
        
        _deleteButton = [self setupButtonWithTitle:titles[1]];
        _deleteButton.tag = 1;
        
        _addButton = [self setupButtonWithTitle:titles[2]];
        _addButton.tag = 2;
        
        _backgroundView = [[UIStackView alloc] initWithArrangedSubviews:@[_privateButton, _deleteButton, _addButton]];
    }
    
    _backgroundView.axis = UILayoutConstraintAxisHorizontal;
    _backgroundView.distribution = UIStackViewDistributionFillEqually;    
    [self addSubview:_backgroundView];
}
- (void)layoutSubviews {
    _backgroundView.frame = self.bounds;
}

- (UIButton *)setupButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateState:(id)state forIndex:(NSInteger)index {
    
    BOOL isEnable = [state boolValue];
    
    switch (index) {
        case 0:
            _backButton.enabled = isEnable;
            break;
        case 1:
            _forwardButton.enabled = isEnable;
            break;
        case 2:
            _loadButton.enabled = !isEnable;
            break;
        case 4:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)clickButton:(UIButton *)sender {
    [self.delegate toolbar:self pressIndex:sender.tag];
}

@end
