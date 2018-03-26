//
//  PageTabViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/26.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "PageTabViewController.h"

//最大拉伸距离
static const CGFloat kReservedStretchSpace = 150;
//最小压缩距离
static const CGFloat kReservedCompressSpace = 10;

@interface NodeView: UIView
@property (nonatomic, weak) NodeView *nextView;
@property (nonatomic, weak) NodeView *preView;
//静止时的frame
@property (nonatomic, assign) CGRect originRect;


- (NodeView *)rootNode;
- (void)updateNextY:(CGFloat)y;

- (void)updateStretchY:(CGFloat)y;
- (void)updateCompressY:(CGFloat)y;

//拉，从链表尾部开始向前查找
- (NodeView *)shouldStretch;
//压，从链表头部开始向后查找
- (NodeView *)shouldCompress;

@end
@implementation NodeView

- (NodeView *)rootNode {
    if (!self.preView) {
        return self;
    }
    return [self.preView rootNode];
}

- (NodeView *)shouldStretch {
    
    if (!_preView) {//没有前节点，直接不能拉
        return nil;
    }
    
    if (self.frame.origin.y - _preView.frame.origin.y >= kReservedStretchSpace) {
        //当前拉伸到最大值，不能再拉伸，看看前节点能不能拉升
        return [_preView shouldStretch];
    }
    else {//还可以拉，返回当前节点，设置y值
        return self;
    }
}

//需要使用根节点调用对象方法
- (NodeView *)shouldCompress {
    if (!_nextView) {//没有后节点，已经查找到最后，不能压，直接返回
        return nil;
    }
    if (_nextView.frame.origin.y - self.frame.origin.y <= kReservedCompressSpace) {
        //当前压到最大值，不能再压，看看后节点能不能压
        return [_nextView shouldCompress];
    }
    else {//还可以压，返回后节点，设置y值
        return _nextView;
    }
}

- (void)updateNextY:(CGFloat)y {
    if (self.nextView) {
        CGRect frame = self.nextView.originRect;
        frame.origin.y += y;
        //校对
        frame.origin.y = MAX(frame.origin.y, self.frame.origin.y + kReservedCompressSpace);
        self.nextView.frame = frame;
        
        [self.nextView updateNextY:y];//直接跟随
    }
}

//拉伸更新y值，从当前节点向前查找，y都是通过pan手势获得，所以不能每次都直接操作frame，应该操作每次静止时的frame(originRect)
- (void)updateStretchY:(CGFloat)y {
    if (!_preView) {
        return;
    }
    
    //设置当前值
    CGRect frame = _originRect;
    frame.origin.y += y;
    //校对,最大不能大于最大临界
    frame.origin.y = MIN(frame.origin.y, _preView.frame.origin.y+kReservedStretchSpace);
    self.frame = frame;
    
    CGFloat offsetY = frame.origin.y - _preView.frame.origin.y;//当前差值
    if (offsetY >= kReservedStretchSpace) {//当前差值达到最大差值时，开始滑动前节点视图
        CGFloat orginOffsetY = _originRect.origin.y - _preView.originRect.origin.y;
        //滑动前节点时，需要先减去初始化时的差值，该值为固定值
        [_preView updateStretchY:y-(kReservedStretchSpace-orginOffsetY)];
    }
}

//y都是通过pan手势获得，所以不能每次都直接操作frame，应该操作每次静止时的frame(originRect)
- (void)updateCompressY:(CGFloat)y {
    if (!_nextView) {//没有后节点，已经查询到最后，不需要设置任何位移

    }
    else {
        if (_nextView.frame.origin.y - self.frame.origin.y <= kReservedCompressSpace) {
            //当前frame与后节点frame相差最小值时，到达临界点，继续向后查找下一个节点
            [_nextView updateCompressY:y];
        }
        else {//未达到临界值，当前节点之后的所有节点都需要同时移动相同距离

            if (self.nextView) {

                CGRect frame = self.nextView.originRect;
                frame.origin.y += y;
                //校对
                frame.origin.y = MAX(frame.origin.y, self.frame.origin.y + kReservedCompressSpace);
                self.nextView.frame = frame;

                [self.nextView updateNextY:y];//直接跟随
            }
        }
    }
    
}



/*
 
 
 v1 originY = 40 y = 40; v2 originY = 80  y = 80;   v3  originY = 120 y = 120  
 offsetY = 140拉                                          到达临界
 v1              y = 40; v2       +30     y = 110;  v3    +110 +30    y = 260
 offsetY = 80压
 v1              y = 40; v3       -30     y = 50;   v3    +80         y = 200
 
 
 v1 originY = 40 y = 40; v2 originY = 190  y = 190;   v3  originY = 340 y = 340
 offsetY = -30压
 v1              y = 40; v2       -30      y = 160;   v3     -30        y = 310
 offsetY = -150压
 v1              y = 40; v2       -140     y = 50;    v3     -150       y = 170

 
 */



@end

@interface PageTabViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray<NodeView *> *viewArray;

@end

@implementation PageTabViewController {
    UIScrollView *_scrollView;
    UIView *_containerView;
    
    NodeView *_lastInsertView;
    NodeView *_activityView;
    
    CGFloat _lastOffsetY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, self.view.bounds.size.height-130)];
    _scrollView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_scrollView];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / 500.0;
    _scrollView.layer.sublayerTransform = transform;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width-40, 4 * 150 + 20);
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeView:)];
    pan.delegate = self;
    [_scrollView addGestureRecognizer:pan];

    [self deapPages];
}

- (void)swipeView:(UIPanGestureRecognizer *)gesture {

    switch (gesture.state) {
        case UIGestureRecognizerStateChanged: {
            
            CGFloat offsetY = [gesture translationInView:gesture.view].y;
            
            if (offsetY > _lastOffsetY && [_activityView shouldStretch]) {//可以拉伸
                _scrollView.scrollEnabled = NO;
                //当前节点向前
                [_activityView updateStretchY:offsetY];
                [_activityView updateNextY:offsetY];
                _lastOffsetY = offsetY;
                return;
            }
            
            if (offsetY < _lastOffsetY && [_viewArray.lastObject shouldCompress]) {//可以压缩
                
                if (_lastOffsetY != 0) {
                    offsetY -= _lastOffsetY;
                }
                else {
                    _lastOffsetY = offsetY;
                }
                
                _scrollView.scrollEnabled = NO;
                //根节点向后
                [_viewArray.lastObject updateCompressY:offsetY];
                
                return;
            }
            
            _lastOffsetY = 0;
            if (!_scrollView.isScrollEnabled) {
                _scrollView.scrollEnabled = YES;
            }
            
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            _lastOffsetY = 0;
            for (NodeView *view in _viewArray) {
                view.originRect = view.frame;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (point.y > CGRectGetMaxY(_lastInsertView.frame)) {//不在点击区域时，都不滑动
        _scrollView.scrollEnabled = NO;
        return NO;
    }
    _scrollView.scrollEnabled = YES;
    //计算获取activityView
    _activityView = nil;
    for (NodeView *view in _viewArray) {
        if (view.frame.origin.y <= point.y) {
            _activityView = view;
            break;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
////只有当前手势失败时，才去执行其他手势
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}


#pragma mark - create
- (void)deapPages {
    
    CGFloat totalW = _scrollView.bounds.size.width;
    
    NodeView *view1 = [self createLayerWithFrame:CGRectMake(0, 40, totalW, 300)];
    view1.originRect = CGRectMake(0, 40, totalW, 300);
    [_scrollView addSubview:view1];

    NodeView *view2 = [self createLayerWithFrame:CGRectMake(0, 190, totalW, 300)];
    view2.originRect = CGRectMake(0, 190, totalW, 300);
    [_scrollView addSubview:view2];
    
    NodeView *view3 = [self createLayerWithFrame:CGRectMake(0, 340, totalW, 300)];
    view3.originRect = CGRectMake(0, 340, totalW, 300);
    [_scrollView addSubview:view3];
    
    _lastInsertView = view3;
    
    _viewArray = @[view3, view2, view1];
    
    view1.nextView = view2;
    
    view2.preView = view1;
    view2.nextView = view3;
    
    view3.preView = view2;
    
}

- (NodeView *)createLayerWithFrame:(CGRect)frame {
    
    NodeView *view = [[NodeView alloc] initWithFrame:frame];
    view.layer.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
    view.layer.cornerRadius = 8.0;
    view.layer.zPosition = -5;
    
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 10;
    view.layer.shadowOffset = CGSizeMake(0, -5);
    
    return view;
}

@end


