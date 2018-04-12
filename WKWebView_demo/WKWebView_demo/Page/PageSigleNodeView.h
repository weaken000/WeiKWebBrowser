//
//  PageSigleView.h
//  WKWebView_demo
//
//  Created by mc on 2018/4/11.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageSigleNodeView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, weak) PageSigleNodeView *nextView;

@property (nonatomic, weak) PageSigleNodeView *preView;
//静止时的frame
@property (nonatomic, assign) CGRect originRect;

- (PageSigleNodeView *)rootNode;
- (void)updateNextY:(CGFloat)y;

- (void)updateStretchY:(CGFloat)y;
- (void)updateCompressY:(CGFloat)y;

//拉，从链表尾部开始向前查找
- (PageSigleNodeView *)shouldStretch;
//压，从链表头部开始向后查找
- (PageSigleNodeView *)shouldCompress;

@end
