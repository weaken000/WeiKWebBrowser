//
//  WebViewMaskView.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewMaskView : UIView

@property (nonatomic, strong) UIView *header;

- (void)configTitle:(NSString *)title image:(UIImage *)image;

@end
