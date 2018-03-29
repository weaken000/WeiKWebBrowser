//
//  TabBarViewController.h
//  Wedding
//
//  Created by irene on 16/5/11.
//  Copyright © 2016年 HYcompany. All rights reserved.
//

#import <UIKit/UIKit.h>

//是否是一级tabbar
#define IS_NOT_FIRST @"IS_NOT_FIRST"

@interface TabBarViewController : UITabBarController
// 移除系统tabbar按钮 UITabBarButton
- (void)removeSystemTabbarButton;

- (void)hasNewMessage:(BOOL)newMessage;

@property (nonatomic, assign) BOOL needRemoveBid;

@end
