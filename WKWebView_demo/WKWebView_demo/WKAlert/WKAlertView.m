
//
//  WKAlertView.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/3.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WKAlertView.h"
#import "Masonry.h"
#import "UIButton+ImageTitleSpacing.h"
#import "WKAnimationAlert.h"

@implementation WKAlertView {
    
    WKAlertType _alertType;
    UIButton *_closeButton;//关闭按钮
    
    UILabel *_stateLab;
    UILabel *_descLab;
    UILabel *_glodNumberLab;//金币数标签
    UIImageView *_typeImageView;
    UIButton *_confirmbutton;//确认按钮
    UIImageView *_bannerImageView;//广告图片
    
    UIImageView *_shareBackgroundImageView;
    //分享按钮
    UIButton *_wechatButton;
    UIButton *_wechatCircleButton;
    UIButton *_weiboButton;
    UIButton *_qqButton;
    //开红包按钮
    UIButton *_openBagButton;
}

- (instancetype)initWithAlertType:(WKAlertType)alertType goldNumber:(NSString *)goldNumber bannerURL:(NSString *)bannerURL shareBannerImage:(UIImage *)bannerImage {
    if (self == [super init]) {
        
        _alertType = alertType;
        if (alertType == WKAlertTypeSignSuccess || alertType == WKAlertTypeReceiveFailure || alertType == WKAlertTypeReceiveSuccess) {
            [self setupSubviewsForSignAndReceiveWithGoldNumber:goldNumber url:bannerURL];
            self.bannerURL = bannerURL;
            self.goldNumber = goldNumber;
        }
        else if (alertType == WKAlertTypeShared) {
            [self setupSubviewsForShareWithGoldNumber:goldNumber];
            self.bannerImage = bannerImage;
            self.goldNumber = goldNumber;
        }
        else {
            [self setupSubviewForRedBag];
        }
    }
    return self;
}

#pragma mark - setter

- (void)setBannerURL:(NSString *)bannerURL {
    _bannerURL = bannerURL;
    //设置图片
    _bannerImageView.image = nil;
}

- (void)setGoldNumber:(NSString *)goldNumber {
    _goldNumber = goldNumber?:@"";
    if (_alertType == WKAlertTypeSignSuccess) {
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"恭喜获得+%@金币", goldNumber]];
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} range:NSMakeRange(0, 5)];
        [att addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:36.0]} range:NSMakeRange(5, goldNumber.length)];
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(5+goldNumber.length, 2)];
        [att addAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} range:NSMakeRange(0, 4)];
        [att addAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} range:NSMakeRange(4, 3+goldNumber.length)];
    }
    else if (_alertType == WKAlertTypeReceiveSuccess) {
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"成功领取+%@金币", goldNumber]];
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} range:NSMakeRange(0, 5)];
        [att addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:36.0]} range:NSMakeRange(5, goldNumber.length)];
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(5+goldNumber.length, 2)];
        [att addAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} range:NSMakeRange(0, 4)];
        [att addAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} range:NSMakeRange(4, 3+goldNumber.length)];
    }
    else if (_alertType == WKAlertTypeShared) {
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"赚了%@元", goldNumber]];
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} range:NSMakeRange(0, 2)];
        [att addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:36.0]} range:NSMakeRange(2, goldNumber.length)];
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(2+goldNumber.length, 1)];
        [att addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:198.0/255 green:139.0/255 blue:90.0/255 alpha:1.0]} range:NSMakeRange(0, 2)];
        [att addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:251.0/255 green:3.0/255 blue:50.0/255 alpha:1.0]} range:NSMakeRange(2, goldNumber.length + 1)];
        _glodNumberLab.attributedText = att;
    }
}

#pragma mark - Action
- (void)click_comfirmButton:(UIButton *)sender {
    if ([self.alertDelegate respondsToSelector:@selector(alertViewDidClickComfirm:)]) {
        [self.alertDelegate alertViewDidClickComfirm:self];
    }
    [WKAnimationAlert dismiss];
}
- (void)click_dismissButton:(UIButton *)sender {
    if ([self.alertDelegate respondsToSelector:@selector(alertViewDidClickDismiss:)]) {
        [self.alertDelegate alertViewDidClickDismiss:self];
    }
    [WKAnimationAlert dismiss];
}
- (void)tap_bannerImage {
    if ([self.alertDelegate respondsToSelector:@selector(alertViewDidClickBanner:)]) {
        [self.alertDelegate alertViewDidClickBanner:self];
    }
    [WKAnimationAlert dismiss];
}
- (void)click_shareButton:(UIButton *)sender {
    if ([self.alertDelegate respondsToSelector:@selector(alertView:didClickShareType:shareImage:)]) {
        UIImage *image = [self captureImageForShare];
        if (sender == _weiboButton) {
            [self.alertDelegate alertView:self didClickShareType:WKShareTypeWeibo shareImage:image];
        }
        else if (sender == _wechatButton) {
            [self.alertDelegate alertView:self didClickShareType:WKShareTypeWechat shareImage:image];
        }
        else if (sender == _wechatCircleButton) {
            [self.alertDelegate alertView:self didClickShareType:WKShareTypeWechatCircle shareImage:image];
        }
        else {
            [self.alertDelegate alertView:self didClickShareType:WKShareTypeQQ shareImage:image];
        }
    }
    [WKAnimationAlert dismiss];
}

#pragma mark - private
- (UIImage *)captureImageForShare {
    //生成上边的图片
    UIGraphicsBeginImageContextWithOptions(_shareBackgroundImageView.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_shareBackgroundImageView.layer renderInContext:context];
    UIImage *shareTopimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //设置整体frame
    CGFloat w = _shareBackgroundImageView.frame.size.width;
    CGFloat bottomH = w / self.bannerImage.size.width * self.bannerImage.size.height;
    CGSize captureSize = CGSizeMake(w, _shareBackgroundImageView.frame.size.height+bottomH);
    
    //绘制整图
    UIGraphicsBeginImageContextWithOptions(captureSize, NO, [UIScreen mainScreen].scale);
    [shareTopimage drawInRect:CGRectMake(0, 0, w, _shareBackgroundImageView.frame.size.height)];
    [self.bannerImage drawInRect:CGRectMake(0, _shareBackgroundImageView.frame.size.height,  w, bottomH)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    return result;
}




#pragma mark - setup
- (void)setupSubviewsForSignAndReceiveWithGoldNumber:(NSString *)goldNumber url:(NSString *)url {
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 7.0;
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [UIView new];
    [self addSubview:topView];
    
    _stateLab = [[UILabel alloc] init];
    _stateLab.font = [UIFont systemFontOfSize:22];
    _stateLab.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    [topView addSubview:_stateLab];
    
    _typeImageView = [UIImageView new];
    _typeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [topView addSubview:_typeImageView];
    
    _descLab = [UILabel new];
    [topView addSubview:_descLab];
    
    _confirmbutton = [UIButton new];
    _confirmbutton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_confirmbutton setTitle:@"确定" forState:UIControlStateNormal];
    _confirmbutton.backgroundColor = [UIColor colorWithRed:255.0/255 green:220.0/255 blue:49.0/255 alpha:1];
    [_confirmbutton setTitleColor:[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1] forState:UIControlStateNormal];
    [topView addSubview:_confirmbutton];
    
    _closeButton = [UIButton new];
    [topView addSubview:_closeButton];
    
    UIView *bottomView;
    if (_alertType != WKAlertTypeReceiveFailure) {
        _glodNumberLab = [UILabel new];
        [topView addSubview:_glodNumberLab];
        
        bottomView = [UIView new];
        [self addSubview:bottomView];
        
        _bannerImageView = [UIImageView new];
        [bottomView addSubview:_bannerImageView];
    }
    
    CGFloat totolH = 0;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(78);
    }];
    [_bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        if (bottomView) {
            make.bottom.equalTo(bottomView.mas_top);
        }
        else {
            make.bottom.mas_equalTo(0);
        }
    }];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
        make.width.height.mas_equalTo(20);
    }];
    
    if (bottomView) {
        totolH += 78;
        [_stateLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(50);
        }];
        totolH += 50;
        [_typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(_stateLab.mas_bottom).offset(30);
            make.height.mas_equalTo(64);
            make.width.equalTo(topView);
        }];
        totolH += 94;
        [_glodNumberLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(_typeImageView.mas_bottom).offset(35);
        }];
        totolH += 35;
        [_descLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(_glodNumberLab.mas_bottom).offset(15);
        }];
        totolH += 15;
    }
    else {
        [_typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(50);
            make.height.mas_equalTo(64);
            make.width.equalTo(topView);
        }];
        totolH += 114;
        [_stateLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(_typeImageView.mas_bottom).offset(35);
        }];
        totolH += 35;
        [_descLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(_stateLab.mas_bottom).offset(15);
        }];
        totolH += 15;
    }
    
    [_confirmbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(_descLab.mas_bottom).offset(25);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(180);
    }];
    _confirmbutton.layer.cornerRadius = 20;
    totolH += 105;
    
    switch (_alertType) {
        case WKAlertTypeReceiveSuccess:
        {
            _stateLab.text = @"恭喜你";
            _descLab.text = @"已放入钱包，每日自动兑换成现金";
            _typeImageView.image = [UIImage imageNamed:@"window_signed_succeed"];
        }
            break;
        case WKAlertTypeSignSuccess:
        {
            _stateLab.text = @"签到成功";
            _descLab.text = @"已放入钱包，每日自动兑换成现金";
            _typeImageView.image = [UIImage imageNamed:@"window_signed_succeed"];
        }
            break;
        case WKAlertTypeReceiveFailure:
        {
            _stateLab.text = @"很遗憾";
            _descLab.text = @"你来晚了，本时段已领取完毕";
            _typeImageView.image = [UIImage imageNamed:@"window_signed_failed"];
        }
            break;
        default:
            break;
    }
    self.goldNumber = goldNumber;
    
    _bannerImageView.backgroundColor = [UIColor redColor];
    _bannerImageView.userInteractionEnabled = YES;
    _closeButton.backgroundColor = [UIColor redColor];
    
    [_descLab sizeToFit];
    [_stateLab sizeToFit];
    [_glodNumberLab sizeToFit];
    totolH += _descLab.bounds.size.height;
    totolH += _stateLab.bounds.size.height;
    totolH += _glodNumberLab.bounds.size.height;
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-80, totolH);
    
    [_closeButton addTarget:self action:@selector(click_dismissButton:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmbutton addTarget:self action:@selector(click_comfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bannerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_bannerImage)]];
}

- (void)setupSubviewsForShareWithGoldNumber:(NSString *)goldNumber {
    
    UIView *topView = [UIView new];
    [self addSubview:topView];
    
    _shareBackgroundImageView = [UIImageView new];
    [topView addSubview:_shareBackgroundImageView];
    
    _glodNumberLab = [UILabel new];
    [_shareBackgroundImageView addSubview:_glodNumberLab];
    
    _closeButton = [UIButton new];
    [topView addSubview:_closeButton];
    
    UIView *leftLine = [UIView new];
    leftLine.backgroundColor = [UIColor whiteColor];
    leftLine.alpha = 0.16;
    [topView addSubview:leftLine];
    
    UIView *rightLine = [UIView new];
    rightLine.backgroundColor = [UIColor whiteColor];
    rightLine.alpha = 0.16;
    [topView addSubview:rightLine];
    
    UILabel *tipLab = [UILabel new];
    tipLab.text = @"晒收入";
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = [UIColor whiteColor];
    [topView addSubview:tipLab];
    
    UIView *bottomView = [UIView new];
    [self addSubview:bottomView];
    
    CGFloat totalH = 0;
    totalH += 100;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
    _wechatButton = [UIButton new];
    [_wechatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _wechatButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _wechatCircleButton = [UIButton new];
    [_wechatCircleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _wechatCircleButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _weiboButton = [UIButton new];
    [_weiboButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _weiboButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _qqButton = [UIButton new];
    [_qqButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _qqButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_weiboButton setImage:[UIImage imageNamed:@"makemoney_share_weibo"] forState:UIControlStateNormal];
    [_weiboButton setTitle:@"微博" forState:UIControlStateNormal];
    [_wechatButton setImage:[UIImage imageNamed:@"makemoney_share_wechat"] forState:UIControlStateNormal];
    [_wechatButton setTitle:@"微信" forState:UIControlStateNormal];
    [_wechatCircleButton setImage:[UIImage imageNamed:@"makemoney_share_friends"] forState:UIControlStateNormal];
    [_wechatCircleButton setTitle:@"朋友圈" forState:UIControlStateNormal];
    [_qqButton setImage:[UIImage imageNamed:@"makemoney_share_QQ"] forState:UIControlStateNormal];
    [_qqButton setTitle:@"QQ" forState:UIControlStateNormal];
    
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_wechatButton, _wechatCircleButton, _weiboButton, _qqButton]];
    stack.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-60, 80);
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.alignment = UIStackViewAlignmentFill;
    stack.spacing = 25;
    stack.distribution = UIStackViewDistributionFillEqually;
    [bottomView addSubview:stack];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [_qqButton sizeToFit];
    [_wechatCircleButton sizeToFit];
    [_wechatButton sizeToFit];
    [_weiboButton sizeToFit];
    [_qqButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
    [_wechatCircleButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
    [_wechatButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
    [_weiboButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
    
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(bottomView.mas_top);
    }];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(0);
    }];
    totalH += 35;
    UIImage *shareImage = [UIImage imageNamed:@"makemoney_share_background"];
    CGFloat shareH = shareImage.size.height / (shareImage.size.width / ([UIScreen mainScreen].bounds.size.width-60));
    [_shareBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width-60);
        make.top.equalTo(_closeButton.mas_bottom).offset(20);
        make.height.mas_equalTo(shareH);
    }];
    
    CGFloat scale = 34.0 / 87.0;
    [_glodNumberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.equalTo(_shareBackgroundImageView.mas_top).offset(scale*shareH);
    }];
    
    totalH += 20 + shareH;
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_shareBackgroundImageView.mas_bottom).offset(15);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(0);
    }];
    totalH += 45;
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_shareBackgroundImageView);
        make.right.equalTo(tipLab.mas_left);
        make.centerY.equalTo(tipLab);
        make.height.mas_equalTo(1);
    }];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_shareBackgroundImageView);
        make.left.equalTo(tipLab.mas_right);
        make.centerY.equalTo(tipLab);
        make.height.mas_equalTo(1);
    }];
    
    _closeButton.backgroundColor = [UIColor redColor];
    _shareBackgroundImageView.image = [UIImage imageNamed:@"makemoney_share_background"];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-60, totalH);
    
    [_closeButton addTarget:self action:@selector(click_dismissButton:) forControlEvents:UIControlEventTouchUpInside];
    NSArray *array = @[_wechatCircleButton, _wechatButton, _weiboButton, _qqButton];
    for (UIButton *btn in array) {
        [btn addTarget:self action:@selector(click_shareButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupSubviewForRedBag {
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-80, 397);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 7.0;
    
    CALayer *bottomLayer = [CALayer layer];
    bottomLayer.frame = CGRectMake(0, 242, self.bounds.size.width, 155);
    bottomLayer.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:57.0/255.0 blue:32.0/255.0 alpha:1.0].CGColor;
    [self.layer addSublayer:bottomLayer];
    
    CAShapeLayer *topCircleLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 242)];
    [path addQuadCurveToPoint:CGPointMake(0, 242) controlPoint:CGPointMake(self.bounds.size.width/2.0, 320)];
    [path closePath];
    topCircleLayer.path = path.CGPath;
    topCircleLayer.fillColor = [UIColor colorWithRed:243.0/255 green:78.0/255 blue:53.0/255 alpha:1.0].CGColor;
    [self.layer addSublayer:topCircleLayer];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0, 242)];
    [linePath addQuadCurveToPoint:CGPointMake(self.bounds.size.width, 242) controlPoint:CGPointMake(self.bounds.size.width/2, 320)];
    linePath.lineWidth = 5;
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = [UIColor colorWithRed:231.0/255.0 green:0 blue:0 alpha:1.0].CGColor;
    lineLayer.fillColor = nil;
    [self.layer addSublayer:lineLayer];
    
    _closeButton = [UIButton new];
    [self addSubview:_closeButton];
    
    UIImageView *iconImageView = [UIImageView new];
    [self addSubview:iconImageView];
    
    UILabel *tip1Lab = [UILabel new];
    tip1Lab.text = @"知趣新闻发";
    tip1Lab.textColor = [UIColor colorWithRed:1 green:219.0/255.0 blue:165.0/255.0 alpha:1.0];
    tip1Lab.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:tip1Lab];
    
    UILabel *tip2Lab = [UILabel new];
    tip2Lab.text = @"新人现金红包";
    tip2Lab.textColor = [UIColor colorWithRed:1 green:236.0/255.0 blue:186.0/255.0 alpha:1.0];
    tip2Lab.font = [UIFont systemFontOfSize:24.0];
    [self addSubview:tip2Lab];
    
    
    CGFloat delta = sqrt(78.0*78.0+(self.bounds.size.width/2.0)*(self.bounds.size.width/2.0));
    CGFloat t = delta * delta / 78.0;
    //半径
    CGFloat radius = self.bounds.size.width / 2 * delta / 78.0;
    CGFloat result = 78.0 - t + radius;
    CGPoint buttonCenter = CGPointMake(self.bounds.size.width / 2.0, 242 + result);
   
    _openBagButton = [UIButton new];
    [self addSubview:_openBagButton];
    _openBagButton.frame = CGRectMake(0, 0, 104, 104);
    _openBagButton.center = buttonCenter;
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(46);
        make.top.mas_equalTo(43);
    }];
    [tip1Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(iconImageView.mas_bottom).offset(40);
    }];
    [tip2Lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(tip1Lab.mas_bottom).offset(25);
    }];
    
    [_openBagButton setImage:[UIImage imageNamed:@"redpack_open"] forState:UIControlStateNormal];
    [_openBagButton addTarget:self action:@selector(click_comfirmButton:) forControlEvents:UIControlEventTouchUpInside];
}


@end
