//
//  YXProtocol.m
//  YXNetwork
//
//  Created by zdy on 16/5/19.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import "YXProtocol.h"

@implementation YXProtocolURLParse

@end


@implementation YXProtocol
- (id)init
{
    if (self = [super init]) {
        _paths = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    
    return self;
}

- (void)addURLPath:(NSString *)urlPath parseClassName:(NSString *)className parseType:(YXProtocolURLParseType)parseType
{
    YXProtocolURLParse *path = [[YXProtocolURLParse alloc] init];
    path.urlPath = urlPath;
    path.parseClassName = className;
    path.parseType = parseType;
    
    self.paths[urlPath] = path;
}
@end
