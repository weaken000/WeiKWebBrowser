//
//  Tab.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface Tab : NSObject

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIImage *corpImage;

@end
