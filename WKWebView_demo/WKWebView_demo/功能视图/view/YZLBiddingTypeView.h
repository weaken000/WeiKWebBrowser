//
//  YZLBiddingTypeView.h
//  HaveCar
//
//  Created by yzl on 17/9/27.
//  Copyright © 2017年 lwk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YZLBiddingTypeView : UIView

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, assign) CGFloat offsetPercent;

@property (nonatomic, assign) CGFloat noEffectOffsetPercent;

@property (nonatomic, assign) BOOL isHiddenLine;

@property (nonatomic, copy  ) void (^ typeSelectChanged)(NSInteger selectIndex);

- (instancetype)initWithTypes:(NSArray *)types;

- (void)reloadSelctColor:(UIColor *)selectColor normalColor:(UIColor *)normalColor;
//返回初始状态
- (void)rebackFirst;

@end
