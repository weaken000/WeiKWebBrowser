//
//  WKDownLoadManager.h
//  WKWebView_demo
//
//  Created by mc on 2018/4/2.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import <Foundation/Foundation.h>


/** The download state */
typedef NS_ENUM(NSUInteger, WKDownloadState) {
    WKDownloadStateNone,           /** default */
    WKDownloadStateWillResume,     /** waiting */
    WKDownloadStateDownloading,    /** downloading */
    WKDownloadStateSuspened,       /** suspened */
    WKDownloadStateCompleted,      /** download completed */
    WKDownloadStateFailed          /** download failed */
};

/** The download prioritization */
typedef NS_ENUM(NSInteger, WKDownloadPrioritization) {
    WKDownloadPrioritizationFIFO,  /** first in first out */
    WKDownloadPrioritizationLIFO   /** last in first out */
};

@class WKDownloadReceipt;

@protocol WKDownloadReceiptDelegate <NSObject>

- (void)receipt:(WKDownloadReceipt *)receipt didChangedState:(WKDownloadState)state;

@end

@interface WKDownloadReceipt : NSObject

@property (nonatomic, copy  , readonly) NSString *url;
@property (nonatomic, assign, readonly) WKDownloadState state;

@property (nonatomic, assign, readonly) long long totalBytesWritten;
@property (nonatomic, assign, readonly) long long totalBytesExpectedToWrite;

@property (nonatomic, copy  , readonly) NSString *fileName;
@property (nonatomic, copy  , readonly) NSString *filePath;

@property (nonatomic, strong, readonly) NSOutputStream *stream;
@property (nonatomic, copy  , readonly) NSProgress *progress;

@property (nonatomic, weak) id<WKDownloadReceiptDelegate> receiptDelegate;

@end



@interface WKDownloadManager : NSObject

+ (instancetype)defaultManager;

- (void)clearCache;

//只有这个方法能够初始化开始下载
- (WKDownloadReceipt *)downloadFileWithURL:(NSString *)url
                                  progress:(void(^)(NSProgress *progress, WKDownloadReceipt *receipt))progress
                                   success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *url))success
                                   failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response,  NSError *error))failure;


- (WKDownloadReceipt *)receiptForURL:(NSString *)url;

- (void)suspendAll;

- (void)resumeWithURL:(NSString *)url;
- (void)resumeWithReceipt:(WKDownloadReceipt *)receipt;

- (void)suspendWithURL:(NSString *)url;
- (void)suspendWithReceipt:(WKDownloadReceipt *)receipt;

- (void)removeWithURL:(NSString *)url;
- (void)removeWithReceipt:(WKDownloadReceipt *)receipt;

@end
