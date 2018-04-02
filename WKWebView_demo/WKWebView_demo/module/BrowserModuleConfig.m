//
//  BrowserModuleConfig.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/2.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "BrowserModuleConfig.h"

NSString *const kMuduleConfig = @"kMuduleConfig";

@implementation BrowserModuleConfig

+ (instancetype)sharedInstance {
    static BrowserModuleConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BrowserModuleConfig alloc] init];
        
        NSDictionary *params = [[NSUserDefaults standardUserDefaults] objectForKey:kMuduleConfig];
        if (params) {
            instance.isNight = [[params objectForKey:@"isNight"] boolValue];
            instance.isNoPicture = [[params objectForKey:@"isNoPicture"] boolValue];
            instance.isQuickness = [[params objectForKey:@"isQuickness"] boolValue];
            instance.isFullScreenViewer = [[params objectForKey:@"isFullScreenViewer"] boolValue];
        }
        else {
            instance.isNight = NO;
            instance.isNoPicture = NO;
            instance.isQuickness = NO;
            instance.isFullScreenViewer = NO;
            [instance saveConfig];
        }
    });
    return instance;
}

- (void)saveConfig {
    
    NSDictionary *config = @{@"isNight": @(self.isNight),
                             @"isNoPicture": @(self.isNoPicture),
                             @"isQuickness": @(self.isQuickness),
                             @"isFullScreenViewer": @(self.isFullScreenViewer)
                             };
    [[NSUserDefaults standardUserDefaults] setObject:config forKey:kMuduleConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
