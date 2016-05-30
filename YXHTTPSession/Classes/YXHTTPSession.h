//
//  YXHTTPSession.h
//  YXNetwork
//
//  Created by zdy on 15/11/13.
//  Copyright © 2015年 xinyunlian. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YXTaskHandler.h"
#import "YXProtocol.h"

typedef void (^TaskDidCompletionBlock)(NSData *data, NSURLResponse *response, NSError *error, YXCompletionBlock block);

#define YXSession   [YXHTTPSession share]


@interface YXHTTPSession : NSObject

+ (YXHTTPSession *)share;

/**
 *  protocol 对象保存了域名，通用header设置信息，请求地址类型以及对于的解析类
 */
@property (nonatomic, readonly) YXProtocol *protocol;

/**
 *  注册URL baseURL，例如https://api.bmob.cn/
 *
 *  @param host
 */
- (void)registerHost:(NSString *)host;

/**
 *  注册URL 解析对象类名，内部使用MJExtension做json解析
 *
 *  @param urlPath   path 部分，path 要具有唯一性
 *  @param className
 *  @param parseType
 */
- (void)addURLPath:(NSString *)urlPath
    parseClassName:(NSString *)className
         parseType:(YXProtocolURLParseType)parseType;

/**
 *
 *  设置通用的HTTP Header 头部信息
 */
- (void)setCommonRestHeaders:(NSDictionary *)commonRestHeaders;


/**
 *  URLSession:task:didCompleteWithError 调用会调用次bock处理业务逻辑
 *
 *  @param taskDidCompletionBlock
 */
- (void)setTaskDidCompletionBlock:(TaskDidCompletionBlock)taskDidCompletionBlock;

/**
 *  创建URLRequest 请求
 *
 *  @param method     GET、POST、PUT、DELETE
 *  @param urlPath    url path 部分
 *  @param bodyType   POST 方式，body数据格式
 *  @param parameters 参数列表
 *
 *  @return
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)urlPath
                                  bodyType:(YXRequestBodyType)bodyType
                                parameters:(NSDictionary *)parameters;

/**
 *  创建URLRequestion 请求
 *
 *  @param method     GET、POST、PUT、DELETE
 *  @param urlString  url 完整地址
 *  @param bodyType   POST 方式，body数据格式
 *  @param parameters 参数列表
 *
 *  @return <#return value description#>
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 urlString:(NSString *)urlString
                                  bodyType:(YXRequestBodyType)bodyType
                                parameters:(NSDictionary *)parameters;

/**
 *  <#Description#>
 *
 *  @param request       <#request description#>
 *  @param responseBlock <#responseBlock description#>
 *
 *  @return <#return value description#>
 */
- (NSURLSessionTask *)dataTaskWithRequest:(NSURLRequest *)request
                            responseBlock:(YXCompletionBlock)responseBlock;

/**
 *  <#Description#>
 *
 *  @param request       <#request description#>
 *  @param fileURL       本地文件url地址
 *  @param progressBlock <#progressBlock description#>
 *  @param responseBlock <#responseBlock description#>
 *
 *  @return <#return value description#>
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                    progressBlock:(YXProgressBlock)progressBlock
                                    responseBlock:(YXCompletionBlock)responseBlock;

/**
 *  <#Description#>
 *
 *  @param request       <#request description#>
 *  @param progressBlock <#progressBlock description#>
 *  @param downloadBlock 返回的文件地址URL 是临时地址，在block执行完成后会被系统删除
 *  @param responseBlock <#responseBlock description#>
 *
 *  @return <#return value description#>
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                        progressBlock:(YXProgressBlock)progressBlock
                                        downloadBlock:(YXDownloadBlock)downloadBlock
                                        responseBlock:(YXCompletionBlock)responseBlock;

/**
 *  <#Description#>
 *
 *  @param data          <#data description#>
 *  @param progressBlock <#progressBlock description#>
 *  @param downloadBlock 返回的文件地址URL 是临时地址，在block执行完成后会被系统删除
 *  @param responseBlock <#responseBlock description#>
 *
 *  @return <#return value description#>
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)data
                                           progressBlock:(YXProgressBlock)progressBlock
                                           downloadBlock:(YXDownloadBlock)downloadBlock
                                           responseBlock:(YXCompletionBlock)responseBlock;

/**
 *  如果取消请求，responseBlock被设置为nil，不会回调controller
 *
 *  @param taskId <#taskId description#>
 */
- (void)cancelTaskWithTaskId:(NSUInteger)taskId;

@end
