//
//  DataBaseHelper.h
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BrowsedModel;

@interface DataBaseHelper : NSObject

+ (instancetype)sharedInstance;

+ (void)insertBrowsedRecord:(BrowsedModel *)browsed complete:(void (^)(BOOL success))complete;
+ (void)insertBrowsedRecords:(NSArray<BrowsedModel *> *)browsedList complete:(void (^)(BOOL success))complete;

//+ (void)updateBrowsedRecord:(BrowsedModel *)browsed complete:(void (^)(BOOL))complete;
//+ (void)updateBrowsedRecords:(NSArray<BrowsedModel *> *)browsedList complete:(void (^)(BOOL))complete;

+ (void)deleteBrowsedWhereCondition:(NSString *)condition complete:(void (^)(BOOL success))complete;

+ (void)selectBrowsedWhereCondition:(NSString *)condition complete:(void (^)(BOOL success, NSArray *array))complete;

@end
