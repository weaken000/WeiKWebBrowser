//
//  DeviceUtils.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtils : NSObject

+ (NSString *)deviceModelName;

+ (NSString *)systemVersion;

+ (NSString *)UUID;

@end
