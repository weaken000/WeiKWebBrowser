//
//  BrowsedModel.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    BrowsedModelTypeHistory = 1,
    BrowsedModelTypeCollect,
    BrowsedModelTypeHome
} BrowsedModelType;

@interface BrowsedModel : NSObject

@property (nonatomic, copy) NSString *absoluteURL;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BrowsedModelType type;

@property (nonatomic, assign) long createDate;

@end
