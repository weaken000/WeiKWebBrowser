//
//  TabWKWebView.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/30.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <WebKit/WebKit.h>

@class TabWKWebView;

@protocol TabWKWebViewDelegate <NSObject>

- (void)tabWebViewWillBack:(TabWKWebView *)webView;

- (void)tabWebViewWillForward:(TabWKWebView *)webView;

- (void)tabWebViewWillReload:(TabWKWebView *)webView;

@end

@interface TabWKWebView : WKWebView

@property (nonatomic, weak) id<TabWKWebViewDelegate> tabWebViewDelegate;

@end
