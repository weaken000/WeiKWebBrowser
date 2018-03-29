//
//  GradientProgressBar.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/21.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "GradientProgressBar.h"

static const NSTimeInterval kAnimationDurcation = 0.2;

@implementation GradientProgressBar
{
    NSArray *_gradientColors;
    CAGradientLayer *_gradientLayer;
    CALayer *_alphaMaskLayer;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self updateAlphaMaskLayerWidthAnimated:YES];
}
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateAlphaMaskLayerWidthAnimated:YES];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gradientColors = @[((__bridge id)[UIColor redColor].CGColor),
                            ((__bridge id)[UIColor blueColor].CGColor),
                            ((__bridge id)[UIColor redColor].CGColor),
                            ((__bridge id)[UIColor blueColor].CGColor),
                            ((__bridge id)[UIColor redColor].CGColor),
                            ((__bridge id)[UIColor blueColor].CGColor),
                            ((__bridge id)[UIColor redColor].CGColor)];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    _alphaMaskLayer = [CALayer layer];
    _alphaMaskLayer.frame = self.bounds;
    _alphaMaskLayer.anchorPoint = CGPointZero;
    _alphaMaskLayer.position = CGPointZero;
    _alphaMaskLayer.cornerRadius = 3;
    _alphaMaskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.mask = _alphaMaskLayer;
    _gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width*2, self.bounds.size.height);
    _gradientLayer.colors = _gradientColors;
    _gradientLayer.locations = @[@0, @0.2, @0.4, @0.6, @0.8, @1, @1];
    _gradientLayer.startPoint = CGPointZero;
    _gradientLayer.endPoint = CGPointMake(1, 0);
    _gradientLayer.drawsAsynchronously = YES;
    [self.layer insertSublayer:_gradientLayer atIndex:0];
}

- (void)layoutSubviews {
    [self updateAlphaMaskLayerWidthAnimated:YES];
}

- (void)animateGradient {
    CABasicAnimation *gradientAnim = [CABasicAnimation animationWithKeyPath:@"locations"];
    gradientAnim.duration = 4 * kAnimationDurcation;
    gradientAnim.fromValue = @[@0, @0.2, @0.4, @0.6, @0.8, @1, @1];
    gradientAnim.toValue = @[@0, @0, @0, @0.2, @0.4, @0.6, @0.8];
    gradientAnim.repeatCount = INFINITY;
    gradientAnim.fillMode = kCAFillModeForwards;
    gradientAnim.removedOnCompletion = NO;
    [_gradientLayer addAnimation:gradientAnim forKey:@"colors"];
}

- (void)hiddenProgressBar {
    if (self.progress != 1) {
        return;
    }
    
    [CATransaction begin];
    
    CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnim.duration = kAnimationDurcation;
    positionAnim.fromValue = [NSValue valueWithCGPoint:_gradientLayer.position];
    positionAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width, 0)];
    [_gradientLayer addAnimation:positionAnim forKey:@"position"];
    
    [CATransaction setCompletionBlock:^{
        [self resetProgress];
    }];
    [CATransaction commit];
}

- (void)resetProgress {
    [self setProgress:0 animated:NO];
    self.hidden = YES;
}

- (void)updateAlphaMaskLayerWidthAnimated:(BOOL)animated {
    [CATransaction begin];
    [CATransaction setAnimationDuration:animated?kAnimationDurcation:0];
    
    _alphaMaskLayer.frame = CGRectMake(0, 0, self.bounds.size.width*self.progress, self.bounds.size.height);
    
    if (self.progress == 1) {
        [CATransaction setCompletionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDurcation * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hiddenProgressBar];
            });
        }];
    }
    [CATransaction commit];
}


- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (progress < self.progress && self.progress != 1) {
        return;
    }
    
    [_gradientLayer removeAnimationForKey:@"position"];
    self.hidden = NO;
    if ([_gradientLayer animationForKey:@"colors"] == nil) {
        [self animateGradient];
    }

    _progress = progress;
    [self updateAlphaMaskLayerWidthAnimated:animated];
}


@end
