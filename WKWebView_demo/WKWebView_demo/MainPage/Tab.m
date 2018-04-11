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
        
        //偏好设置
        WKPreferences *preferences = [[WKPreferences alloc] init];
        preferences = [WKPreferences new];
        preferences.javaScriptEnabled = YES;
        preferences.javaScriptCanOpenWindowsAutomatically = NO;
        config.preferences = preferences;
        
        //共享进程池，表示共享不同webView之间的cookie等
        config.processPool = siglePool;
        
        //注入js对象，处理js调用oc
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
//        [userContentController addScriptMessageHandler:self name:@"iosInstance"];
        //注入js代码
//        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:@"" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//        [userContentController addUserScript:userScript];
        config.userContentController = userContentController;
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
            //设置储存
            config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
        }
        
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
