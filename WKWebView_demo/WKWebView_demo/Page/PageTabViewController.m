//
//  PageTabViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/26.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "PageTabViewController.h"
#import "PageSigleNodeView.h"

//最大拉伸距离
const CGFloat kReservedStretchSpace  = 150;
//最小压缩距离
const CGFloat kReservedCompressSpace = 10;
//根节点距离父视图的上边距
const CGFloat kTopMargin             = 10;

@interface PageTabViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray<PageSigleNodeView *> *viewArray;

@property (nonatomic, assign) NSInteger minVisiableCount;

@end

@implementation PageTabViewController {
    
    UIScrollView *_scrollView;
    UIView *_containerView;
    
    PageSigleNodeView *_firstNode;
    PageSigleNodeView *_lastNode;
    
    CGFloat _lastScrollOffsetY;
    CGFloat _lastOffsetY;
    
    NSInteger _itemCount;
    
}

- (instancetype)initWithItemCount:(NSInteger)itemCount {
    if (itemCount <= 0) return nil;
    
    if (self == [super init]) {
        _itemCount = itemCount;
        _minVisiableCount = 3;
    }
    return self;
}

#pragma mark - lift circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupContranier];
    
    [self setupDeapPage];
    
    [self setupNodeList];
    
    [self setupGesure];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - setup
- (void)setupContranier {
    
    CGRect containerFrame = CGRectMake(20, 100, self.view.frame.size.width-40, self.view.bounds.size.height-130);
    
    _containerView = [[UIView alloc] initWithFrame:containerFrame];
    _containerView.backgroundColor = [UIColor grayColor];
    _containerView.layer.masksToBounds = YES;
    [self.view addSubview:_containerView];

    _scrollView = [[UIScrollView alloc] initWithFrame:_containerView.bounds];
    _scrollView.delegate = self;
    _scrollView.transform = CGAffineTransformMakeRotation(M_PI);
    [_containerView addSubview:_scrollView];
    
    _scrollView.contentSize = CGSizeMake(0, kTopMargin + (_itemCount + _minVisiableCount - 1) * kReservedStretchSpace);
    _lastScrollOffsetY =  kTopMargin + (MIN(_minVisiableCount, _itemCount) - 1) * (kReservedStretchSpace - kReservedCompressSpace);
    _scrollView.contentOffset = CGPointMake(0, _lastScrollOffsetY);
}

- (void)setupDeapPage {
    
    NSMutableArray *tmp = [NSMutableArray array];
    CGFloat totalW = _containerView.bounds.size.width - 20;
    
    int i = 0;
    while (_itemCount - _minVisiableCount - i >= 0) {
        PageSigleNodeView *view = [[PageSigleNodeView alloc] init];
        [_containerView addSubview:view];
        view.frame = CGRectMake(10, kTopMargin + i * kReservedCompressSpace, totalW, 300);
        view.originRect = view.frame;
        [tmp addObject:view];
        i++;
    }
    
    CGFloat compressY = kTopMargin + i * kReservedCompressSpace;
    for (int j = i; j < _itemCount; j++) {
        PageSigleNodeView *view = [[PageSigleNodeView alloc] init];
        [_containerView addSubview:view];
        view.frame = CGRectMake(10, compressY + (j - i + 1) * kReservedStretchSpace, totalW, 300);
        view.originRect = view.frame;
        [tmp addObject:view];
    }
    
    _viewArray = [tmp copy];
    _firstNode = tmp.firstObject;
    _lastNode  = tmp.lastObject;
}

- (void)setupNodeList {
    PageSigleNodeView *pre;
    for (int i = 0; i < _viewArray.count; i++) {
        PageSigleNodeView *cur = [_viewArray objectAtIndex:i];
        cur.preView = pre;
        pre.nextView = cur;
        pre = cur;
    }
}

- (void)setupGesure {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.8;
    longPress.delaysTouchesBegan = YES;
    longPress.delegate = self;
    [_containerView addGestureRecognizer:longPress];
}

#pragma mark - Action
- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    
    
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
    
    NSLog(@" 获得长按手势 ");
}

- (void)deletePan:(UIPanGestureRecognizer *)gesture {
    
}

#pragma mark - private
- (void)deapPageScroll:(CGFloat)scrollOffsetY {
    if (scrollOffsetY > _lastOffsetY && [_lastNode shouldStretch]) {//可以拉伸, 末尾节点向前
        [_lastNode updateStretchY:scrollOffsetY];
        _lastOffsetY = scrollOffsetY;
        return;
    }
    
    if (scrollOffsetY < _lastOffsetY && [_firstNode shouldCompress]) {//可以压缩，根节点向后
        [_firstNode updateCompressY:_lastOffsetY-scrollOffsetY];
        _lastOffsetY = scrollOffsetY;
        return;
    }
    
    _lastOffsetY = scrollOffsetY;
    //已经不能拉伸或者压缩，整体进行移动
}

- (UIImage *)createMaskImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36, 36), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self deapPageScroll:scrollView.contentOffset.y - _lastScrollOffsetY];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //结束滑动，计算当前scrollView的位置
    _lastScrollOffsetY = scrollView.contentOffset.y;
    _lastOffsetY = 0;
    for (PageSigleNodeView *view in _viewArray) {
        view.originRect = view.frame;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    int i = _viewArray.count - 1;
    while (i >= 0) {
        PageSigleNodeView *node = [_viewArray objectAtIndex:i];
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end


