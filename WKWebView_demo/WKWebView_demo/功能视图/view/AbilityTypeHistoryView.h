//
//  AbilityTypeHistoryCell.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbilityTypeViewController.h"

@interface AbilityTypeHistoryView : UIView

@property (nonatomic, weak) AbilityTypeViewController *abilityVC;

@property (nonatomic, assign) NSInteger Index;

@property (nonatomic, assign) NSInteger currentShowIndex;

@end
