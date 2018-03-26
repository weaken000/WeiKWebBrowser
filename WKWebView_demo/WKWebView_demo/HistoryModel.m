//
//  HistoryModel.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/22.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "HistoryModel.h"

@implementation HistoryModel

- (NSURL *)iconURL {
    
    NSURL *tmpURL = [NSURL URLWithString:self.url];
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = tmpURL.scheme;
    components.port = tmpURL.port;
    components.host = tmpURL.host;
    components.path = @"/";
    return components.URL;
    
}

@end
