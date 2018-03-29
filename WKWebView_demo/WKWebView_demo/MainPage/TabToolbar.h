//
//  TabToolbar.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabToolbar;

@protocol TabToolbarDelegate

- (void)toolbar:(TabToolbar *)toolBar pressIndex:(NSInteger)index;

@end

@interface TabToolbar : UIView

@property (nonatomic, weak) id<TabToolbarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles;

- (void)updateState:(id)state forIndex:(NSInteger)index;

@end
