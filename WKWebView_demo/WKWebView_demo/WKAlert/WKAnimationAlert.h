//
//  YZLDriverMeUserInfoAlertView.h
//  knight
//
//  Created by YZLDriver on 17/2/22.
//  Copyright © 2017年 hongdongjie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WKAlertAnimationTypeCenter,
    WKAlertAnimationTypeBottom,
    WKAlertAnimationTypeScale,
    WKAlertAnimationTypeCurve
} WKAlertAnimationType;

@interface WKAnimationAlert : UIView

+ (void)dismissComplete:(void(^)(void))complete;

+ (void)dismiss;



+ (void)showAlertWithInsideView:(UIView *)insideView animation:(WKAlertAnimationType)animation;

+ (void)showAlertWithInsideView:(UIView *)insideView animation:(WKAlertAnimationType)animation canTouchDissmiss:(BOOL)canTouchDissmiss;

+ (void)showAlertWithInsideView:(UIView *)insideView animation:(WKAlertAnimationType)animation canTouchDissmiss:(BOOL)canTouchDissmiss offset:(CGFloat)offset;

/*
 insideView  弹框内容视图
 animation   动画类型
 canTouchDissmiss 是否可以触碰边缘进行关闭弹框，默认不能
 superView   弹框的父视图，默认window
 offset      弹框偏移量，弹框显示的时候距离指定位置的偏移量，动画类型为center时，为距离中心的偏移量
 **/
+ (void)showAlertWithInsideView:(UIView *)insideView animation:(WKAlertAnimationType)animation canTouchDissmiss:(BOOL)canTouchDissmiss superView:(UIView *)superView offset:(CGFloat)offset;

@end
