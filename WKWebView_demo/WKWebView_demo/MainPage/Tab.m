//
//  Tab.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "Tab.h"

static WKProcessPool *siglePool;

@implementation Tab

- (instancetype)init {
    self = [super init];
    if (self) {
        if (!siglePool) {
            siglePool = [WKProcessPool new];
        }
    }
    return self;
}

#pragma mark - getter
- (TabWKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.preferences = [WKPreferences new];
        config.preferences.javaScriptEnabled = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        config.processPool = siglePool;//共享同一个pool，共享cookie
        _webView = [[TabWKWebView alloc] initWithFrame:CGRectZero configuration:config];
    }
    return _webView;
}

- (UIImage *)corpImage {
    if (!_corpImage) {
        _corpImage = [self captureImage];
    }
    return _corpImage;
}

- (UIImage *)captureImage {
    UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, NO, [UIScreen mainScreen].scale);
    [_webView.scrollView drawViewHierarchyInRect:self.webView.bounds
                              afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
