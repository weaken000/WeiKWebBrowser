//
//  TabBarViewController.m
//  Wedding
//
//  Created by irene on 16/5/11.
//  Copyright © 2016年 HYcompany. All rights reserved.
//

#import "TabBarViewController.h"
#import "BaseNavigationController.h"
//#import "BaseViewController.h"

#define TAG_BTN 0x0100

@interface TabBarViewController ()<UIViewControllerTransitioningDelegate>

{
    NSMutableArray *_buttonArr;
}

@end

@implementation TabBarViewController

#pragma mark - dealloc
- (void)dealloc {
//    DLog(@"TabBarViewController销毁");
}

#pragma mark - view Func
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 1.初始化子视图
    [self initSubviews];
    
    // 2.自定义标签栏
    [self initCustomTabBarView];
    
    
}

- (void)setNeedRemoveBid:(BOOL)needRemoveBid {
    _needRemoveBid = needRemoveBid;
    if (needRemoveBid) {
        [self removeBid];
    } else {
        [self insertBid];
    }
}

- (void)removeBid {
    
    NSMutableArray *tmp = [self.viewControllers mutableCopy];
    [tmp removeObjectAtIndex:1];
    self.viewControllers = tmp;
 
    [_buttonArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttonArr removeAllObjects];
    [self initCustomTabBarView];
}

- (void)insertBid {
//    NSMutableArray *tmp = [self.viewControllers mutableCopy];
//    Class cls = NSClassFromString(@"YZLBiddingViewController");
//    BaseViewController *controller = [[cls alloc] init];
//    BaseNavigationController *nav= [[BaseNavigationController alloc] initWithRootViewController:controller];
//    [tmp insertObject:nav atIndex:1];
//    self.viewControllers = [NSArray arrayWithArray:tmp];
//
//    [_buttonArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [_buttonArr removeAllObjects];
//    [self initCustomTabBarView];
}

#pragma mark - 初始化子视图
- (void)initSubviews {
//    NSArray *viewControllers = @[@"YZLHomeViewController",@"YZLBiddingViewController",@"YZLMessageViewController",@"YZLMeViewController"];
//
//    // 创建导航控制器
//    NSMutableArray *baseNavs = [NSMutableArray array];
//
//    for (NSInteger i = 0; i < viewControllers.count; i++) {
//        Class cls = NSClassFromString(viewControllers[i]);
//        if (cls) {
//            BaseViewController *controller = [[cls alloc] init];
//            BaseNavigationController *nav= [[BaseNavigationController alloc] initWithRootViewController:controller];
//            [baseNavs addObject:nav];
//        }
//    }
//    self.viewControllers = baseNavs;
}

#pragma mark - 自定义标签栏
- (void)initCustomTabBarView {
    // 1.移除系统tabbar按钮
    [self removeSystemTabbarButton];
    
    // 2.创建标签栏按钮
    // 01.标签栏按钮图片名字数组，标题名字数组
    NSArray *imageNames          = @[@"tab_off1", @"tab_off2", @"tab_off3", @"tab_off4"];
    NSArray *imageNames_selected = @[@"tab_on1", @"tab_on2", @"tab_on3", @"tab_on4"];
    NSArray *titles              = @[@"首页", @"竞拍大厅", @"消息", @"我的"];
    
    if (self.needRemoveBid) {
        imageNames          = @[@"tab_off1", @"tab_off3", @"tab_off4"];
        imageNames_selected = @[@"tab_on1", @"tab_on3", @"tab_on4"];
        titles              = @[@"首页", @"消息", @"我的"];
    }
    // 02.标签栏的宽度
//    float width_button = SCREEN_WIDTH / (float)imageNames.count;
//    
//    // 03.创建按钮
//    _buttonArr = [NSMutableArray arrayWithCapacity:imageNames.count];
//    for (NSInteger i = 0; i < imageNames.count; i++) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(width_button * i, 0, width_button, 49);
//        button.backgroundColor = [UIColor clearColor];
//        button.tag = i + TAG_BTN;
//        [button setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:imageNames_selected[i]] forState:UIControlStateSelected];
//        [button setTitle:titles[i] forState:UIControlStateNormal];
//        [button setTitleColor:RGB(120, 120, 120) forState:UIControlStateNormal];
//        [button setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
//        button.titleLabel.font = [UIFont systemFontOfSize:10.0f];
//        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:4.0];
//        [self.tabBar addSubview:button];
//        [_buttonArr addObject:button];
//        
//        if (i == 0) {//当刚进入时，选择第一个按钮作为选中状态
//            button.selected = YES;
//            self.selectedIndex = i;
//        }
//    }
}

// 标签按钮点击事件
- (void)buttonAction:(UIButton *)item {
    self.selectedIndex = item.tag - TAG_BTN;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    for (int i = 0; i < _buttonArr.count; i++) {
        UIButton *button = (UIButton *)_buttonArr[i];
        button.selected = NO;
    }
    UIButton *selectButton = (UIButton *)_buttonArr[selectedIndex];
    selectButton.selected = YES;
    [super setSelectedIndex:selectedIndex];
}

- (void)hasNewMessage:(BOOL)newMessage {
    for (int i = 0; i < self.childViewControllers.count; i++) {
        BaseNavigationController *navi = self.childViewControllers[i];
        if ([navi.childViewControllers.firstObject isMemberOfClass:NSClassFromString(@"YZLMessageViewController")]) {
            UIButton *button = _buttonArr[i];
            if (newMessage) {
                [button setImage:[UIImage imageNamed:@"off3_mes"] forState:UIControlStateNormal];
            }
            else {
                [button setImage:[UIImage imageNamed:@"tab_off3"] forState:UIControlStateNormal];
            }
            break;
        }
    }
}

// 移除系统tabbar按钮 UITabBarButton
- (void)removeSystemTabbarButton {
    // 遍历tabbar上面的所有子视图，移除上面的按钮
    for (UIView *view in self.tabBar.subviews) {
        Class c = NSClassFromString(@"UITabBarButton");
        if ([view isKindOfClass:[c class]]) {
            [view removeFromSuperview];
        }
    }
    
    UIView *subview = self.tabBar.subviews.firstObject;
    for (UIView *view in subview.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
            [view removeFromSuperview];
            break;
        }
    }
}

@end
