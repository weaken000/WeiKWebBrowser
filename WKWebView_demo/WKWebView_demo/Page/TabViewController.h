//
//  TabViewController.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tab, TabViewController, WebViewCollectionViewCell;

@protocol TabViewControllerDelegate <NSObject>

@optional
- (void)tabViewController:(TabViewController *)tabViewController didDeleteTab:(Tab *)tab;
- (void)tabViewController:(TabViewController *)tabViewController didShowTab:(Tab *)tab;
- (void)tabViewControllerDidCreateTab:(TabViewController *)tabViewController;
@end

@interface TabViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, weak) id<TabViewControllerDelegate> tabDelegate;

@property (nonatomic, strong) UIView *header;

- (CGRect)reloadItem;

- (WebViewCollectionViewCell *)transitionFrameCell;

@end
