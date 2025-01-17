//
//  YChatRequestMan.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YChatRequestMan.h"
#import "YChatURLRequest.h"
#import "YChatHTTPClient.h"
#import "YChatRequestBuilder.h"
#import "YChatResponseCode.h"
#import "YChat_Precompile.h"
#import "YChatSettingStore.h"

@implementation YChatRequestMan


+ (NSURLSessionDataTask*)postRequest:(YChatURLRequest *)request completion:(YChatURLRequestCompletionBlock)block {
    YChatHTTPClient* mHTTPsClient = [YChatHTTPClient sharedClient];
    
    if ([[YChatSettingStore sharedInstance]getAuthToken]) {
        [mHTTPsClient.requestSerializer setValue:[NSString stringWithFormat:@"%@",[YChatSettingStore sharedInstance].getAuthToken] forHTTPHeaderField:@"token"];
        
    }
    if ([[YChatSettingStore sharedInstance]getAppId]) {
        [mHTTPsClient.requestSerializer setValue:[NSString stringWithFormat:@"%@",[[YChatSettingStore sharedInstance]getAppId]] forHTTPHeaderField:@"appId"];
    }else {
        [mHTTPsClient.requestSerializer setValue:[NSString stringWithFormat:@"%@",ychatAppId] forHTTPHeaderField:@"appId"];
    }
    return [self postRequest:request mHTTPsClient:mHTTPsClient completion:block];
}


+ (NSURLSessionDataTask*)postRequest:(YChatURLRequest *)request
                              mHTTPsClient:(YChatHTTPClient *)mHTTPsClient
                                completion:(YChatURLRequestCompletionBlock)block {
    NSURL* url = request.URL;
    
    NSURLSessionDataTask* task = [mHTTPsClient POST:url.absoluteString parameters:request.paramDict headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (block) {
            if (responseObject == nil) {
                NSError* err = [YChatRequestMan resultCodeToError:YChatResponseCodeParseError task:task];
                    block(nil, err);
            }else {
                NSDictionary* resultDic = (NSDictionary*)responseObject;
                NSInteger retCode = [YChatRequestMan checkExpectCode:YChatResponseCodeSucceed withResult:resultDic];
                if (retCode == 0) {
                    block(resultDic, nil);
                } else{
                    NSInteger code = [YChatRequestMan checkExpectCode:YChatResponseCodeSucceed withResult:resultDic];
                    NSError* err = [YChatRequestMan errorCode:code withDesc:[responseObject stringForKey:@"msg"] task:task];
                    block(nil, err);
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSError *err = [NSError errorWithDomain:request.URL.absoluteString code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"retry_later", nil), NSLocalizedDescriptionKey, [NSNumber numberWithInteger:error.code], @"errorCode", nil]];
        if (block) {
            NSLog(@"\n\n>>>>>>>>>>>>RequestUrl:\n%@\n\n>>>>>>>>>>requestHeader:\n%@\n\n>>>>>>>>>>params:\n%@  \n\n>>>>>>>>Failed:\n%@\n\n", request.URL, mHTTPsClient.requestSerializer.HTTPRequestHeaders,request.paramDict,error);
            block(nil, err);
        };
    }];
    return task;
}

+ (NSString *)paramsOrderWith:(NSMutableDictionary *)params1 dic2:(NSDictionary *)params2 {
    NSMutableDictionary *bindDic = [[NSMutableDictionary alloc] initWithDictionary:params1];
    NSArray *keyP2 = params2.allKeys;
    NSArray *valueP2 = params2.allValues;
    for (int i = 0; i < params2.count; i++) {
        [bindDic setObject:valueP2[i] forKey:keyP2[i]];
    }
    
    NSMutableString *paramsMd5 = [[NSMutableString alloc] init];
    NSArray *allkeys = [bindDic allKeys];
    
    allkeys = [allkeys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch];
    }];
    
    for (NSString *key in allkeys) {
        id value = [bindDic objectForKey:key];
        if ([value isKindOfClass:[NSString class]] && [value length] > 0) {
            [paramsMd5 appendString:[NSString stringWithFormat:@"&%@=%@", key, value]];
        }else if([value isKindOfClass:[NSNumber class]]){
            [paramsMd5 appendString:[NSString stringWithFormat:@"&%@=%@", key, value]];
        }else if ([value isKindOfClass:[NSDate class]]) {
            NSDate *time = (NSDate *)value;
            NSNumber *ndate = [NSNumber numberWithDouble: time.timeIntervalSince1970];
            [params1 setObject:ndate forKey:key];
            [paramsMd5 appendString:[NSString stringWithFormat:@"&%@=%@", key, ndate]];
        }
    }
    
    [paramsMd5 appendString:@"@iossecret"];
    return [paramsMd5 substringFromIndex:1];
}

+ (NSError *)resultCodeToError:(NSInteger)code task:(NSURLSessionDataTask*)task
{
    NSString *errorString = [NSString stringWithFormat:@"出现未知错误。错误代号:%d", (int)code];
    NSError *err = [NSError errorWithDomain:task.currentRequest.URL.absoluteString code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, [NSNumber numberWithInteger:code], @"errorCode", nil]];
    NSLog(@"error reason %@ \n", [err localizedDescription]);
    return err;
}

+ (NSInteger)checkExpectCode:(NSInteger)expectCode withResult:(id)dictResult
{
    if (dictResult == nil || ![dictResult isKindOfClass:[NSDictionary class]]) {
        return ReqErrorCodeParseError;
    }
    else {
        NSObject *error = [dictResult objectForKey: @"error"];
        if ([error isKindOfClass: [NSNumber class]]) {
            return [(NSNumber *) error intValue];
        }
        else if ([error isKindOfClass:[NSString class]]) {
            return [[NSNumber numberWithDouble:[(NSString *) error doubleValue]] intValue] ?: ReqErrorCodeParseError;
        }
    }
    return 0;
}


+ (NSError*)errorCode:(NSInteger)code withDesc:(NSString*)desc task:(NSURLSessionDataTask*)task
{
    NSError *err = [NSError errorWithDomain:task.currentRequest.URL.absoluteString code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:desc, NSLocalizedDescriptionKey, [NSNumber numberWithInteger:code], @"errorCode", nil]];
    NSLog(@"error reason %@ \n", [err localizedDescription]);
    return err;
}

@end
