//
//  GradientProgressBar.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientProgressBar : UIView

@property (nonatomic, assign) float progress;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
