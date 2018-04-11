//
//  WKHttpCookieManager.h
//  WKWebView_demo
//
//  Created by mc on 2018/4/8.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKHttpCookieManager : NSObject

+ (instancetype)sharedInstance;

- (void)clearCookieCache:(void(^)(void))complete;
@end
