//
//  ViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "TabToolbar.h"
#import "GradientProgressBar.h"
#import "HistoryModel.h"
#import "HistoryTableViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKMessageHandler.h"

#import "TabManager.h"
#import "Tab.h"

#import "TabViewController.h"
#import "PageTabViewController.h"

@interface ViewController ()<WKMessageHandlerDelegate, TabToolbarDelegate, TabViewControllerDelegate>

//@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UITextField *urlTF;

@property (nonatomic, strong) UIButton *loadButton;

@property (nonatomic, strong) TabToolbar *tabToolbar;

@property (nonatomic, strong) GradientProgressBar *progressBar;

@property (nonatomic, strong) NSMutableArray *history;

@property (nonatomic, strong) WKUserContentController *userContent;

@property (nonatomic, strong) TabViewController *tabVC;

@end

@implementation ViewController {

    CGFloat _toolbarOffsetY;
    
    UIView *_header;
    UIView *_footer;
    UIView *_webContainer;
    UIView *_container;
    
    NSString *_lastTitle;
    
    TabManager *_tabManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.history = [NSMutableArray array];
    _lastTitle = @"";
    _tabManager = [TabManager sharedInstance];
    
    [self setupSubviews];
    
    _urlTF.text = @"https://www.baidu.com";
}

- (void)dealloc {
    //[_userContent removeScriptMessageHandlerForName:@"appInstance"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)setupSubviews {
    
    _tabVC = [TabViewController new];
    _tabVC.view.hidden = YES;
    _tabVC.tabDelegate = self;
    _tabVC.view.frame = self.view.bounds;
    [self addChildViewController:_tabVC];
    [self.view addSubview:_tabVC.view];
    
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
    
    _container = [UIView new];
    [self.view addSubview:_container];
    
    WKWebView *webView = [_tabManager addWebView];
    _webContainer = [UIView new];
    [_webContainer addSubview:webView];
    [_container addSubview:_webContainer];

//    UIPanGestureRecognizer *panScrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan_scrollGesture:)];
//    panScrollGesture.maximumNumberOfTouches = 1;
//    panScrollGesture.delegate = self;
//    [_webView.scrollView addGestureRecognizer:panScrollGesture];
    
    _header = [UIView new];
    _urlTF = [[UITextField alloc] init];
    _urlTF.borderStyle = UITextBorderStyleLine;
    _progressBar = [[GradientProgressBar alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 10)];
    [_header addSubview:_progressBar];
    [_header addSubview:_urlTF];
    
    _loadButton = [[UIButton alloc] init];
    _loadButton.backgroundColor = [UIColor grayColor];
    [_loadButton addTarget:self action:@selector(click_loadButton) forControlEvents:UIControlEventTouchUpInside];
    [_header addSubview:_loadButton];
    [_container addSubview:_header];
    
    _footer = [UIView new];
    _tabToolbar = [[TabToolbar alloc] initWithFrame:CGRectZero titles:@[@"后退", @"前进", @"刷新", @"分页", @"历史"]];
    _tabToolbar.delegate = self;
    [_footer addSubview:_tabToolbar];
    [_container addSubview:_footer];
    
    _container.frame = self.view.bounds;
    _header.frame = CGRectMake(0, 22, self.view.frame.size.width, 50);
    _urlTF.frame = CGRectMake(10, 0, _header.bounds.size.width-90, _header.frame.size.height);
    _loadButton.frame = CGRectMake(CGRectGetMaxX(_urlTF.frame)+10, 0, 60, _header.frame.size.height);
    
    _footer.frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50);
    _tabToolbar.frame = _footer.bounds;
    
    _webContainer.frame = CGRectMake(0, CGRectGetMaxY(_header.frame), self.view.frame.size.width, self.view.bounds.size.height-50-CGRectGetMaxY(_header.frame));
    webView.frame = _webContainer.bounds;
    
    _toolbarOffsetY = 22;
    
    [self addObserversForWebView:webView];
}

- (void)addObserversForWebView:(WKWebView *)webView {
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)click_loadButton {
    _tabVC.view.hidden = YES;
    [_tabManager.selectTab.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlTF.text]]];
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

- (void)showToolBarAnimated:(BOOL)animated {
    _toolbarOffsetY = 22;
}

- (void)hiddenToolBarAnimated:(BOOL)animated {
    _toolbarOffsetY = -28;
}

#pragma mark - KVO for WKWebView
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        //NSLog(@"estimatedProgress--%@", change[NSKeyValueChangeNewKey]);
        [_progressBar setProgress:[change[NSKeyValueChangeNewKey] floatValue] animated:YES];
    }
    else if ([keyPath isEqualToString:@"loading"]) {
        //NSLog(@"loading--%@", change[NSKeyValueChangeNewKey]);
        [_tabToolbar updateState:change[NSKeyValueChangeNewKey] forIndex:2];
    }
    else if ([keyPath isEqualToString:@"canGoBack"]) {
        //NSLog(@"canGoBack--%@", change[NSKeyValueChangeNewKey]);
        [_tabToolbar updateState:change[NSKeyValueChangeNewKey] forIndex:0];

    }
    else if ([keyPath isEqualToString:@"canGoForward"]) {
        //NSLog(@"canGoForward--%@", change[NSKeyValueChangeNewKey]);
        [_tabToolbar updateState:change[NSKeyValueChangeNewKey] forIndex:1];

    }
    else if ([keyPath isEqualToString:@"URL"]) {
        //NSLog(@"URL--%@", change[NSKeyValueChangeNewKey]);
    }
    else if ([keyPath isEqualToString:@"title"]) {
        NSString *title = change[NSKeyValueChangeNewKey];
        if ([_lastTitle compare:title] != NSOrderedSame && title.length) {
            _lastTitle = change[NSKeyValueChangeNewKey];
            HistoryModel *model = [[HistoryModel alloc] init];
            model.title = _lastTitle;
            model.url = _tabManager.selectTab.webView.URL.absoluteString;
            [self.history addObject:model];
        }
        //NSLog(@"title--%@\n url--%@", change[NSKeyValueChangeNewKey],  _webView.URL.absoluteString);
        
    }
    
}

#pragma mark - TabToolbarDelegate
- (void)toolbar:(TabToolbar *)toolBar pressIndex:(NSInteger)index {
    if (index == 0) {
        [_tabManager.selectTab.webView goBack];
    }
    else if (index == 1) {
        [_tabManager.selectTab.webView goForward];
    }
    else if (index == 2) {
        [_tabManager.selectTab.webView reload];
    }
    else if (index == 3) {
        _tabVC.view.hidden = NO;
        _container.hidden = YES;
        [self.tabVC reloadItemAtIndex:_tabManager.selectIndex complete:^{
            
        }];
    }
    else {
        [self.navigationController pushViewController:[PageTabViewController new] animated:YES];
//        HistoryTableViewController *next = [[HistoryTableViewController alloc] init];
//        next.historyList = self.history;
//        [self.navigationController pushViewController:next animated:YES];
        
    }
}

#pragma mark - TabViewControllerDelegate
- (void)tabViewController:(TabViewController *)tabViewController didShowTab:(Tab *)tab {
    if (_tabManager.selectTab != tab) {
        _tabManager.selectTab = tab;
        _webContainer.subviews.firstObject.hidden = YES;
    }
    tab.webView.hidden = NO;
    _container.hidden = NO;
    _tabVC.view.hidden = YES;
}
- (void)tabViewController:(TabViewController *)tabViewController didCreateTab:(Tab *)tab {
    WKWebView *webView = [_tabManager addWebView];
    [self addObserversForWebView:webView];
    
    [_webContainer.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    webView.frame = _webContainer.bounds;
    [_webContainer addSubview:webView];
}

- (void)tabViewController:(TabViewController *)tabViewController didDeleteTab:(Tab *)tab {
    
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

#pragma mark - UIScrollViewDelegate

#pragma mark - getter

@end
