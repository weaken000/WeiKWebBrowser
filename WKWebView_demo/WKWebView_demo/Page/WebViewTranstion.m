//
//  WebViewTranstion.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WebViewTranstion.h"
#import "ViewController.h"
#import "TabViewController.h"
#import "WebViewMaskView.h"
#import "WebViewCollectionViewCell.h"

@interface WebViewTranstion()

@property (nonatomic, assign) TranstionType transtionType;

@property (nonatomic, copy  ) void (^ completion)(void);

@end

@implementation WebViewTranstion


+ (WebViewTranstion *)transtionForType:(TranstionType)type complete:(void (^)(void))complete {
    WebViewTranstion *t = [WebViewTranstion new];
    t.transtionType = type;
    t.completion = [complete copy];
    return t;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transtionType == TranstionTypeShow) {
        [self animateTransitionForShow:transitionContext];
    }
    else {
        [self animateTransitionForDismiss:transitionContext];
    }
}

- (void)animateTransitionForShow:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    ViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    TabViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    //添加
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    toVC.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
    
    //添加蒙版
    UIImage *cropImage = [fromVC transitionFromImage];
    CGRect cropRect = [fromVC transitionFromRect];
    
    WebViewMaskView *cell = [[WebViewMaskView alloc] initWithFrame:cropRect];
    cell.frame = cropRect;
    [cell layoutIfNeeded];
    [cell configTitle:@"火狐" image:cropImage];
//    cell.header.transform = CGAffineTransformMakeTranslation(-cropRect.size.width, 0);
    [containerView addSubview:cell];
    
    CGRect toRect = [toVC reloadItem];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        cell.frame = toRect;
        //        cell.header.transform = CGAffineTransformIdentity;
        [cell layoutIfNeeded];
        
        toVC.view.transform = CGAffineTransformIdentity;
        
        [fromVC setTransitionHeaderAndFooter];
        fromVC.view.frame = toRect;
    } completion:^(BOOL finished) {
        [cell removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
   
    
}

- (void)animateTransitionForDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    TabViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];

    //添加蒙版
    WebViewCollectionViewCell *maskCell = [fromVC transitionFrameCell];
    CGRect cropRect = [maskCell.superview convertRect:maskCell.frame toView:fromVC.view];
    WebViewMaskView *cell = [[WebViewMaskView alloc] initWithFrame:cropRect];
    cell.header.hidden = YES;
    [cell layoutIfNeeded];
    
    [cell configTitle:maskCell->_titlelab.text image:maskCell->_corpImageView.image];
    
    //添加toVC
    toVC.view.frame = finalFrame;
    toVC->_webContainer.hidden = YES;
    [toVC.view layoutIfNeeded];
    CGRect toRect = [toVC transitionFromRect];
    
    toVC.view.frame = cropRect;
    [toVC.view layoutIfNeeded];
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:cell];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        cell.frame = toRect;
        [cell layoutIfNeeded];
        
        toVC.view.frame = finalFrame;
        [toVC setTransitionHeaderAndFooterIdentity];
    } completion:^(BOOL finished) {
        toVC->_webContainer.hidden = NO;
        [cell removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    

}


@end
