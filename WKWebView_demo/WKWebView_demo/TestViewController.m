//
//  TestViewController.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/3.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "TestViewController.h"
#import "WKAlertView.h"
#import "Masonry.h"
#import "WKAnimationAlert.h"

@interface TestViewController ()<WKAlertViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    WKAlertView *alert = [[WKAlertView alloc] initWithAlertType:WKAlertTypeShared goldNumber:@"18.98" bannerURL:@"" shareBannerImage:[UIImage imageNamed:@"window_signed_succeed"]];
    alert.alertDelegate = self;
    [WKAnimationAlert showAlertWithInsideView:alert animation:WKAlertAnimationTypeCenter];
}

- (void)alertView:(WKAlertView *)alertView didClickShareType:(WKShareType)shareType shareImage:(UIImage *)shareImage {
    self.imageView.image = shareImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
