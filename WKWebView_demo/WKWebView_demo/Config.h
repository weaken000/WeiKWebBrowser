//
//  Config.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#ifndef Config_h
#define Config_h

//设备高度相关宏
#define IS_IPONEX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))
#define STATUS_BAR_HEIGHT (IS_IPONEX ? (44.f) : (20.f))
#define TABBAR_HEIGHT (IS_IPONEX ? (44.f) : (20.f))
//#define NAVIGATIONBAR
#endif /* Config_h */
