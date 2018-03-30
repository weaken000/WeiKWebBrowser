//
//  InputURLView.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/28.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputURLView;

@protocol InputURLViewDelegate <NSObject>

- (void)inputURLView:(InputURLView *)urlView didClickDone:(NSString *)url;

- (void)inputURLView:(InputURLView *)urlView didIntoFocus:(BOOL)intoFocus;

- (void)inputURLView:(InputURLView *)urlView didClickCollect:(UIButton *)sender;

@end

@interface InputURLView : UIView<UITextFieldDelegate>

@property (nonatomic, weak) id<InputURLViewDelegate> delegate;

@property (nonatomic, assign) BOOL isOnFocus;

@property (nonatomic, assign) BOOL isCollect;

@property (nonatomic, strong) NSURL *currentURL;


@end
