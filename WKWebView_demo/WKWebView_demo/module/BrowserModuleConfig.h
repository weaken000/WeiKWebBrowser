//
//  BrowserModuleConfig.h
//  WKWebView_demo
//
//  Created by mc on 2018/4/2.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowserModuleConfig : NSObject

+ (instancetype)sharedInstance;
//夜间模式
@property (nonatomic, assign) BOOL isNight;
//无图模式
@property (nonatomic, assign) BOOL isNoPicture;
//全屏浏览
@property (nonatomic, assign) BOOL isFullScreenViewer;
//极速模式
@property (nonatomic, assign) BOOL isQuickness;

- (void)saveConfig;

@end
