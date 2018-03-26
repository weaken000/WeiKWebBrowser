//
//  WKMessageHandler.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/22.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol WKMessageHandlerDelegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface WKMessageHandler : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKMessageHandlerDelegate> delegate;

@end
