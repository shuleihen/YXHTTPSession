//
//  YXProtocol.h
//  YXNetwork
//
//  Created by zdy on 16/5/19.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YXRequestBodyType){
    YXRequestBodyTypeFormUrlEncode,
    YXRequestBodyTypeFormData,
    YXRequestBodyTypeFormRawJson
};

typedef NS_ENUM(NSInteger, YXProtocolURLParseType){
    YXProtocolURLParseArray     = 1,
    YXProtocolURLParseObject    = 2,
    YXProtocolURLParseNone      = 3
};

@interface YXProtocolURLParse : NSObject
@property (nonatomic, strong) NSString *urlPath;
@property (nonatomic, strong) NSString *parseClassName;
@property (nonatomic, assign) YXProtocolURLParseType parseType;
@end

@interface YXProtocol : NSObject
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSDictionary *commonRestHeaders;
@property (nonatomic, strong) NSMutableDictionary *paths;

- (void)addURLPath:(NSString *)urlPath parseClassName:(NSString *)className parseType:(YXProtocolURLParseType)parseType;
@end
