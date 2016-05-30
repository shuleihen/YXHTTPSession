//
//  WXJsonParse.h
//  YXNetwork
//
//  Created by zdy on 15/10/9.
//  Copyright © 2015年 xinyunlian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YXProtocol;

@interface YXJsonParse : NSObject

+ (id)parseWithData:(id)data url:(NSURL *)url protocol:(YXProtocol *)protocol;
@end
