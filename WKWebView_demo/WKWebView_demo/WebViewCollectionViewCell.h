//
//  WebViewCollectionViewCell.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/23.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewCollectionViewCell;

@protocol WebViewCollectionViewCellDelegate <NSObject>

@optional
- (void)collectionCell:(WebViewCollectionViewCell *)cell didClickDelete:(UIButton *)sender;

@end

@interface WebViewCollectionViewCell : UICollectionViewCell {
    @public
    UIImageView *_corpImageView;
    UILabel *_titlelab;
    UIButton *_deleteButton;
}

@property (nonatomic, weak) id<WebViewCollectionViewCellDelegate> delegate;

- (void)configTitle:(NSString *)title image:(UIImage *)image;

@end
