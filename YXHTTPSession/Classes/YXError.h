//
//  YXError.h
//  YXNetwork
//
//  Created by zdy on 16/5/13.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YXErrorCode) {
    
    YXProtocolJsonSerializationError    = -4000,    // NSJSONSerialization json解析错误
};

typedef struct {
    int code;
    char * __nonnull message;
}YXErrorMessage;

@interface YXError : NSObject
+ (void)setupErrorMessages:(YXErrorMessage *)errorMsgs;
+ (NSString *)errorMessageWithCode:(NSInteger)code;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code error:(NSError *)error;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)defaultMessage;
@end


extern NSString *YXNetworkErrorDomain;
extern NSString *YXParseErrorDomain;
extern NSString *YXProtocolErrorDomain;