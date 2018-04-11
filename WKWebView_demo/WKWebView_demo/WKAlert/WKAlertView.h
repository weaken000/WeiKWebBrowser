//
//  WKAlertView.h
//  WKWebView_demo
//
//  Created by mc on 2018/4/3.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WKAlertTypeSignSuccess,    //签到成功
    WKAlertTypeReceiveSuccess, //领取成功
    WKAlertTypeReceiveFailure, //领取失败
    WKAlertTypeShared,         //分享
    WKAlertTypeRedbag          //红包
} WKAlertType;

typedef enum : NSUInteger {
    WKShareTypeWechat,
    WKShareTypeWechatCircle, //朋友圈
    WKShareTypeQQ,
    WKShareTypeWeibo
} WKShareType;

@class WKAlertView;

@protocol WKAlertViewDelegate <NSObject>

@optional
//点击关闭，关闭弹框已经实现
- (void)alertViewDidClickDismiss:(WKAlertView *)alertView;
//点击确定、开红包，关闭弹框已经实现
- (void)alertViewDidClickComfirm:(WKAlertView *)alertView;
//点击领取和签到的底部广告，关闭弹框已经实现
- (void)alertViewDidClickBanner:(WKAlertView *)alertView;
//点击分享：参数分享类型、分享图片，关闭弹框已经实现
- (void)alertView:(WKAlertView *)alertView didClickShareType:(WKShareType)shareType shareImage:(UIImage *)shareImage;

@end


@interface WKAlertView : UIView


- (instancetype)initWithAlertType:(WKAlertType)alertType
                       goldNumber:(NSString *)goldNumber
                        bannerURL:(NSString *)bannerURL
                 shareBannerImage:(UIImage *)bannerImage;

@property (nonatomic, weak) id<WKAlertViewDelegate> alertDelegate;
//金币数：领取成功、签名成功、分享时需要在初始化方法设置
@property (nonatomic, copy) NSString *goldNumber;
//广告图片：领取成功、签名成功需要设置
@property (nonatomic, copy) NSString *bannerURL;
//广告图片: 分享需要设置
@property (nonatomic, strong) UIImage *bannerImage;

@end
