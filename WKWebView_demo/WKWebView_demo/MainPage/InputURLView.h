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

@end

@interface InputURLView : UIView<UITextFieldDelegate>

@property (nonatomic, weak) id<InputURLViewDelegate> delegate;

@property (nonatomic, assign) BOOL isOnFocus;

@property (nonatomic, strong) NSURL *currentURL;


@end
