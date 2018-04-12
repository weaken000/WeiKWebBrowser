//
//  PageSigleView.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/11.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "PageSigleNodeView.h"
#import "PageTabViewController.h"

@implementation PageSigleNodeView {
    UIImageView *_imageView;
    UIButton *_deleteButton;
    UILabel *_titleLab;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self setupSubviews];
        
        self.userInteractionEnabled = NO;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.0;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1.0;
        
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowRadius  = 10;
        self.layer.shadowOffset  = CGSizeMake(0, -5);
    }
    return self;
}

- (void)setupSubviews {
    _imageView = [UIImageView new];
    [self addSubview:_imageView];
    
    _deleteButton = [UIButton new];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self addSubview:_deleteButton];
    
    _titleLab = [UILabel new];
    _titleLab.textColor = [UIColor blackColor];
    _titleLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:_titleLab];
    
    _titleLab.text = @"首页";
    _imageView.image = [UIImage imageNamed:@"makemoney_share_background"];
}

- (void)layoutSubviews {
    CGFloat btnW = 35;
    _deleteButton.frame = CGRectMake(self.bounds.size.width-btnW, 0, btnW, btnW);
    _titleLab.frame = CGRectMake(btnW, 0, self.bounds.size.width - 2 * btnW, btnW);
    _imageView.frame = CGRectMake(0, btnW, self.bounds.size.width, self.bounds.size.height - btnW);
}



#pragma mark - public

- (PageSigleNodeView *)rootNode {
    if (!self.preView) {
        return self;
    }
    return [self.preView rootNode];
}

- (PageSigleNodeView *)shouldStretch {
    if (!_preView) {//没有前节点，直接不能拉
        return self;
    }
    
    if (self.frame.origin.y - _preView.frame.origin.y >= kReservedStretchSpace) {
        //当前拉伸到最大值，不能再拉伸，看看前节点能不能拉升
        return [_preView shouldStretch];
    }
    else {//还可以拉，返回当前节点，设置y值
        return self;
    }
}

//需要使用根节点调用对象方法
- (PageSigleNodeView *)shouldCompress {
    if (!_nextView) {//没有后节点，已经查找到最后，不能压，直接返回
        return self;
    }
    if (_nextView.frame.origin.y - self.frame.origin.y <= kReservedCompressSpace) {
        //当前压到最大值，不能再压，看看后节点能不能压
        return [_nextView shouldCompress];
    }
    else {//还可以压，返回当前节点，设置y值
        return self;
    }
}

- (void)updateNextY:(CGFloat)y {
    if (self.nextView) {
        CGRect frame = self.nextView.originRect;
        frame.origin.y += y;
        //校对
        frame.origin.y = MAX(frame.origin.y, self.frame.origin.y + kReservedCompressSpace);
        self.nextView.frame = frame;
        
        [self.nextView updateNextY:y];//直接跟随
    }
}

//拉伸更新y值，从当前节点向前查找，y都是通过pan手势获得，所以不能每次都直接操作frame，应该操作每次静止时的frame(originRect)
- (void)updateStretchY:(CGFloat)y {
    //设置当前值
    CGRect frame = _originRect;
    frame.origin.y += y;
    //校对,最大不能大于最大临界
    if (frame.origin.y < _preView.frame.origin.y + kReservedCompressSpace) {
        frame.origin.y = _preView.frame.origin.y + kReservedCompressSpace;
    }
    frame.origin.y = MIN(frame.origin.y, _preView.frame.origin.y+kReservedStretchSpace);
    self.frame = frame;
    
    CGFloat offsetY = frame.origin.y - _preView.frame.origin.y;//当前差值
    if (offsetY >= kReservedStretchSpace) {//当前差值达到最大差值时，开始滑动前节点视图
        CGFloat orginOffsetY = _originRect.origin.y - _preView.originRect.origin.y;
        //滑动前节点时，需要先减去初始化时的差值，该值为固定值
        [_preView updateStretchY:y-(kReservedStretchSpace-orginOffsetY)];
    }
}


//y都是通过pan手势获得，所以不能每次都直接操作frame，应该操作每次静止时的frame(originRect)
- (void)updateCompressY:(CGFloat)y {
    
    if (!_preView && self.frame.origin.y > 10) {//根节点,并且根节点不在初始位置，先让根节点归位
        CGRect frame = self.frame;
        frame.origin.y += y;
        frame.origin.y = MIN(frame.origin.y, 10);
        self.frame = frame;
        
        CGRect nextFrame = self.nextView.frame;
        nextFrame.origin.y += y;
        nextFrame.origin.y = MAX(nextFrame.origin.y, self.frame.origin.y + kReservedCompressSpace);
        self.nextView.frame = nextFrame;
        
        [_nextView updateCompressY:y];
        return;
    }
    
    if (_nextView.frame.origin.y - self.frame.origin.y <= kReservedCompressSpace && _nextView) {
        //当前frame与后节点frame相差最小值时，到达临界点，继续向后查找下一个节点
        [_nextView updateCompressY:y];
    }
    else {//未达到临界值，当前节点之后的所有节点都需要同时移动相同距离
        if (y > 0) {
            y = -y;
        }
        
        CGRect frame = self.nextView.frame;
        frame.origin.y += y;
        frame.origin.y = MAX(frame.origin.y, self.frame.origin.y + kReservedCompressSpace);
        self.nextView.frame = frame;
        [_nextView updateCompressY:y];
    }
}


@end
