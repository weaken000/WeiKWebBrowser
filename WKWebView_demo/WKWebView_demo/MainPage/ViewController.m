//
//  ViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "ViewController.h"
#import "TabToolbar.h"
#import "GradientProgressBar.h"
#import "InputURLView.h"

#import "TabManager.h"
#import "Tab.h"
#import "DataBaseHelper.h"
#import "BrowsedModel.h"
#import "BrowserModuleConfig.h"

#import "TabViewController.h"
#import "PageTabViewController.h"
#import "AbilityTypeViewController.h"
#import "DownloadListViewController.h"

#import "Masonry.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKMessageHandler.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<TabToolbarDelegate, TabViewControllerDelegate, AbilityTypeViewControllerDelegate, InputURLViewDelegate, TabManagerDelegate>

@property (nonatomic, strong) TabToolbar *tabToolbar;

@property (nonatomic, strong) GradientProgressBar *progressBar;

@property (nonatomic, strong) AbilityTypeViewController *abilityVC;

@end

@implementation ViewController {

    CGFloat _toolbarOffsetY;
    NSString *_lastTitle;
    
    UIView *_header;
    UIView *_footer;
    
    UIView *_container;
    InputURLView *_urlInputView;

    TabManager *_tabManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tabManager = [TabManager sharedInstance];
    _tabManager.tabDelegate = self;
    
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_abilityVC) {
        _abilityVC = [AbilityTypeViewController new];
        _abilityVC.delegate = self;
        _abilityVC.view.frame = _webContainer.bounds;
        [self addChildViewController:_abilityVC];
        [_webContainer insertSubview:_abilityVC.view atIndex:0];
    }
}

- (void)setupSubviews {

    _container = [UIView new];
    [self.view addSubview:_container];
    _webContainer = [UIView new];
    [_container addSubview:_webContainer];
    _header = [UIView new];
    [_container addSubview:_header];
    _footer = [UIView new];
    [_container addSubview:_footer];
    
    _urlInputView = [[InputURLView alloc] initWithFrame:CGRectZero];
    _urlInputView.delegate = self;
    [_header addSubview:_urlInputView];
    _tabToolbar = [[TabToolbar alloc] initWithFrame:CGRectZero titles:@[@"后退", @"前进", @"刷新", @"分页", @"功能"]];
    _tabToolbar.delegate = self;
    _tabToolbar.backgroundColor = [UIColor whiteColor];
    [_footer addSubview:_tabToolbar];
    
    _progressBar = [[GradientProgressBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 4)];
    [_header addSubview:_progressBar];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0));
    }];
    [_header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    [_footer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    [_webContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(_header.mas_bottom).offset(10);
        make.bottom.equalTo(_footer.mas_top).offset(-10);
    }];
    
    [_tabToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [_progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(4);
        make.left.right.bottom.mas_equalTo(0);
    }];
    [_urlInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(8);
        make.bottom.equalTo(_progressBar.mas_top).offset(-5);
    }];
    
    
    UIView *footLine = [UIView new];
    footLine.backgroundColor = [UIColor lightGrayColor];
    [_footer addSubview:footLine];
    [footLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    Tab *tab = [_tabManager createTab];
    _tabManager.selectTab = tab;
    tab.webView.hidden = YES;
    [self addObserversForWebView:tab.webView];
    [_webContainer addSubview:tab.webView];
    [tab.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
//    [DataBaseHelper selectBrowsedWhereCondition:@"where type = 1" complete:^(BOOL success, NSArray *array) {
//        if (success && array.count) {
//
//        }
//    }];
}

- (void)addObserversForWebView:(WKWebView *)webView {
    if (!webView) return;

    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserversForWebView:(WKWebView *)webView {
    if (!webView) return;
    [webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [webView removeObserver:self forKeyPath:@"loading"];
    [webView removeObserver:self forKeyPath:@"canGoBack"];
    [webView removeObserver:self forKeyPath:@"canGoForward"];
    [webView removeObserver:self forKeyPath:@"URL"];
    [webView removeObserver:self forKeyPath:@"title"];
}


#pragma mark - public
- (UIImage *)transitionFromImage {
    return _tabManager.selectTab.corpImage;
}

- (CGRect)transitionFromRect {
    return [_webContainer.superview convertRect:_webContainer.frame toView:self.view];
}

- (void)setTransitionHeaderAndFooter {
    CGAffineTransform transformHeader = CGAffineTransformIdentity;
    transformHeader = CGAffineTransformTranslate(transformHeader, 0, -_header.bounds.size.height);
    transformHeader = CGAffineTransformScale(transformHeader, 1, 0.4);
    _header.transform = transformHeader;
    
    CGAffineTransform transformFoot = CGAffineTransformIdentity;
    transformFoot = CGAffineTransformTranslate(transformFoot, 0, _footer.bounds.size.height);
    transformFoot = CGAffineTransformScale(transformFoot, 1, 0.4);
    _footer.transform = transformFoot;
    
    _header.alpha = 0;
    _footer.alpha = 0;

    [self.view layoutIfNeeded];
}

- (void)setTransitionHeaderAndFooterIdentity {
    _header.transform = CGAffineTransformIdentity;
    _footer.transform = CGAffineTransformIdentity;
    _header.alpha = 1.0;
    _footer.alpha = 1.0;
}

#pragma mark - private
- (void)loadURL:(NSURL *)url {
    _abilityVC.view.hidden = YES;
    _tabManager.selectTab.webView.hidden = NO;
    
    if (!url.scheme.length || ![url.scheme containsString:@"http"]) {
        NSURLComponents *components = [[NSURLComponents alloc] init];
        components.scheme = @"http";
        components.host = url.host;
        components.path = url.path;
        url = components.URL;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_tabManager.selectTab.webView loadRequest:request];
    
    [_tabToolbar updateState:@(YES) forIndex:0];
}

- (void)showTab:(Tab *)tab {
    if (_tabManager.selectTab != tab) {//不相同tab，清除当前web，添加选择web的视图
        [_tabManager.selectTab.webView removeFromSuperview];
        [_webContainer addSubview:tab.webView];
        [tab.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        _tabManager.selectTab = tab;
        [self addObserversForWebView:tab.webView];
    }
    _urlInputView.currentURL = tab.webView.URL;
    if (!tab.webView.backForwardList.currentItem) {
        tab.webView.hidden = YES;
        [_abilityVC abilityHidden:NO];
        _urlInputView.isCollect = [_tabManager isCollectWithWebView:tab.webView];
    }
    else {
        tab.webView.hidden = NO;
        [_abilityVC abilityHidden:YES];
        [_tabToolbar updateState:@([tab.webView canGoForward]) forIndex:1];
        [_tabToolbar updateState:@(YES) forIndex:0];
        [_tabToolbar updateState:@(NO) forIndex:2];
    }
   
}

- (void)backToHome {
    _abilityVC.view.hidden = NO;
    _tabManager.selectTab.webView.hidden = YES;
    _urlInputView.currentURL = nil;
    [_tabToolbar updateState:@(YES) forIndex:1];
    [_tabToolbar updateState:@(NO) forIndex:0];
    [_tabToolbar updateState:@(YES) forIndex:2];
}

- (void)showOthers {
    BrowserModuleConfig *config = [BrowserModuleConfig sharedInstance];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"其他功能" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_0 = [UIAlertAction actionWithTitle:@"下载管理" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DownloadListViewController *next = [DownloadListViewController new];
        [self.navigationController pushViewController:next animated:YES];
    }];
    [alert addAction:action_0];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:config.isNight?@"日间模式":@"夜间模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BrowserModuleConfig sharedInstance].isNight = ![BrowserModuleConfig sharedInstance].isNight;
    }];
    [alert addAction:action_1];

    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:config.isFullScreenViewer?@"关闭全屏浏览":@"开启全屏浏览" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BrowserModuleConfig sharedInstance].isFullScreenViewer = ![BrowserModuleConfig sharedInstance].isFullScreenViewer;
    }];
    [alert addAction:action_2];

    UIAlertAction *action_3 = [UIAlertAction actionWithTitle:config.isNoPicture?@"关闭无图模式":@"开启无图模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BrowserModuleConfig sharedInstance].isNoPicture = ![BrowserModuleConfig sharedInstance].isNoPicture;
    }];
    [alert addAction:action_3];
    
    UIAlertAction *action_4 = [UIAlertAction actionWithTitle:config.isQuickness?@"关闭急速模式":@"开启急速模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [BrowserModuleConfig sharedInstance].isQuickness = ![BrowserModuleConfig sharedInstance].isQuickness;
    }];
    [alert addAction:action_4];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - KVO for WKWebView
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [_progressBar setProgress:[change[NSKeyValueChangeNewKey] floatValue] animated:YES];
    }
    else if ([keyPath isEqualToString:@"loading"]) {
        [_tabToolbar updateState:change[NSKeyValueChangeNewKey] forIndex:2];
    }
    else if ([keyPath isEqualToString:@"canGoBack"]) {//在首页是不能返回，其他都能返回
        
    }
    else if ([keyPath isEqualToString:@"canGoForward"]) {
        if (!change[NSKeyValueChangeNewKey]) {
            [_tabToolbar updateState:change[NSKeyValueChangeOldKey] forIndex:1];
        }
        else {
            [_tabToolbar updateState:change[NSKeyValueChangeNewKey] forIndex:1];
        }
    }
    else if ([keyPath isEqualToString:@"URL"]) {
        _urlInputView.currentURL = change[NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:@"title"]) {
        
    }
}

#pragma mark - TabManagerDelegate
- (void)tabManager:(TabManager *)tabManager didCreateTab:(Tab *)tab {
    [self showTab:tab];
    tab.webView.hidden = NO;
    [_abilityVC abilityHidden:YES];
}
- (void)tabManager:(TabManager *)tabManager didChangedCollectState:(BOOL)isCollect {
    _urlInputView.isCollect = isCollect;
}

#pragma mark - AbilityTypeViewControllerDelegate
- (void)abilitySubViewDidScroll:(AbilityTypeViewController *)ability {
    [self.view endEditing:YES];
}
- (void)ability:(AbilityTypeViewController *)ability didClickURL:(NSURL *)url {
    [self loadURL:url];
    _urlInputView.isOnFocus = NO;
    [self inputURLView:_urlInputView didIntoFocus:NO];
}

#pragma mark - InputURLViewDelegate
- (void)inputURLView:(InputURLView *)urlView didClickDone:(NSString *)url {
    NSURL *newURL = [NSURL URLWithString:url];
    [self loadURL:newURL];
}

- (void)inputURLView:(InputURLView *)urlView didClickCollect:(UIButton *)sender {
    if (!_tabManager.selectTab.webView.isLoading) {
        _urlInputView.isCollect = [_tabManager collectCurrentURL];
    }
}

- (void)inputURLView:(InputURLView *)urlView didIntoFocus:(BOOL)intoFocus {
    if (intoFocus) {//进入输入状态，显示首页
        [_tabManager cacheHistoryModel:nil immediately:YES];
        _tabManager.selectTab.webView.hidden = YES;
        [_abilityVC abilityHidden:NO];
    }
    else {
        if (_tabManager.selectTab.webView.URL) {
            _tabManager.selectTab.webView.hidden = NO;
            [_abilityVC abilityHidden:YES];
        }
        else {
            _tabManager.selectTab.webView.hidden = YES;
            [_abilityVC abilityHidden:NO];
        }
    }
}

#pragma mark - TabToolbarDelegate
- (void)toolbar:(TabToolbar *)toolBar pressIndex:(NSInteger)index {
    if (index == 0) {
        if ([_tabManager.selectTab.webView canGoBack]) {
            [_tabManager.selectTab.webView goBack];
        }
        else {//返回到首页
            [self backToHome];
        }
    }
    else if (index == 1) {
        if (_abilityVC.view.hidden == NO && _tabManager.selectTab.webView.backForwardList.currentItem) {
            [self showTab:_tabManager.selectTab];
        }
        else {
            [_tabManager.selectTab.webView goForward];
        }
    }
    else if (index == 2) {
        [_tabManager.selectTab.webView reload];
    }
    else if (index == 3) {
        [_abilityVC abilityHidden:YES];
        
        TabViewController *tabVC = [[TabViewController alloc] init];
        tabVC.tabDelegate = self;
        self.navigationController.delegate = tabVC;
        [self.navigationController pushViewController:tabVC animated:YES];
        
        if (_tabManager.selectTab.webView.isLoading) {
            [_progressBar setProgress:1.0 animated:YES];
            [_tabManager.selectTab.webView stopLoading];
        }
        [self removeObserversForWebView:_tabManager.selectTab.webView];
    }
    else {//
        [self showOthers];
    }
}

#pragma mark - TabViewControllerDelegate
- (void)tabViewControllerDidCreateTab:(TabViewController *)tabViewController {
    Tab *tab = [_tabManager createTab];//添加新的tab
    [self showTab:tab];
}

- (void)tabViewController:(TabViewController *)tabViewController didShowTab:(Tab *)tab {
    [self showTab:tab];
}

- (void)tabViewController:(TabViewController *)tabViewController didDeleteTab:(Tab *)tab {
    [_tabManager removeTab:tab];
}

#pragma mark - UIScrollViewDelegate

#pragma mark - getter




























- (void)dealloc {
    //[_userContent removeScriptMessageHandlerForName:@"appInstance"];
}
//#pragma mark - WKHTTPCookieStoreObserver
//- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore {
//
//}
//
//#pragma mark - WKMessageHandlerDelegate
//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//
//}
//
//
//
//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}



#pragma mark - other
- (void)other {
    
    
    //    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    //    config.preferences = [WKPreferences new];
    //    config.processPool = [WKProcessPool new];
    //    config.preferences.javaScriptEnabled = YES;
    //    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //    _userContent = [[WKUserContentController alloc] init];
    //
    //    //注入js
    //    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:@"alert(\"WKUserScript注入js\");" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    //    [config.userContentController addUserScript:userScript];
    //    config.userContentController = _userContent;
    //
    //    WKHTTPCookieStore *cookieStore = config.websiteDataStore.httpCookieStore;
    //    [cookieStore addObserver:self];
    //
    //    WKMessageHandler *messageHandler = [[WKMessageHandler alloc] init];
    //    messageHandler.delegate = self;
    //    [_userContent addScriptMessageHandler:messageHandler name:@"appInstance"];
    //
    //    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    //    _webView.UIDelegate = self;
    //    _webView.navigationDelegate = self;
    //    _webView.scrollView.delegate = self;
    //    _webView.scrollView.layer.masksToBounds = YES;
    
    
    
    //    UIPanGestureRecognizer *panScrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan_scrollGesture:)];
    //    panScrollGesture.maximumNumberOfTouches = 1;
    //    panScrollGesture.delegate = self;
    //    [_webView.scrollView addGestureRecognizer:panScrollGesture];
    
    
    //    _urlTF = [[UITextField alloc] init];
    //    _urlTF.borderStyle = UITextBorderStyleLine;
    //    _progressBar = [[GradientProgressBar alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 10)];
    //    [_header addSubview:_progressBar];
    //    [_header addSubview:_urlTF];
    //
    //    _loadButton = [[UIButton alloc] init];
    //    _loadButton.backgroundColor = [UIColor grayColor];
    //    [_loadButton addTarget:self action:@selector(click_loadButton) forControlEvents:UIControlEventTouchUpInside];
    //    [_header addSubview:_loadButton];
}

- (void)pan_scrollGesture:(UIPanGestureRecognizer *)panner {
    //    CGFloat offsetY = [panner translationInView:panner.view].y;
    //
    //    switch (panner.state) {
    //        case UIGestureRecognizerStateFailed:
    //        case UIGestureRecognizerStateCancelled:
    //        case UIGestureRecognizerStateEnded:
    //        {
    //            CGFloat curY = CGRectGetMidY(_header.frame);
    //            if (curY > 47) {
    //                [self showToolBarAnimated:YES];
    //            }
    //            else {
    //                [self hiddenToolBarAnimated:YES];
    //            }
    //        }
    //            break;
    //        case UIGestureRecognizerStateChanged:
    //        {
    //
    //            CGRect oldFrame = _header.frame;
    //            CGFloat newY = MIN(_toolbarOffsetY + offsetY, 22);
    //            newY = MAX(newY, -28);
    //            if (oldFrame.origin.y == newY) {
    //                return;
    //            }
    //            oldFrame.origin.y = newY;
    //            _header.frame = oldFrame;
    //
    //
    //            CGFloat realOffsetY = _toolbarOffsetY - newY;
    //            CGRect footFrame = _footer.frame;
    //            if (realOffsetY>0) {
    //                footFrame.origin.y = self.view.bounds.size.height-50+realOffsetY;
    //            }
    //            else {
    //                footFrame.origin.y = self.view.bounds.size.height+realOffsetY;
    //
    //            }
    //            _footer.frame = footFrame;
    //
    //            if (newY == 22) {
    //                _toolbarOffsetY = 22;
    //            }
    //            if (newY == -28) {
    //                _toolbarOffsetY = -28;
    //            }
    //        }
    //            break;
    //        case UIGestureRecognizerStateBegan:
    ////            NSLog(@"began");
    //            break;
    //        default:
    //            break;
    //    }
}
@end

