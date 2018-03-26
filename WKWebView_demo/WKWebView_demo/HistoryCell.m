//
//  HistoryCell.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/22.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "HistoryCell.h"
#import "HistoryModel.h"
#import "UIImageView+WebCache.h"

@implementation HistoryCell

- (void)setHistoryInfo:(HistoryModel *)historyInfo {
    _historyInfo = historyInfo;
    self.textLabel.text = historyInfo.url;
    self.detailTextLabel.text = historyInfo.title;
    
    [self.imageView sd_setImageWithURL:historyInfo.iconURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"%@--%@", image, error.description);
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.textColor = [UIColor grayColor];
    self.textLabel.font = [UIFont systemFontOfSize:14.0];
    self.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
