//
//  NSURL+Extension.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Extension)

- (NSURL *)removeScheme;

- (NSURL *)addScheme;

@end
