//
//  YXTaskHandler.h
//  YXNetwork
//
//  Created by zdy on 16/5/16.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YXCompletionBlock)(id data,NSError *error);
typedef void (^YXProgressBlock)(NSURLSessionTask *task, NSProgress *progress);
typedef void (^YXDownloadBlock)(NSURLSessionDownloadTask *downloadTask,NSURL *fileURL);

@interface YXTaskHandler : NSObject
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, copy) YXCompletionBlock responseBlock;
@property (nonatomic, copy) YXProgressBlock progressBlock;
@property (nonatomic, copy) YXDownloadBlock downloadBlock;
@property (nonatomic, strong) NSURL *downloadFile;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSMutableData *appendData;

+ (YXTaskHandler *)handlerWithTask:(NSURLSessionTask *)task completionBlock:(YXCompletionBlock)block;

+ (YXTaskHandler *)handlerWithTask:(NSURLSessionTask *)task
                     progressBlock:(YXProgressBlock)progressBlock
                   completionBlock:(YXCompletionBlock)block;

+ (YXTaskHandler *)handlerWithTask:(NSURLSessionTask *)task
                     progressBlock:(YXProgressBlock)progressBlock
                     downloadBlock:(YXDownloadBlock)downloadBlock
                   completionBlock:(YXCompletionBlock)block;
@end
