//
//  TabManager.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TabManager.h"
#import "Tab.h"
#import "TabWKWebView.h"
#import <pthread.h>

#import "BrowsedModel.h"
#import "DataBaseHelper.h"


static pthread_mutex_t pLock;

@interface TabManager()<WKUIDelegate, WKNavigationDelegate, TabWKWebViewDelegate>

@property (nonatomic, copy) NSString *lastTitle;

@property (nonatomic, strong) NSMutableArray *historyCacheArray;

@property (nonatomic, strong) NSMutableArray *collectArray;


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
- (instancetype)init {
    self = [super init];
    if (self) {
        _lastTitle = @"";
        _historyCacheArray = [NSMutableArray array];
        _collectArray = [NSMutableArray array];
        [DataBaseHelper selectBrowsedWhereCondition:@"where type = 2" complete:^(BOOL success, NSArray *array) {
            if (success) {
                [_collectArray addObjectsFromArray:array];
            }
        }];
        pthread_mutex_init(&pLock, NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (webApplicationWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

#pragma mark - public
- (Tab *)createTab {
    Tab *tab = [Tab new];
    tab.webView.UIDelegate = self;
    tab.webView.navigationDelegate = self;
    tab.webView.tabWebViewDelegate = self;
    [self.tabs addObject:tab];
    return tab;
}

- (void)removeTab:(Tab *)tab {
    if ([_tabs containsObject:tab]) {
        [tab.webView removeFromSuperview];
        tab.webView.UIDelegate = nil;
        tab.webView.navigationDelegate = nil;
        tab.webView.tabWebViewDelegate = nil;
        if (tab == _selectTab) {
            _selectTab = nil;
        }
        [_tabs removeObject:tab];
    }
}

- (void)cacheHistoryModel:(BrowsedModel *)model immediately:(BOOL)immediately {
    
    pthread_mutex_lock(&pLock);
    
    if (model) {
        [self.historyCacheArray addObject:model];
    }
    
    if (immediately) {
        [DataBaseHelper insertBrowsedRecords:self.historyCacheArray complete:^(BOOL success) {
            if (success) {
                [self.historyCacheArray removeAllObjects];
            }
            pthread_mutex_unlock(&pLock);
        }];
    }
    else {
        if (self.historyCacheArray.count >= 30) {//缓存最大限度30条
            [DataBaseHelper insertBrowsedRecords:self.historyCacheArray complete:^(BOOL success) {
                if (success) {
                    [self.historyCacheArray removeAllObjects];
                }
                pthread_mutex_unlock(&pLock);
            }];
        }
        pthread_mutex_unlock(&pLock);
    }
}

- (BOOL)collectCurrentURL {
    BOOL flag = [self isCollectWithWebView:_selectTab.webView];
    if (flag) {//已经收藏，则清除收藏
        NSArray *tmp = [self.collectArray copy];
        for (BrowsedModel *model in tmp) {
            if ([model.absoluteURL compare:_selectTab.webView.URL.absoluteString] == NSOrderedSame) {
                [self.collectArray removeObject:model];
                [DataBaseHelper deleteBrowsedWhereCondition:[NSString stringWithFormat:@"where type = 2 and absoluteURL = '%@'", model.absoluteURL] complete:^(BOOL success) {
                    
                }];
                break;
            }
        }
    }
    else {//没有收藏，添加收藏
        BrowsedModel *model = [BrowsedModel new];
        model.absoluteURL = _selectTab.webView.URL.absoluteString;
        model.type = BrowsedModelTypeCollect;
        model.title = _selectTab.webView.title;
        model.createDate = [[NSDate date] timeIntervalSince1970];
        [self.collectArray addObject:model];
        [DataBaseHelper insertBrowsedRecord:model complete:^(BOOL success) {
            
        }];
    }
    return !flag;
}
- (BOOL)isCollectWithWebView:(WKWebView *)webView {
    BrowsedModel *model;
    for (BrowsedModel *m in _collectArray) {
        if ([m.absoluteURL compare:webView.URL.absoluteString] == NSOrderedSame) {
            model = m;
            break;
        }
    }
    return model != nil;
}

#pragma mark - Private
- (void)webApplicationWillEnterBackground:(NSNotification *)noti {
    [self cacheHistoryModel:nil immediately:YES];
}


#pragma mark - TabWKWebViewDelegate
- (void)tabWebViewWillForward:(TabWKWebView *)webView {
}
- (void)tabWebViewWillReload:(TabWKWebView *)webView {
}
- (void)tabWebViewWillBack:(TabWKWebView *)webView {
}


#pragma mark - WKNavigationDelegate（调用顺序）
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
}
//https身份验证
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
//    //用户身份信息
//    NSURLCredential *newCred = [NSURLCredential credentialWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
//    // 为 challenge 的发送方提供 credential
//    [[challenge sender] useCredential:newCred forAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
//}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}
//接收到服务器跳转请求之后调用：重定向
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}
//当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    BOOL flag = [self isCollectWithWebView:webView];
    if ([self.tabDelegate respondsToSelector:@selector(tabManager:didChangedCollectState:)]) {
        [self.tabDelegate tabManager:self didChangedCollectState:flag];
    }
    
    if ([_lastTitle compare:webView.title] != NSOrderedSame && webView.title.length) {
        
        /*
         浏览历史的添加规则是在发现当前title不等于上一个title时，倒序遍历缓存数组后5个，如果有相同则更新改模型的时间，否则直接添加
         **/
        
        if (_historyCacheArray.count) {
            NSInteger limitCount = _historyCacheArray.count-5;
            if (limitCount < 0) {
                limitCount = 0;
            }
            NSInteger i = _historyCacheArray.count-1;
            while (i >= limitCount) {
                BrowsedModel *model = _historyCacheArray[i];
                if ([model.title isEqualToString:webView.title]) {
                    model.createDate = [[NSDate date] timeIntervalSince1970];
                    _lastTitle = model.title;
                    return;
                }
                i--;
            }
        }
        
        BrowsedModel *model = [[BrowsedModel alloc] init];
        model.title = webView.title;
        model.absoluteURL = self.selectTab.webView.URL.absoluteString;
        model.type = BrowsedModelTypeHistory;
        model.createDate = [[NSDate date] timeIntervalSince1970];
        [self cacheHistoryModel:model immediately:NO];
        _lastTitle = webView.title;
    }
    
    
//    [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
//        NSLog(@"%zd", records.count);
//    }];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}
//进程被终止时调用，防止白屏
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    Tab *tab = [Tab new];
    tab.webView = [[TabWKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    tab.webView.UIDelegate = self;
    tab.webView.navigationDelegate = self;
    tab.webView.tabWebViewDelegate = self;
    [self.tabs addObject:tab];
    
    if ([self.tabDelegate respondsToSelector:@selector(tabManager:didCreateTab:)]) {
        [self.tabDelegate tabManager:self didCreateTab:tab];
    }
    
    return tab.webView;
}
//关闭一个webview
- (void)webViewDidClose:(WKWebView *)webView {
    
}
//输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
//确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}
//警告框
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cacheHistoryModel:nil immediately:YES];
}

@end
