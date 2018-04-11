//
//  ViewUtils.h
//  feiba
//
//  Created by Feiba on 16/8/12.
//  Copyright © 2016年 fangj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ANIMATION_DURATION 0.6f

@interface AnimationUtils : NSObject

+ (void)showOpacityAnimatedWithView:(UIView *)view;

+ (void)dismissOpacityAnimatedWithView:(UIView *)view;

+ (void)showPositionAnimatedWithView:(UIView *)view offset:(CGFloat)offset;
+ (void)dismissPositionAnimatedWithView:(UIView *)view;

+ (void)showCurveAnimatedWithView:(UIView *)view withOptions:(UIViewAnimationOptions)option;
+ (void)dismissCurveAnimatedWithView:(UIView *)view withOptions:(UIViewAnimationOptions)option;
@end

