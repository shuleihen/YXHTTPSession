//
//  WXJsonParse.m
//  YXNetwork
//
//  Created by zdy on 15/10/9.
//  Copyright © 2015年 xinyunlian. All rights reserved.
//

#import "YXJsonParse.h"
#import "MJExtension.h"
#import "YXProtocol.h"

@implementation YXJsonParse

+ (id)parseWithData:(id)data url:(NSURL *)url protocol:(YXProtocol *)protocol
{
    id result = nil;
    NSString *urlPath = url.path;
    
    YXProtocolURLParse *path = protocol.paths[urlPath];
    if (path.parseType == YXProtocolURLParseArray) {
        Class class = NSClassFromString(path.parseClassName);
        result = [class mj_objectArrayWithKeyValuesArray:data];
    }
    else if (path.parseType == YXProtocolURLParseObject){
        Class class = NSClassFromString(path.parseClassName);
        result = [class mj_objectWithKeyValues:data];
    }
    else {
        result = data;
    }
        
    return result;
}
@end
