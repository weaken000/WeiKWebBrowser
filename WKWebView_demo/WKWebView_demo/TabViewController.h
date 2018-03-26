//
//  TabViewController.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tab, TabViewController;

@protocol TabViewControllerDelegate <NSObject>

@optional

- (void)tabViewController:(TabViewController *)tabViewController didDeleteTab:(Tab *)tab;
- (void)tabViewController:(TabViewController *)tabViewController didCreateTab:(Tab *)tab;
- (void)tabViewController:(TabViewController *)tabViewController didShowTab:(Tab *)tab;

@end

@interface TabViewController : UIViewController

@property (nonatomic, weak) id<TabViewControllerDelegate> tabDelegate;

- (void)reloadItemAtIndex:(NSInteger)index complete:(void (^)(void))complete;

@end
