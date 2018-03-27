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
    if (!_preView) {//没有后节点，已经查找到最后，不能压，直接返回
        return nil;
    }
    if (self.frame.origin.y - _preView.frame.origin.y <= kReservedCompressSpace) {
        //当前压到最大值，不能再压，看看后节点能不能压
        return [_preView shouldCompress];
    }
    else {//还可以压，返回当前节点，设置y值
        return self;
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
    if (frame.origin.y < _preView.frame.origin.y + kReservedCompressSpace) {
        frame.origin.y = _preView.frame.origin.y + kReservedCompressSpace;
    }
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
            if (y > 0) {
                y = -y;
            }
            
            CGRect frame = self.nextView.frame;
            frame.origin.y += y;
            frame.origin.y = MAX(frame.origin.y, self.frame.origin.y + kReservedCompressSpace);
            self.nextView.frame = frame;
            [_nextView updateCompressY:y];
        }
    }
    
}

@end

@interface PageTabViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray<NodeView *> *viewArray;

@property (nonatomic, strong) CADisplayLink *tiemr;

@end

@implementation PageTabViewController {
    UIScrollView *_scrollView;
    UIView *_containerView;
    
    NodeView *_lastInsertView;
    NodeView *_activityView;
    
    CGFloat _lastOffsetY;
    
    CGFloat _fromOffsetY;
    CGFloat _toOffsetY;
    
    CFTimeInterval _duraction;
    CFTimeInterval _lastStep;
    CFTimeInterval _timeOffset;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _duraction = 1.0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, self.view.bounds.size.height-130)];
    _scrollView.backgroundColor = [UIColor grayColor];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / 500.0;
    _scrollView.layer.sublayerTransform = transform;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width-40, 6 * kReservedStretchSpace + kReservedStretchSpace);

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeView:)];
    pan.delegate = self;
    [_scrollView addGestureRecognizer:pan];

    [self deapPages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_tiemr invalidate];
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - function
- (float)interpolateFromValue:(float)fromValue time:(float)time
{
    return interpolate(fromValue, _toOffsetY, time);
}

float interpolate(float from, float to, float time)
{
    return (to - from) * time + from;
}
float CubicEaseOut(float p)
{
    float f = (p - 1);
    return f * f * f * f * f + 1;
}

#pragma mark - private
- (void)timeInvalidate {
    if (_tiemr) {
        [_tiemr invalidate];
        _tiemr = nil;
    }
    
    _activityView = nil;
    _fromOffsetY = 0;
    _toOffsetY = 0;
    _lastStep = 0;
    _timeOffset = 0;
    _lastOffsetY = 0;
    
    for (NodeView *view in _viewArray) {
        view.originRect = view.frame;
    }
}

- (void)deapPageScroll:(CGFloat)scrollOffsetY isAuto:(BOOL)isAuto {
    if (scrollOffsetY > _lastOffsetY && [_activityView shouldStretch]) {//可以拉伸
        //当前节点向前
        [_activityView updateStretchY:scrollOffsetY];
        [_activityView updateNextY:scrollOffsetY];
        _lastOffsetY = scrollOffsetY;
        if (!isAuto) {
            _fromOffsetY = scrollOffsetY;
            _toOffsetY = scrollOffsetY + 60.0;
        }
        return;
    }
    
    if (scrollOffsetY < _lastOffsetY && [_activityView shouldCompress]) {//可以压缩
        //根节点向后
        [_viewArray.lastObject updateCompressY:_lastOffsetY-scrollOffsetY];
        _lastOffsetY = scrollOffsetY;
        if (!isAuto) {
            _fromOffsetY = scrollOffsetY;
            _toOffsetY = scrollOffsetY - 60.0;
        }
        return;
    }
}

#pragma mark - SEL
- (void)swipeView:(UIPanGestureRecognizer *)gesture {

    switch (gesture.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat offsetY = [gesture translationInView:gesture.view].y;
            [self deapPageScroll:offsetY isAuto:NO];
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            if (_activityView) {
                _lastStep = CACurrentMediaTime();
                _tiemr = [CADisplayLink displayLinkWithTarget:self selector:@selector(timePast:)];
                [_tiemr addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            }
            else {
                [self timeInvalidate];
            }
        }
            break;
        default:
            break;
    }
}

- (void)timePast:(CADisplayLink *)timer {
    
    CFTimeInterval thisStep = CACurrentMediaTime();
    CFTimeInterval stepDuration = thisStep - _lastStep;
    _lastStep = thisStep;
    _timeOffset = MIN(_timeOffset + stepDuration, _duraction);
    float time = _timeOffset / _duraction;
    time = CubicEaseOut(time);
    
    float offsetY = [self interpolateFromValue:_fromOffsetY time:time];
    [self deapPageScroll:offsetY isAuto:YES];
    
    if (_timeOffset >= _duraction) {
        [self timeInvalidate];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    [self timeInvalidate];
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (point.y > CGRectGetMaxY(_lastInsertView.frame)) {//不在点击区域时，都不滑动
        _scrollView.scrollEnabled = NO;
        return NO;
    }
    
    //计算获取activityView
    for (NodeView *view in _viewArray) {
        if (view.frame.origin.y <= point.y) {
            //判断当前view是否可以拉动缩动
            CGFloat offsetY = [gestureRecognizer translationInView:gestureRecognizer.view].y;
            if ((offsetY > 0 && [view shouldStretch]) || (offsetY < 0 && [view shouldCompress])) {//可以滑动
                _activityView = view;
                _scrollView.scrollEnabled = NO;
                return YES;
            }
            else {//不可滑动
                _scrollView.scrollEnabled = YES;
                return NO;
            }
        }
        
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

////只有当前手势失败时，才去执行其他手势
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    scrollView.scrollEnabled = YES;
//    [scrollView setContentOffset:CGPointZero animated:YES];
//}


#pragma mark - create
- (void)deapPages {
    
    CGFloat totalW = _scrollView.bounds.size.width;
    
    NodeView *view1 = [self createLayerWithFrame:CGRectMake(0, 40, totalW, 300)];
    view1.originRect = CGRectMake(0, 40, totalW, 300);
    [_scrollView addSubview:view1];

    NodeView *view2 = [self createLayerWithFrame:CGRectMake(0, 40+kReservedCompressSpace, totalW, 300)];
    view2.originRect = CGRectMake(0, 190, totalW, 300);
    [_scrollView addSubview:view2];
    
    NodeView *view3 = [self createLayerWithFrame:CGRectMake(0, 40+2*kReservedCompressSpace, totalW, 300)];
    view3.originRect = CGRectMake(0, 340, totalW, 300);
    [_scrollView addSubview:view3];
    
    NodeView *view4 = [self createLayerWithFrame:CGRectMake(0, 40+3*kReservedCompressSpace, totalW, 300)];
    view4.originRect = CGRectMake(0, 340, totalW, 300);
    [_scrollView addSubview:view4];
    
    NodeView *view5 = [self createLayerWithFrame:CGRectMake(0, 40+3*kReservedCompressSpace+kReservedStretchSpace, totalW, 300)];
    view5.originRect = CGRectMake(0, 340, totalW, 300);
    [_scrollView addSubview:view5];
    
    NodeView *view6 = [self createLayerWithFrame:CGRectMake(0, 40+3*kReservedCompressSpace+2*kReservedStretchSpace, totalW, 300)];
    view6.originRect = CGRectMake(0, 340, totalW, 300);
    [_scrollView addSubview:view6];
    
    _lastInsertView = view6;
    
    _viewArray = @[view6, view5, view4, view3, view2, view1];
    
    view1.nextView = view2;
    
    view2.preView = view1;
    view2.nextView = view3;
    
    view3.preView = view2;
    view3.nextView = view4;
    
    view4.preView = view3;
    view4.nextView = view5;
    
    view5.preView = view4;
    view5.nextView = view6;
    
    view6.preView = view5;
    
}

- (NodeView *)createLayerWithFrame:(CGRect)frame {
    
    NodeView *view = [[NodeView alloc] initWithFrame:frame];
    view.layer.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
    view.layer.cornerRadius = 8.0;
    view.layer.zPosition    = -5;
    
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius  = 10;
    view.layer.shadowOffset  = CGSizeMake(0, -5);
    
    return view;
}

@end


