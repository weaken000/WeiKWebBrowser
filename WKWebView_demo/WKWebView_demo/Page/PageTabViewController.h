//
//  PageTabViewController.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/26.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>


extern const CGFloat kReservedStretchSpace, kReservedCompressSpace, kTopMargin;

@interface PageTabViewController : UIViewController

- (instancetype)initWithItemCount:(NSInteger)itemCount;

@end
