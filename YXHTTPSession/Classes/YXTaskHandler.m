//
//  YXTaskHandler.m
//  YXNetwork
//
//  Created by zdy on 16/5/16.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import "YXTaskHandler.h"

@implementation YXTaskHandler

+ (YXTaskHandler *)handlerWithTask:(NSURLSessionTask *)task completionBlock:(YXCompletionBlock)block
{
    return [YXTaskHandler handlerWithTask:task progressBlock:nil completionBlock:block];
}

+ (YXTaskHandler *)handlerWithTask:(NSURLSessionTask *)task
                     progressBlock:(YXProgressBlock)progressBlock
                   completionBlock:(YXCompletionBlock)block
{
    return [YXTaskHandler handlerWithTask:task progressBlock:progressBlock downloadBlock:nil completionBlock:block];
}

+ (YXTaskHandler *)handlerWithTask:(NSURLSessionTask *)task
                     progressBlock:(YXProgressBlock)progressBlock
                     downloadBlock:(YXDownloadBlock)downloadBlock
                   completionBlock:(YXCompletionBlock)block
{
    YXTaskHandler *handler = [[YXTaskHandler alloc] init];
    handler.task = task;
    handler.responseBlock = block;
    handler.progressBlock = progressBlock;
    handler.downloadBlock = downloadBlock;
    handler.appendData = [NSMutableData data];
    
    return handler;
}
@end
