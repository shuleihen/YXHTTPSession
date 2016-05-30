//
//  YXLogger.h
//  YXNetwork
//
//  Created by zdy on 16/5/9.
//  Copyright © 2016年 lianlian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXLogger : NSObject
+ (void)logDebugInfoWithReuest:(NSURLRequest *)request apiName:(NSString *)apiName requestParams:(id)requestParams httpMethod:(NSString *)httpMethod;
+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response jsonData:(id)jsonData error:(NSError *)error;
@end
