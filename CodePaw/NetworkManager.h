//
//  NetworkManager.h
//  CodePaw
//
//  Created by Nirbhay Agarwal on 20/08/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkProtocol <NSObject>

- (void)receivedData:(NSData *)data forRequestURLString:(NSString *)requestString;

@end

@interface NetworkManager : NSObject
<
    NSURLSessionDelegate,
    NSURLSessionTaskDelegate,
    NSURLSessionDownloadDelegate
>

@property (nonatomic, strong) id <NetworkProtocol> delegate;

+ (NetworkManager *)sharedManager;
- (void)startRequestWithString:(NSString *)requestString;

@end
