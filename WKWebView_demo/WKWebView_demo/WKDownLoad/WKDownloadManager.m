//
//  WKDownLoadManager.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/2.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WKDownloadManager.h"
#import <CommonCrypto/CommonDigest.h>

#pragma mark - ********** define ***********
NSString * const WKDownloadCacheFolderName = @"WKDownloadCache";

static NSString * cacheFolder() {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    static NSString *cacheFolder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cacheFolder) {
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
            cacheFolder = [cacheDir stringByAppendingPathComponent:WKDownloadCacheFolderName];
        }
        NSError *error = nil;
        BOOL isDirectory;
        if (![filemgr fileExistsAtPath:cacheFolder isDirectory:&isDirectory]) {
            BOOL success = [filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error];
            if (!success) {
                NSLog(@"%@", error);
                cacheFolder = nil;
            }
        }
        
    });
    return cacheFolder;
}

static NSString * LocalReceiptsPath() {
    return [cacheFolder() stringByAppendingPathComponent:@"receipts.data"];
}

static unsigned long long fileSizeForPath(NSString *path) {
    
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

static NSString * getMD5String(NSString *str) {
    
    if (str == nil) return nil;
    
    const char *cstring = str.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}

typedef void (^sucessBlock)(NSURLRequest * _Nullable, NSHTTPURLResponse * _Nullable, NSURL * _Nonnull);
typedef void (^failureBlock)(NSURLRequest * _Nullable, NSHTTPURLResponse * _Nullable,  NSError * _Nonnull);
typedef void (^progressBlock)(NSProgress * _Nonnull, WKDownloadReceipt *);


#pragma mark - ********** WKDownloadReceipt ***********
@interface WKDownloadReceipt()

@property (nonatomic, copy  ) NSString        *url;
@property (nonatomic, strong) NSError         *error;
@property (nonatomic, assign) WKDownloadState state;

@property (nonatomic, assign) long long totalBytesWritten;
@property (nonatomic, assign) long long totalBytesExpectedToWrite;

@property (nonatomic, copy  ) sucessBlock   successBlock;
@property (nonatomic, copy  ) failureBlock  failureBlock;
@property (nonatomic, copy  ) progressBlock progressBlock;

@property (nonatomic, copy  ) NSString *fileName;
@property (nonatomic, copy  ) NSString *filePath;

@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, copy  ) NSProgress     *progress;

@end

@implementation WKDownloadReceipt

- (NSOutputStream *)stream {
    if (_stream == nil) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    }
    return _stream;
}

- (NSString *)filePath {
    if (!_filePath) {
        NSString *path = [cacheFolder() stringByAppendingPathComponent:self.fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSString *dir = [path stringByDeletingLastPathComponent];
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
        _filePath = path;
    }
    return _filePath;
}

- (NSString *)fileName {
    if (!_fileName) {
        NSString *extension = self.url.pathExtension;
        if (extension.length) {
            _fileName = [NSString stringWithFormat:@"%@.%@", getMD5String(self.url), extension];
        }
        else {
            _fileName = getMD5String(self.url);
        }
    }
    return _fileName;
}

- (NSProgress *)progress {
    if (_progress == nil) {
        _progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    @try {
        _progress.totalUnitCount = self.totalBytesExpectedToWrite;
        _progress.completedUnitCount = self.totalBytesWritten;
    } @catch (NSException *exception) {
        
    }
    return _progress;
}

- (long long)totalBytesWritten {
    return fileSizeForPath(self.filePath);
}

- (instancetype)initWithURL:(NSString *)url {
    if (self = [self init]) {
        self.url = url;
        self.totalBytesExpectedToWrite = 1;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(filePath))];
    [aCoder encodeObject:@(self.state) forKey:NSStringFromSelector(@selector(state))];
    [aCoder encodeObject:self.fileName forKey:NSStringFromSelector(@selector(fileName))];
    [aCoder encodeObject:@(self.totalBytesWritten) forKey:NSStringFromSelector(@selector(totalBytesWritten))];
    [aCoder encodeObject:@(self.totalBytesExpectedToWrite) forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        self.filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filePath))];
        self.state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(state))] unsignedIntegerValue];
        self.fileName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileName))];
        self.totalBytesWritten = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesWritten))] unsignedIntegerValue];
        self.totalBytesExpectedToWrite = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))] unsignedIntegerValue];
        
    }
    return self;
}

@end


#pragma mark - ********** WKDownloadManager ***********
@interface WKDownloadManager()<NSURLSessionDataDelegate>

@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;

@property (nonatomic, strong) NSURLSession *session;
//已经进入下载的task
@property (nonatomic, strong) NSMutableDictionary *activityTasks;
//等待序列
@property (nonatomic, strong) NSMutableArray<WKDownloadReceipt *> *queuedTasks;
//所有下载记录历史
@property (nonatomic, strong) NSMutableArray<WKDownloadReceipt *> *allDownloadReceipts;

@property (nonatomic, assign) NSUInteger maxActivityReqeustCount;
@property (nonatomic, assign) NSInteger  activeRequestCount;
@property (nonatomic, assign) WKDownloadPrioritization downloadPrioritization;
@end

@implementation WKDownloadManager

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.HTTPMaximumConnectionsPerHost = 10;
    return configuration;
}

+ (instancetype)defaultManager {
    static WKDownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WKDownloadManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    NSURLSessionConfiguration *config = [self.class defaultURLSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:queue];
    return [self initWithURLSession:session downloadPrioritization:WKDownloadPrioritizationFIFO maxActivityRequestCount:2];
}

- (instancetype)initWithURLSession:(NSURLSession *)session downloadPrioritization:(WKDownloadPrioritization)prioritization maxActivityRequestCount:(NSUInteger)count {
    if (self == [super init]) {
        _session = session;
        _maxActivityReqeustCount = count;
        _activeRequestCount = 0;
        _downloadPrioritization = prioritization;
        
        _activityTasks = [NSMutableDictionary dictionary];
        _queuedTasks = [NSMutableArray array];
        
        NSString *name = @"com.wk.downloadManager.synchronizationqueue-%@";
        _synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - getter
- (NSMutableArray *)allDownloadReceipts {
    if (!_allDownloadReceipts) {
        NSArray *receipts = [NSKeyedUnarchiver unarchiveObjectWithFile:LocalReceiptsPath()];
        _allDownloadReceipts = receipts != nil ? receipts.mutableCopy : [NSMutableArray array];
    }
    return _allDownloadReceipts;
}

#pragma mark - Private
- (WKDownloadReceipt *)receiptForURL:(NSString *)url {
    if (!url.length) return nil;
    for (WKDownloadReceipt *receipt in self.allDownloadReceipts) {
        if ([receipt.url isEqualToString:url]) {
            return receipt;
        }
    }
    return nil;
}

- (void)saveAllDownloadReceipts:(NSArray<WKDownloadReceipt *> *)receipts {
    [NSKeyedArchiver archiveRootObject:receipts toFile:LocalReceiptsPath()];
}
- (BOOL)isActivityRequestCountBelowMaxCount {
    return _activeRequestCount < _maxActivityReqeustCount;
}
- (WKDownloadReceipt *)updateReceiptWithURL:(NSString *)url state:(WKDownloadState)state {
    WKDownloadReceipt *receipt = [self receiptForURL:url];
    receipt.state = state;
    [self saveAllDownloadReceipts:self.allDownloadReceipts];
    return receipt;
}


#pragma mark - Public Load
//两种情况，一种是调用resume发现已经在队列中，但还没有开始下载另外一种是根本不存在改下载任务
- (WKDownloadReceipt *)downloadFileWithURL:(NSString *)url
                                  progress:(void (^)(NSProgress *, WKDownloadReceipt *))progress
                                   success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSURL *))success
                                   failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure {
    
    WKDownloadReceipt *receipt = [self receiptForURL:url];
    if (!receipt) {
        receipt = [[WKDownloadReceipt alloc] initWithURL:url];
    }
    receipt.successBlock = success;
    receipt.progressBlock = progress;
    receipt.failureBlock = failure;
    
    dispatch_async(self.synchronizationQueue, ^{
        
        //如果已经存在，就需要及时返回当前对应的状态
        if (receipt.state == WKDownloadStateFailed) {
            receipt.failureBlock(nil, nil, receipt.error);
            return;
        }
        if (receipt.state == WKDownloadStateCompleted && receipt.totalBytesWritten == receipt.totalBytesExpectedToWrite) {
            receipt.successBlock(nil, nil, [NSURL URLWithString:receipt.url]);
            return;
        }
        
        if (receipt.state != WKDownloadStateNone) {
            receipt.progressBlock(receipt.progress, receipt);
        }
        
        
        /*
         下载规则：调用当前方法时，不代表立即开始下载，只是确认添加到下载历史中，同时如果之前已经有过下载记录（根据url判断，新建的receipt的state为WKDownloadStateNone），则需要返回之前的下载记录，不再重新开启task下载
         如果当前未到达同时下载最大数量时，加入活动字典中并且马上开始下载，，
         如果已经到达最大数量，不做操作.
         根据下载策略(FIFO、FILO)加入等待下载的数组中
         **/
        
        if ([self isActivityRequestCountBelowMaxCount]) {
            receipt.state = WKDownloadStateDownloading;
            NSURLSessionDataTask *task = _activityTasks[receipt.url];
            if (!task) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:receipt.url]];
                request.HTTPMethod = @"GET";
                NSString *range = [NSString stringWithFormat:@"bytes=%zd-", receipt.totalBytesWritten];
                [request setValue:range forHTTPHeaderField:@"Range"];
                task = [self.session dataTaskWithRequest:request];
                task.taskDescription = receipt.url;
                self.activityTasks[receipt.url] = task;
            }
            [task resume];
            self.activeRequestCount++;
        }
        else {
            receipt.state = WKDownloadStateWillResume;
        }
        
        //加入下载序列
        if (![self.queuedTasks containsObject:receipt]) {
            if (self.downloadPrioritization == WKDownloadPrioritizationFIFO) {
                [self.queuedTasks addObject:receipt];
            }
            else {
                [self.queuedTasks insertObject:receipt atIndex:0];
            }
        }
        
        //添加记录
        if (![self.allDownloadReceipts containsObject:receipt]) {
            [self.allDownloadReceipts addObject:receipt];
            [self saveAllDownloadReceipts:self.allDownloadReceipts];
        }
        
    });
    
    return receipt;
}

- (void)clearCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:cacheFolder() error:nil];
}

#pragma mark - Public Action
- (void)resumeWithURL:(NSString *)url {
    WKDownloadReceipt *receipt = [self receiptForURL:url];
    [self resumeWithReceipt:receipt];
}

- (void)resumeWithReceipt:(WKDownloadReceipt *)receipt {
    if (!receipt) return;//说明当前模型已经存在所有记录中

    if (![self isActivityRequestCountBelowMaxCount]) {//暂停一个任务
        [self suspendWithURL:self.activityTasks.allKeys.firstObject];
    }
    [self downloadFileWithURL:receipt.url progress:receipt.progressBlock success:receipt.successBlock failure:receipt.failureBlock];
}

- (void)suspendWithURL:(NSString *)url {
    WKDownloadReceipt *receipt = [self receiptForURL:url];
    [self suspendWithReceipt:receipt];
}
- (void)suspendWithReceipt:(WKDownloadReceipt *)receipt {
    if (!receipt) return;//已经存在任务队列中
    if (!_activityTasks[receipt.url]) return;//任务还没有开始下载，无法暂停
    
    NSURLSessionDataTask *task = _activityTasks[receipt.url];
    if (receipt.state == WKDownloadStateDownloading) {
        [task suspend];
    }
    
    _activeRequestCount--;
    [self updateReceiptWithURL:receipt.url state:WKDownloadStateSuspened];
}

- (void)removeWithURL:(NSString *)url {
    WKDownloadReceipt *receipt = [self receiptForURL:url];
    [self removeWithReceipt:receipt];
}
- (void)removeWithReceipt:(WKDownloadReceipt *)receipt {
    if (!receipt) return;//存在任务队列中
    
    NSURLSessionDataTask *task = _activityTasks[receipt.url];
    if (task) {//已经开始下载，取消下载
        [task cancel];
        [_activityTasks removeObjectForKey:receipt.url];
        _activeRequestCount--;
    }
    
    [_queuedTasks removeObject:receipt];
    [self.allDownloadReceipts removeObject:receipt];
    [self saveAllDownloadReceipts:self.allDownloadReceipts];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:receipt.filePath error:nil];
}


#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    WKDownloadReceipt *receipt = [self receiptForURL:dataTask.taskDescription];

    if (receipt) {
        receipt.totalBytesExpectedToWrite = receipt.totalBytesWritten + dataTask.countOfBytesExpectedToReceive;
        receipt.state = WKDownloadStateDownloading;
        [self saveAllDownloadReceipts:self.allDownloadReceipts];
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    dispatch_async(self.synchronizationQueue, ^{
        
        __block NSError *error = nil;
        WKDownloadReceipt *receipt = [self receiptForURL:dataTask.taskDescription];
        NSInputStream *inputStream =  [[NSInputStream alloc] initWithData:data];
        NSOutputStream *outputStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:receipt.filePath] append:YES];
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [inputStream open];
        [outputStream open];
        
        while ([inputStream hasBytesAvailable] && [outputStream hasSpaceAvailable]) {
    
            uint8_t buffer[1024];
            
            NSInteger bytesRead = [inputStream read:buffer maxLength:1024];
            if (inputStream.streamError || bytesRead < 0) {
                error = inputStream.streamError;
                break;
            }
            
            NSInteger bytesWritten = [outputStream write:buffer maxLength:(NSUInteger)bytesRead];
            if (outputStream.streamError || bytesWritten < 0) {
                error = outputStream.streamError;
                break;
            }
            
            if (bytesRead == 0 && bytesWritten == 0) {
                break;
            }
        }
        [outputStream close];
        [inputStream close];
        
        receipt.progress.totalUnitCount = receipt.totalBytesExpectedToWrite;
        receipt.progress.completedUnitCount = receipt.totalBytesWritten;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.progressBlock) {
                receipt.progressBlock(receipt.progress,receipt);
            }
        });
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    WKDownloadReceipt *receipt = [self receiptForURL:task.taskDescription];
    if (error) {
        receipt.state = WKDownloadStateFailed;
        receipt.error = error;
        receipt.failureBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,error);
    }
    else {
        [receipt.stream close];
        receipt.stream = nil;
        receipt.state = WKDownloadStateCompleted;
        receipt.successBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,task.originalRequest.URL);
    }
    [self saveAllDownloadReceipts:self.allDownloadReceipts];

    //添加等待的任务
    dispatch_async(self.synchronizationQueue, ^{
        self.activeRequestCount--;
        NSInteger i = 0;
        while ([self isActivityRequestCountBelowMaxCount] && i <= self.queuedTasks.count-1) {
            if (!self.queuedTasks.count) {
                break;
            }
            WKDownloadReceipt *nextReceipt = self.queuedTasks[i];
            if (nextReceipt.state == WKDownloadStateCompleted ||
                nextReceipt.state == WKDownloadStateDownloading ||
                nextReceipt.state == WKDownloadStateFailed) {
                i++;
                continue;
            }
            else {
                [self resumeWithReceipt:nextReceipt];
            }
        }
    });
    
}

@end
