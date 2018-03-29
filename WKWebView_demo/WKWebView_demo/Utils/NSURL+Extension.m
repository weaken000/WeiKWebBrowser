//
//  NSURL+Extension.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "NSURL+Extension.h"

@implementation NSURL (Extension)

- (NSURL *)addScheme {
    if (!self.scheme.length || ![self.scheme containsString:@"http"]) {
        NSURLComponents *components = [[NSURLComponents alloc] init];
        components.scheme = @"http";
        components.host = self.host;
        components.path = self.path;
        return components.URL;
    }
    return self;
}
- (NSURL *)removeScheme {
//    if (self.scheme.length) {
//        NSURLComponents *components = [[NSURLComponents alloc] init];
//    }
    return self;
}

@end
