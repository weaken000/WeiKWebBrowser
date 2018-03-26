//
//  TabManager.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TabManager.h"
#import "Tab.h"
#import <WebKit/WebKit.h>

@interface TabManager()<WKUIDelegate, WKNavigationDelegate>

@end

@implementation TabManager

+ (instancetype)sharedInstance {
    static TabManager *instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [TabManager new];
    });
    return instace;
}

- (WKWebView *)addWebView {
    Tab *tab = [Tab new];
    tab.webView.UIDelegate = self;
    tab.webView.navigationDelegate = self;
    
    _selectTab = tab;
    [self.tabs addObject:tab];
    
    return tab.webView;
}


#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    //NSString *inputValueJS = @"document.getElementsByTagName('head')[0].getElementsByTagName('link')[0].getAttribute('rel')";
    
    //    NSString *cookieJS = @"document.cookie";
    //    //执行JS
    //    [webView evaluateJavaScript:cookieJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
    //        NSLog(@"value: %@ error: %@", response, error);
    //    }];
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    
    
    //NSLog(@"%@___%@", NSStringFromSelector(_cmd), navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //NSLog(@"%@___%@", NSStringFromSelector(_cmd), navigationAction.request.URL.absoluteString);
    //允许跳转
    
    //    WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
    //    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *obj) {
    //        for (NSHTTPCookie *cookie in obj) {
    //            NSLog(@"\n%@\n", cookie);
    //        }
    //    }];
    
    
    
//    [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[NSSet setWithArray:@[WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage]] completionHandler:^(NSArray<WKWebsiteDataRecord *> *array) {
//        for (WKWebsiteDataRecord *record in array) {
//            NSLog(@"%@", record);
//        }
//    }];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
//MARK: 防止白屏
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return _selectTab.webView;
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%@",message);
    completionHandler();
}

#pragma mark - getter
- (NSMutableArray<Tab *> *)tabs {
    if (!_tabs) {
        _tabs = [NSMutableArray array];
    }
    return _tabs;
}

- (NSInteger)selectIndex {
    return [_tabs indexOfObject:_selectTab];
}

@end
