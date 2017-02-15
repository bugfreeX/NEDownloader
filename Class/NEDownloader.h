//
//  NEDownloader.h
//  NEDownloader
//
//  Created by Nelson on 2017/2/14.
//  Copyright © 2017年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^progressHandler)(long long completedUnitCount,long long totalUnitCount);
typedef void(^completeBlock)(NSString * filePath,NSString * url,BOOL completed,NSError * error);
@interface NEDownloader : NSObject
-(void)startWithURL:(NSString *)url progressHandler:(progressHandler)progress completeBlock:(completeBlock)completeBlock;
-(void)resume;
-(void)suspend;
@property (nonatomic , assign) NSURLSessionTaskState state;
@end
