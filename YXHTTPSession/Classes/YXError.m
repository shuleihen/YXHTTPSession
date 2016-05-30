//
//  YXError.m
//  YXNetwork
//
//  Created by zdy on 16/5/13.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import "YXError.h"

NSString *YXNetworkErrorDomain      = @"YXNetworkErrorDomain";
NSString *YXParseErrorDomain        = @"YXParseErrorDomain";
NSString *YXProtocolErrorDomain     = @"YXProtocolErrorDomain";


static YXErrorMessage *errorMsg = NULL;

@implementation YXError
+ (void)setupErrorMessages:(YXErrorMessage *)errorMsgs
{
    errorMsgs = errorMsgs;
}

+ (NSString *)errorMessageWithCode:(NSInteger)code
{
    NSAssert(errorMsg, @"需要先添加错误码");
    
    if (!errorMsg) {
        return nil;
    }
    
    YXErrorMessage *e = NULL, *p, *pend;
    
    p = errorMsg;
    pend = p + sizeof(errorMsg)/sizeof(YXErrorMessage);
    
    for (;p<pend;p++){
        if (p->code == code) {
            e = p;
            break;
        }
    }
    
    if (e == NULL) {
        return nil;
    }
    
    NSString *message = [NSString stringWithUTF8String:e->message];
    return message;
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code
{
    NSString *message = [YXError errorMessageWithCode:code];
    
    if (!message) {
        return nil;
    }
    
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
    return error;
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code error:(NSError *)error
{
    NSString *message = [YXError errorMessageWithCode:code];
    
    if (!message) {
        return [NSError errorWithDomain:domain code:code userInfo:error.userInfo];
    }
    
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)defaultMessage
{
    NSString *message = [YXError errorMessageWithCode:code];
    
    if (!message) {
        return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:defaultMessage}];
    }
    
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}
@end
