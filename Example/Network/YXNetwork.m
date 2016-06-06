//
//  YXNetwork.m
//  YXHTTPSession
//
//  Created by zdy on 16/5/26.
//  Copyright © 2016年 zdy. All rights reserved.
//

#import "YXNetwork.h"
#import <YXHTTPSession/YXHTTPSession.h>
#import <YXHTTPSession/YXError.h>
#import <YXHTTPSession/YXProtocol.h>
#import <YXHTTPSession/YXJsonParse.h>

static NSString *YXResponseCode         = @"retCode";
static NSString *YXResponseResult       = @"responseResult";
static NSString *YXResponseMessage      = @"retMsg";
static NSInteger YXResponseSucessCode   = 0000;


YXErrorMessage errorMsg[] = {
    {0000 ,"测试"},
    {1000, "成功"},
};

@implementation YXNetwork
+ (void)setupNetwork
{
    [YXSession registerHost:@""];
    
    [YXSession setCommonRestHeaders:nil];
    
    [YXError setupErrorMessages:errorMsg];
    
    [YXSession addURLPath:@"/user" parseClassName:@"UserModel" parseType:YXProtocolURLParseObject];
    
    __weak YXHTTPSession *wself = (YXHTTPSession *)YXSession;
    
    [YXSession setTaskDidCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error, YXCompletionBlock block){
        
        void (^ResponseBlockInMainQueue)(NSData *data, NSError *error) = ^(NSData *data, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (block) {
                    block(data,error);
                }
            });
        };
        
        if (!error) {
            if (data) {
                NSError *jsonError = nil;
                id jsonData = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&jsonError];
                
                if (jsonError) {
                    // 转成json对象失败
                    NSError *error = [YXError errorWithDomain:YXParseErrorDomain code:YXProtocolJsonSerializationError error:jsonError];
                    ResponseBlockInMainQueue(nil,error);
                }
                else {
                    NSInteger code = [jsonData[YXResponseCode] integerValue];
                    
                    if (code  == YXResponseSucessCode) {
                        // 返回业务成功，将json对象转成modal对象
                        id result = jsonData[YXResponseResult];
                        id data = [YXJsonParse parseWithData:result url:response.URL protocol:wself.protocol];
                        
                        ResponseBlockInMainQueue(data,nil);
                    }
                    else {
                        // 返回业务错误
                        NSString *codeMessge = jsonData[YXResponseMessage];
                        NSError *error = [YXError errorWithDomain:YXProtocolErrorDomain code:code message:codeMessge];
                        
                        ResponseBlockInMainQueue(nil,error);
                    }
                }
            }
            else {
                // HTTP 返回成功，Download 下载完成一般没有返回数据
                ResponseBlockInMainQueue(nil,nil);
            }
        }
        else {
            // HTTP 网络错误， task cancel 会回调 code = YXURLErrorCancelled,
            NSError *error = [YXError errorWithDomain:YXNetworkErrorDomain code:error.code error:error];
            ResponseBlockInMainQueue(nil,error);
        }

    }];
}
@end
