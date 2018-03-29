//
//  TabManager.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class Tab;

@interface TabManager : NSObject

@property (nonatomic, strong) Tab *selectTab;

@property (nonatomic, strong) NSMutableArray<Tab *> *tabs;

@property (nonatomic, assign) NSInteger selectIndex;

+ (instancetype)sharedInstance;

- (Tab *)createTab;

@end
