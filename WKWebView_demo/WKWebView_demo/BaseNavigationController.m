//
//  BaseNavigationController.m
//  mall
//
//  Created by irene on 16/3/8.
//  Copyright © 2016年 HZYuanzhoulvNetwork. All rights reserved.
//

#import "BaseNavigationController.h"
//#import "BaseViewController.h"
//#import "UINavigationController+Category.h"

@interface BaseNavigationController ()<UINavigationControllerDelegate, UINavigationBarDelegate>

@end

@implementation BaseNavigationController 

+ (void)initialize {
    UINavigationBar *bar = [UINavigationBar appearance];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.5]};
    [bar setTitleTextAttributes:attributes];
    [bar setTintColor:[UIColor whiteColor]];
    bar.barTintColor = [UIColor greenColor];
    bar.translucent = YES;
    bar.backgroundColor = [UIColor blueColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    [self findBottomLineUnder:self.navigationBar].hidden = YES;
}

- (UIImageView *)findBottomLineUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findBottomLineUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count == 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    
    
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
}

#pragma mark - 设置导航栏的样式
//设置导航栏的样式 ,只有在导航控制器中重写此方法,才能更改状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor) {
            NSString *version = [UIDevice currentDevice].systemVersion;
            if (version.doubleValue >= 10.0) {
//                [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//                    [self dealInteractionChanges:context];
//                }];
            }
            else {
//                [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//                    [self dealInteractionChanges:context];
//                }];
            }
        }
    }
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        [UIView animateWithDuration:cancelDuration animations:^{
            //CGFloat nowAlpha = [[context viewControllerForKey:UITransitionContextFromViewControllerKey].navBarAlpha floatValue];
            //[self setNeedsNavigationBackground:nowAlpha];
        }];
    }
    else {
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            //CGFloat toAlpha = [[context viewControllerForKey:UITransitionContextToViewControllerKey].navBarAlpha floatValue];
            //[self setNeedsNavigationBackground:toAlpha];
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - UINavigationBarDelegate
//- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
//    if (self.viewControllers.count >= navigationBar.items.count) {
//        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - 1];
//        [self setNeedsNavigationBackground:[popToVC.navBarAlpha floatValue]];
//    }
//}
//
//- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
//    [self setNeedsNavigationBackground:[self.topViewController.navBarAlpha floatValue]];
//}

@end
