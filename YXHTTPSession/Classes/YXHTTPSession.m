//
//  YXHTTPSession.m
//  YXNetwork
//
//  Created by zdy on 15/11/13.
//  Copyright © 2015年 xinyunlian. All rights reserved.
//

#import "YXHTTPSession.h"
#import "YXJsonParse.h"
#import "YXLogger.h"
#import "YXError.h"

static NSInteger YXRequestTimeOut       = 30;

static NSString *YXBoundary             = @"----------cH2gL6ei4Ef1KM7cH2KM7ae0ei4gL6";


@interface YXHTTPSession ()<NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *taskHandlerDict;
@property (nonatomic, strong) NSLock *taskHandlerLock;
@property (nonatomic, strong, readwrite) YXProtocol *protocol;
@property (nonatomic, copy) TaskDidCompletionBlock taskDidCompletion;
@end

@implementation YXHTTPSession

+ (YXHTTPSession *)share
{
    static YXHTTPSession *share= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (id)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies = YES;
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        
        _taskHandlerDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        _taskHandlerLock = [[NSLock alloc] init];
        
        _protocol = [[YXProtocol alloc] init];
    }
    return self;
}

- (void)registerHost:(NSString *)host
{
    self.protocol.host = host;
}

- (void)addURLPath:(NSString *)urlPath parseClassName:(NSString *)className parseType:(YXProtocolURLParseType)parseType
{
    [self.protocol addURLPath:urlPath parseClassName:className parseType:parseType];
}

- (void)setCommonRestHeaders:(NSDictionary *)commonRestHeaders
{
    self.protocol.commonRestHeaders = commonRestHeaders;
}

- (void)setTaskDidCompletionBlock:(TaskDidCompletionBlock)taskDidCompletionBlock
{
    self.taskDidCompletion = taskDidCompletionBlock;
}

- (YXProtocol *)protocol
{
    return _protocol;
}

#pragma mark Request
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)urlPath
                                  bodyType:(YXRequestBodyType)bodyType
                                parameters:(NSDictionary *)parameters
{
    NSParameterAssert(method);
    NSParameterAssert(urlPath);
    NSParameterAssert(self.protocol.host);
    
    NSString *url = [self.protocol.host stringByAppendingString:urlPath];
    
    return [self requestWithMethod:method urlString:url bodyType:bodyType parameters:parameters];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 urlString:(NSString *)urlString
                                  bodyType:(YXRequestBodyType)bodyType
                                parameters:(NSDictionary *)parameters
{
    NSParameterAssert(method);
    NSParameterAssert(urlString);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:YXRequestTimeOut];
    

    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.protocol.commonRestHeaders];
    NSData *body = nil;
    
    if (!parameters || ![parameters count]) {
        // 没有参数
        
        mutableRequest.HTTPMethod = method;
        mutableRequest.allHTTPHeaderFields = headers;
        
        return mutableRequest;
    }
    
    // x-www-form-urlencode , get url query 提交格式
    NSString * (^GenerateParamsBlock)(void) = ^(){
        NSMutableArray *mutablePairs = [NSMutableArray arrayWithCapacity:[parameters count]];
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop){
            NSString *string = [NSString stringWithFormat:@"%@=%@",[YXHTTPSession URLEncode:key],[YXHTTPSession URLEncode:[obj description]]];
            [mutablePairs addObject:string];
        }];
        
        NSString *queryString = [[mutablePairs componentsJoinedByString:@"&"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return queryString;
    };
    
    // form-data 提交格式
    NSData * (^GenerateFormDataBlock)(void) = ^(){
    
        NSMutableData *data = [NSMutableData data];
        
        for (NSString *key in parameters.allKeys) {
            id value = parameters[key];
            if ([value isKindOfClass:[NSString class]]) {
                NSString *param = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",YXBoundary,key,value,nil];
                [data appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if ([value isKindOfClass:[NSDictionary class]]) {
                NSString *fileName = value[@"filename"];
                NSData *fileData = value[@"filedata"];
                
                NSString *param = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n",YXBoundary,key,fileName,nil];
                [data appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
                [data appendData:fileData];
                [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        return data;
    };
    
    if ([method isEqualToString:@"POST"]) {
        
        if (bodyType == YXRequestBodyTypeFormRawJson) {
            headers[@"Content-Type"] = @"application/json";
            body = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        }
        else if (bodyType == YXRequestBodyTypeFormData){
            headers[@"Content-Type"] = [@"multipart/form-data; boundary="stringByAppendingString:YXBoundary];
            body = GenerateFormDataBlock();
        }
        else {
            NSString *bodyString = GenerateParamsBlock();
            headers[@"Content-Type"] = @"application/x-www-form-urlencoded";
            body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        }
        
    }
    else {
        NSString *queryString = GenerateParamsBlock();
        NSString *string = [urlString stringByAppendingString:queryString];
        mutableRequest.URL = [NSURL URLWithString:string];;
    }
    
    
    mutableRequest.HTTPMethod = method;
    mutableRequest.allHTTPHeaderFields = headers;
    mutableRequest.HTTPBody = body;
    
    return mutableRequest;
}


#pragma mark Task
- (NSURLSessionTask *)dataTaskWithRequest:(NSURLRequest *)request
                            responseBlock:(YXCompletionBlock)responseBlock
{
    NSURLSessionDataTask *task = [[YXHTTPSession share].session dataTaskWithRequest:request];
    
    YXTaskHandler *handler = [YXTaskHandler handlerWithTask:task completionBlock:responseBlock];
    [[YXHTTPSession share] addTaskHandler:handler withTask:task];
    
    [task resume];
    
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                    progressBlock:(YXProgressBlock)progressBlock
                                    responseBlock:(YXCompletionBlock)responseBlock
{
    NSURLSessionUploadTask *task = [[YXHTTPSession share].session uploadTaskWithRequest:request fromFile:fileURL];

    YXTaskHandler *handler = [YXTaskHandler handlerWithTask:task
                                              progressBlock:progressBlock
                                            completionBlock:responseBlock];
    
    [[YXHTTPSession share] addTaskHandler:handler withTask:task];
    
    [task resume];
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                        progressBlock:(YXProgressBlock)progressBlock
                                        downloadBlock:(YXDownloadBlock)downloadBlock
                                        responseBlock:(YXCompletionBlock)responseBlock
{
    NSURLSessionDownloadTask *task = [[YXHTTPSession share].session downloadTaskWithRequest:request];
    
    YXTaskHandler *handler = [YXTaskHandler handlerWithTask:task
                                              progressBlock:progressBlock
                                              downloadBlock:downloadBlock
                                            completionBlock:responseBlock];
    
    [[YXHTTPSession share] addTaskHandler:handler withTask:task];
    
    [task resume];
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)data
                                           progressBlock:(YXProgressBlock)progressBlock
                                           downloadBlock:(YXDownloadBlock)downloadBlock
                                           responseBlock:(YXCompletionBlock)responseBlock
{
    NSURLSessionDownloadTask *task = [[YXHTTPSession share].session downloadTaskWithResumeData:data];
    
    YXTaskHandler *handler = [YXTaskHandler handlerWithTask:task
                                              progressBlock:progressBlock
                                              downloadBlock:downloadBlock
                                            completionBlock:responseBlock];
    
    [[YXHTTPSession share] addTaskHandler:handler withTask:task];
    
    [task resume];
    return task;
}


- (void)cancelTaskWithTaskId:(NSUInteger)taskId
{
    YXTaskHandler *handler = [[YXHTTPSession share] searchTaskHandlerWithTaskId:@(taskId)];
    [handler.task cancel];
    
    // 如果取消了，response置成nil，就不会回调了
    handler.responseBlock = nil;
}

#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];;
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    // 
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler;
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    YXTaskHandler *handler = [self searchTaskHandlerWithTask:task];
    if (handler.progressBlock) {
        if (!handler.progress) {
            handler.progress = [[NSProgress alloc] init];
        }
        
        handler.progress.totalUnitCount = totalBytesExpectedToSend;
        handler.progress.completedUnitCount = totalBytesSent;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler.progressBlock(task,handler.progress);
        });
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSAssert(self.taskDidCompletion, @"必须现在设置回调处理业务逻辑");
    
    if (!self.taskDidCompletion) {
        return;
    }
    
    YXTaskHandler *handler = [self searchTaskHandlerWithTask:task];
    if (handler.responseBlock && self.taskDidCompletion) {
        self.taskDidCompletion(handler.appendData,task.response,error,handler.responseBlock);
    }
    
    [self removeTask:task];
}

#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    YXTaskHandler *handler = [self searchTaskHandlerWithTask:dataTask];
    [handler.appendData appendData:data];
}


#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    YXTaskHandler *handler = [self searchTaskHandlerWithTask:downloadTask];
    if (handler.downloadBlock) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler.downloadBlock(downloadTask,location);
        });
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    YXTaskHandler *handler = [self searchTaskHandlerWithTask:downloadTask];
    if (handler.progressBlock) {
        if (!handler.progress) {
            handler.progress = [[NSProgress alloc] init];
        }
        
        handler.progress.totalUnitCount = totalBytesExpectedToWrite;
        handler.progress.completedUnitCount = totalBytesWritten;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler.progressBlock(downloadTask,handler.progress);
        });
    }
}


#pragma mark YXTaskHandler
- (void)addTaskHandler:(YXTaskHandler *)handle withTask:(NSURLSessionTask *)task
{
    [self.taskHandlerLock lock];
    self.taskHandlerDict[@(task.taskIdentifier)] = handle;
    [self.taskHandlerLock unlock];
}

- (void)removeTask:(NSURLSessionTask *)task
{
    [self.taskHandlerLock lock];
    [self.taskHandlerDict removeObjectForKey:@(task.taskIdentifier)];
    [self.taskHandlerLock unlock];
}

- (YXTaskHandler *)searchTaskHandlerWithTaskId:(NSNumber *)taskId
{
    YXTaskHandler *handle = nil;
    
    [self.taskHandlerLock lock];
    handle = self.taskHandlerDict[taskId];
    [self.taskHandlerLock unlock];
    
    return handle;
}

- (YXTaskHandler *)searchTaskHandlerWithTask:(NSURLSessionTask *)task
{
    return [self searchTaskHandlerWithTaskId:@(task.taskIdentifier)];
}

#pragma mark URLEncode
+ (NSString *)URLEncode:(NSString *)param
{
    return [param stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@":/?#[]@!$&'()*+,;="]];
}

@end