//
//  ViewUtils.m
//  feiba
//
//  Created by Feiba on 16/8/12.
//  Copyright © 2016年 fangj. All rights reserved.
//

#import "AnimationUtils.h"

@implementation AnimationUtils
+ (void)showOpacityAnimatedWithView:(UIView *)view {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @0.;
    opacityAnimation.toValue = @1.;
    opacityAnimation.duration = ANIMATION_DURATION * 0.5f;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    view.layer.transform = CATransform3DIdentity;
    CATransform3D startingScale = CATransform3DScale(view.layer.transform, 0, 0, 0);
    CATransform3D overshootScale = CATransform3DScale(view.layer.transform, 1.05, 1.05, 1.0);
    CATransform3D undershootScale = CATransform3DScale(view.layer.transform, 0.98, 0.98, 1.0);
    CATransform3D endingScale = view.layer.transform;
    
    NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
    NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
    NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
    [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
    [keyTimes addObject:@1.0f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    scaleAnimation.values = scaleValues;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.duration = ANIMATION_DURATION;
    
    [view.layer addAnimation:animationGroup forKey:nil];
}

+ (void)dismissOpacityAnimatedWithView:(UIView *)view {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1.;
    opacityAnimation.toValue = @0.;
    opacityAnimation.duration = ANIMATION_DURATION;
    
    
    CATransform3D overShotTransform = CATransform3DScale(view.layer.transform, 1.05, 1.05, 1.0);
    CATransform3D transform = CATransform3DScale(view.layer.transform, 0.5f, 0.5f, 1.0);
    
    NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:view.layer.transform]];
    NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
    NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [scaleValues addObject:[NSValue valueWithCATransform3D:overShotTransform]];
    [keyTimes addObject:@0.5f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [scaleValues addObject:[NSValue valueWithCATransform3D:transform]];
    [keyTimes addObject:@1.0f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = scaleValues;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[opacityAnimation, scaleAnimation];
    animationGroup.duration = ANIMATION_DURATION;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animationGroup forKey:nil];
    
    view.layer.transform = transform;
}

//
+ (void)showPositionAnimatedWithView:(UIView *)view offset:(CGFloat)offset {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, offset);
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)dismissPositionAnimatedWithView:(UIView *)view {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)showCurveAnimatedWithView:(UIView *)view withOptions:(UIViewAnimationOptions)option {
    view.alpha = 0.0;
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:option animations:^{
        view.alpha = 1.0;
    } completion:nil];
}
+ (void)dismissCurveAnimatedWithView:(UIView *)view withOptions:(UIViewAnimationOptions)option {
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:option animations:^{
        view.alpha = 0.0;
    } completion:nil];
}

@end

