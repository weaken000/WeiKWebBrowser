//
//  BrowsedModel.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "BrowsedModel.h"

@implementation BrowsedModel

- (NSURL *)iconURL {
    
    NSURL *url = [NSURL URLWithString:self.absoluteURL];
    
    NSURLComponents *comp = [NSURLComponents new];
    comp.scheme = url.scheme;
    comp.host = url.host;
    comp.path = @"/favicon.ico";
    return comp.URL;
}

@end
