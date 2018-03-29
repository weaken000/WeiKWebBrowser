//
//  AbilityTypeViewController.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AbilityTypeViewController;

@protocol AbilityTypeViewControllerDelegate <NSObject>

- (void)abilitySubViewDidScroll:(AbilityTypeViewController *)ability;

- (void)ability:(AbilityTypeViewController *)ability didClickURL:(NSURL *)url;

@end

@interface AbilityTypeViewController : UIViewController

@property (nonatomic, weak) id<AbilityTypeViewControllerDelegate> delegate;

@property (nonatomic, strong) UIScrollView *scrollView;

- (void)subviewDidScroll;

- (void)subviewDidSelectURL:(NSURL *)url;

@end
