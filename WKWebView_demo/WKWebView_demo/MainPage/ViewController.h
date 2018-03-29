//
//  ViewController.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    @public
    UIView *_webContainer;
}

- (CGRect)transitionFromRect;
- (UIImage *)transitionFromImage;
- (void)setTransitionHeaderAndFooter;
- (void)setTransitionHeaderAndFooterIdentity;

@end

