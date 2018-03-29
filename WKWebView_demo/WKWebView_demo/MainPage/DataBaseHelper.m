//
//  DataBaseHelper.m
//  WKWebView_demo
//
//  Created by mc on 2018/3/29.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "DataBaseHelper.h"
#import "FMDB.h"
#import "BrowsedModel.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"browsedList.sqlite"]

#define DB_NAME @"table_browsed"

@interface DataBaseHelper()

@property (nonatomic, strong) FMDatabase *dataBase;

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

static DataBaseHelper *_helper;

@implementation DataBaseHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[DataBaseHelper alloc] init];
        _helper.dataBase = [FMDatabase databaseWithPath:DB_PATH];
        _helper.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:DB_PATH];
        [_helper createTable];
    });
    return _helper;
}


- (void)createTable {
    if (![_dataBase tableExists:DB_NAME]) {
        if ([_dataBase open]) {
            NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (identifier integer primary key autoincrement, 'title' text, 'absoluteURL' text, 'type' integer, 'createDate' real)", DB_NAME];
            BOOL res = [_dataBase executeUpdate:sql];
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"success to creating db table");
            }
            [_dataBase close];
        }
        else {
            NSLog(@"error when open db");
        }
    }
}

+ (void)insertBrowsedRecord:(BrowsedModel *)browsed complete:(void (^)(BOOL))complete {
    [_helper.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = @"insert into table_browsed (title, absoluteURL, type, createDate) values(?, ?, ?, ?) ";
        BOOL result = [db executeUpdate:sql, browsed.title, browsed.absoluteURL, @(browsed.type), @(browsed.createDate)];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(result);
        });
    }];
}
+ (void)insertBrowsedRecords:(NSArray<BrowsedModel *> *)browsedList complete:(void (^)(BOOL))complete {
    [_helper.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (BrowsedModel *model in browsedList) {
            NSString *sql = @"insert into table_browsed (title, absoluteURL, type, createDate) values(?, ?, ?, ?) ";
            BOOL result = [db executeUpdate:sql, model.title, model.absoluteURL, @(model.type), @(model.createDate)];
            
            if (!result) {
                *rollback = YES;
                complete(result);
                return;
            }
        }
        complete(YES);
    }];
}

+ (void)updateBrowsedRecord:(BrowsedModel *)browsed complete:(void (^)(BOOL))complete {
    
}
+ (void)updateBrowsedRecords:(NSArray<BrowsedModel *> *)browsedList complete:(void (^)(BOOL))complete {
    
}

+ (void)deleteBrowsedWhereCondition:(NSString *)condition complete:(void (^)(BOOL))complete {
    
}

+ (void)selectBrowsedWhereCondition:(NSString *)condition complete:(void (^)(BOOL, NSArray *))complete {
    
    [_helper.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ %@", DB_NAME, condition];
        FMResultSet *resultSet = [db executeQuery:sql];
        NSMutableArray *array = [NSMutableArray array];
        while ([resultSet next]) {
            NSInteger type = [resultSet intForColumn:@"type"];
            NSString *title = [resultSet stringForColumn:@"title"];
            NSString *url = [resultSet stringForColumn:@"absoluteURL"];
            long date = [resultSet longForColumn:@"createDate"];
            
            BrowsedModel *model = [BrowsedModel new];
            model.title = title;
            model.absoluteURL = url;
            model.type = type;
            model.createDate = date;
            [array addObject:model];
        }
        complete(YES, array);
    }];
    
}

@end
