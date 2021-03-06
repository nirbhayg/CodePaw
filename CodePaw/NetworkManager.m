//
//  NetworkManager.m
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "NetworkManager.h"
#import "NetworkConstants.h"

static NetworkManager * _sharedManager = nil;

@interface NetworkManager ()

@property (nonatomic, strong) NSURLSession * sesssion;

@end

@implementation NetworkManager

#pragma mark Initialization

+ (NetworkManager *)sharedManager {
    if (!_sharedManager) {
        _sharedManager = [[NetworkManager alloc] initCustom];
    }
    return _sharedManager;
}

- (id)init {
    NSLog(@"* NetworkManager - Cannot create object this way for singleton");
    return nil;
}

- (id)initCustom {
    self = [super init];
    
    //Initialize session
    self.sesssion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                  delegate:self
                                             delegateQueue:nil];
    
    return self;
}

#pragma mark Helpers

- (NSString *)URLStringForRequestString:(NSString *)requestString {
    return [BASE_URL stringByAppendingString:requestString];
}

- (NSURLSessionDownloadTask *)taskForURLRequestString:(NSString *)requestString {
    NSString * URLString = [self URLStringForRequestString:requestString];
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:URL];
    
//    NSURLSessionTask *task = [_sesssion dataTaskWithRequest:request];
    NSURLSessionDownloadTask * task = [_sesssion downloadTaskWithRequest:request];
    return task;
}

#pragma mark Public

- (void)startRequestWithString:(NSString *)requestString {
    NSURLSessionTask * task = [self taskForURLRequestString:requestString];
    task.taskDescription = requestString;
    
    if (!task) {
        NSLog(@"* NetworkManager - Could not form task for request %@", requestString);
        return;
    }
    
    [task resume];
}

#pragma mark Task Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    NSLog(@"task completed - %@", task.originalRequest.URL.absoluteString);
}

#pragma mark Data Delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    if (!data) {
        NSLog(@"* NetworkManager - error getting data for request %@", dataTask.originalRequest.URL.absoluteString);
        return;
    }
    
    //Callback to delegate
    if (_delegate && [_delegate respondsToSelector:@selector(receivedData:forRequestURLString:)]) {
        [_delegate receivedData:data forRequestURLString:dataTask.taskDescription];
    }
}

#pragma mark DownloadTask Delegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSData* data = [NSData dataWithContentsOfURL:location];
    
    if (!data) {
        NSLog(@"* NetworkManager - error getting data for request %@", downloadTask.originalRequest.URL.absoluteString);
        return;
    }
    
    //Callback to delegate
    if (_delegate && [_delegate respondsToSelector:@selector(receivedData:forRequestURLString:)]) {
        [_delegate receivedData:data forRequestURLString:downloadTask.taskDescription];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {}

@end
