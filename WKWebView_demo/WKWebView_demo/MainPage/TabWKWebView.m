//
//  TabWKWebView.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/30.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TabWKWebView.h"

@implementation TabWKWebView

- (WKNavigation *)goBack {
    if ([self.tabWebViewDelegate respondsToSelector:@selector(tabWebViewWillBack:)]) {
        [self.tabWebViewDelegate tabWebViewWillBack:self];
    }
    return [super goBack];
}
- (WKNavigation *)goForward {
    
    if ([self.tabWebViewDelegate respondsToSelector:@selector(tabWebViewWillForward:)]) {
        [self.tabWebViewDelegate tabWebViewWillForward:self];
    }
    
    return [super goForward];
}
- (WKNavigation *)reload {
    
    if ([self.tabWebViewDelegate respondsToSelector:@selector(tabWebViewWillReload:)]) {
        [self.tabWebViewDelegate tabWebViewWillReload:self];
    }
    
    return [super reload];
}

@end
