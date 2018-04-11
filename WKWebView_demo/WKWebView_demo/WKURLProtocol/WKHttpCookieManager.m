//
//  WKHttpCookieManager.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/8.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WKHttpCookieManager.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@implementation WKHttpCookieManager

+ (instancetype)sharedInstance {
    static WKHttpCookieManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WKHttpCookieManager new];
    });
    return instance;
}

- (void)clearCookieCache:(void(^)(void))complete {

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
//#else
//#endif
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:[NSDate dateWithTimeIntervalSince1970:0] completionHandler:^{
            if (complete) {
                complete();
            }
        }];
    }
    else {
        NSString *cookiePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Cookies"];
        [[NSFileManager defaultManager] removeItemAtPath:cookiePath error:nil];
        if (complete) {
            complete();
        }
    }
}

@end
