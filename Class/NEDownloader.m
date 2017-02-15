//
//  NEDownloader.m
//  NEDownloader
//
//  Created by Nelson on 2017/2/14.
//  Copyright © 2017年 Nelson. All rights reserved.
//

#import "NEDownloader.h"

@interface NEDownloader()<NSURLSessionDelegate>{
    NSString * downloadPath;
    NSString * downloadURL;
    long long tmpFileSize;
    long long totalFileSize;
    progressHandler handler;
    completeBlock block;
}
@property(nonatomic , strong) NSURLSessionDataTask * downloadTask;
@property(nonatomic , strong) NSURLSession * downloadSession;
@property(nonatomic , strong) NSMutableURLRequest * request;
@property(nonatomic , strong) NSOutputStream * outputStream;
@end

@implementation NEDownloader
-(void)startWithURL:(NSString *)url progressHandler:(progressHandler)progress completeBlock:(completeBlock)completeBlock{
    downloadURL = url;
    downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
    
    if (progress) {
        handler = nil;
        handler = progress;
    }
    if (completeBlock) {
        block = nil;
        block = completeBlock;
    }
    
    [self.downloadTask resume];
}

-(NSURLSessionDataTask *)downloadTask{
    if (!_downloadTask) {
        _downloadTask = [self.downloadSession dataTaskWithRequest:self.request];
    }
    return _downloadTask;
}

-(NSURLSession *)downloadSession{
    if (!_downloadSession) {
        _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _downloadSession;
}

-(NSMutableURLRequest *)request{
    if (!_request) {
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0];
        /**
         set HTTPHeaderField
         */
        unsigned long long cacheFileSize = 0;
        cacheFileSize = [self fileSizeForPath:downloadPath];
        if (cacheFileSize > 0) {
            NSLog(@"cache file size:%lld",cacheFileSize);
            tmpFileSize = cacheFileSize;
            NSString * range = [NSString stringWithFormat:@"bytes=%lld-",cacheFileSize];
            [_request setValue:range forHTTPHeaderField:@"Range"];
        }
    }
    return _request;
}
-(NSOutputStream *)outputStream{
    if (!_outputStream) {
        _outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
    }
    return _outputStream;
}

-(void)resume{
    if (self.downloadTask.state == NSURLSessionTaskStateSuspended) {
        NSLog(@"task resume");
        [self.downloadTask resume];
    }
}

-(void)suspend{
    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        NSLog(@"task suspend");
        [self.downloadTask suspend];
        [self.outputStream close];
        self.outputStream = nil;
        self.downloadTask = nil;
        self.downloadSession = nil;
        self.request = nil;
    }
}

-(NSURLSessionTaskState)state{
    return self.downloadTask.state;
}


#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        NSString * rangeString = httpResponse.allHeaderFields[@"Content-Range"];
        totalFileSize = [[[rangeString componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    NSLog(@"total size:%lld",totalFileSize);
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    tmpFileSize += data.length;
    if (handler) {
        handler(tmpFileSize,totalFileSize);
    }
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%s-----%@",__func__,error.description);
    tmpFileSize = 0;
    if (block) {
        if (task.state == NSURLSessionTaskStateCompleted) {
            block(downloadPath,downloadURL,YES,error);
        }else{
            block(downloadPath,downloadURL,NO,error);
        }
    }
    [self.outputStream close];
    self.outputStream = nil;
    session = nil;
    task = nil;
}

- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}
@end
