//
//  CustomURLProtocol.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/3.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "CustomURLProtocol.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static NSString* const FilteredKey = @"FilteredKey";

static UIImage *placeHolderImage() {
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIGraphicsBeginImageContext(CGSizeMake(20, 20));
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, 20, 20));
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

    NSString* extension = request.URL.pathExtension;
    BOOL isImage = NO;
    if (extension.length > 0) {
        isImage = [@[@"png", @"jpeg", @"gif", @"jpg"] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [extension compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
        }] != NSNotFound;
    }
    else if (request.URL.query.length > 0) {
        NSArray<NSString *> *queryArray = [request.URL.query componentsSeparatedByString:@"&"];
        for (NSString *paramt in queryArray) {
            isImage = [@[@"png", @"jpeg", @"gif", @"jpg"] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [paramt.pathExtension compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
            }] != NSNotFound;
            if (isImage) {
                break;
            }
        }
    }

    
    return [NSURLProtocol propertyForKey:FilteredKey inRequest:request] == nil && isImage;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:FilteredKey inRequest:request];
    NSData* data = UIImagePNGRepresentation(placeHolderImage());
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
    
    
    NSCachedURLResponse *res = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    NSLog(@"%@", res);
}
- (void)stopLoading {
    
}

@end
