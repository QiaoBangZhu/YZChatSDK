//
//  YChatRequestBuilder.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YChatRequestBuilder.h"
#import "YChatURLRequest.h"

@interface YChatRequestBuilder()
@property(nonatomic, copy, readwrite) NSString *requestUrl;
//回调函数
@property(nonatomic, copy, readwrite) NSString *callbackPrefix;
@property(nonatomic, copy, readwrite) NSDictionary *params;
//语音和图片
@property(nonatomic, copy, readwrite) NSDictionary *additionParams;
//剩余重试次数
@property(nonatomic, assign, readwrite) NSInteger retryTimes;
//重试间隔
@property(nonatomic, assign, readwrite) NSInteger retryInterval;
@property(nonatomic, assign, readwrite) NSInteger reqPriority;
@end

@implementation YChatRequestBuilder

+ (YChatURLRequest*)requestWithURL:(NSString *)requestUrl andParams:(NSDictionary *)params{
    NSString *baseUrl = [YChatRequestBuilder baseUrlConvertWith:requestUrl];
    NSString *escapedPath = [baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:escapedPath];
    
    url = [url URLByAppendingPathComponent:requestUrl];
    YChatURLRequest* request = [[YChatURLRequest alloc] initWithURL:url];
    NSMutableDictionary* tmpDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    request.paramDict = [[NSMutableDictionary alloc] initWithDictionary:tmpDic];
    return request;
}

+ (NSString *)baseUrlConvertWith:(NSString *)url {
    NSString *baseUrl = YCHAT_REQUEST_BASE_URLS_PRODUCTION;
    return baseUrl;
}

+ (YChatURLRequest *)requestBuilder:(NSString*)requestFullUrl andParams:(NSDictionary*)params {
    
    requestFullUrl = [requestFullUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:requestFullUrl];
    YChatURLRequest* request = [[YChatURLRequest alloc] initWithURL:url];
    request.paramDict = [NSMutableDictionary dictionaryWithDictionary:params];
    return request;
}

+ (YChatURLRequest *)requestWithCustumBaseURL:(NSString *)baseUrl URL:(NSString *)requestUrl andParams:(NSDictionary *)params {
    NSString *escapedPath = [baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:escapedPath];
    
    url = [url URLByAppendingPathComponent:requestUrl];
    YChatURLRequest* request = [[YChatURLRequest alloc] initWithURL:url];
    NSMutableDictionary* tmpDic = [[NSMutableDictionary alloc] initWithDictionary:params];
    request.paramDict = [[NSMutableDictionary alloc] initWithDictionary:tmpDic];
    return request;
}


@end
