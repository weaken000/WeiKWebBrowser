//
//  WebViewTranstion.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TranstionTypeShow,
    TranstionTypeDismiss
} TranstionType;

@interface WebViewTranstion : NSObject<UIViewControllerAnimatedTransitioning>

+ (WebViewTranstion *)transtionForType:(TranstionType)type complete:(void(^)(void))complete;

@end
