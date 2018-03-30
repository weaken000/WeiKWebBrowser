//
//  TabManager.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class Tab, BrowsedModel, TabManager;

@protocol TabManagerDelegate <NSObject>

- (void)tabManager:(TabManager *)tabManager didCreateTab:(Tab *)tab;

- (void)tabManager:(TabManager *)tabManager didChangedCollectState:(BOOL)isCollect;

@end

@interface TabManager : NSObject

@property (nonatomic, strong) Tab *selectTab;

@property (nonatomic, strong) NSMutableArray<Tab *> *tabs;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, weak  ) id<TabManagerDelegate> tabDelegate;

+ (instancetype)sharedInstance;

- (Tab *)createTab;

- (void)removeTab:(Tab *)tab;

- (void)cacheHistoryModel:(BrowsedModel *)model immediately:(BOOL)immediately;

- (BOOL)collectCurrentURL;

- (BOOL)isCollectWithWebView:(WKWebView *)webView;

@end
