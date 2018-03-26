//
//  WKMessageHandler.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/22.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WKMessageHandler.h"

@implementation WKMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
