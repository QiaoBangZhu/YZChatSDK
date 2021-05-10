//
//  YChatRequestBuilder.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YChatURLRequest.h"

NS_ASSUME_NONNULL_BEGIN


static NSString *YCHAT_REQUEST_BASE_URLS_PRODUCTION = @"https://imapi.yzmetax.com/";

@interface YChatRequestBuilder : NSObject
@property(nonatomic, copy, readonly) NSString *requestUrl;
@property(nonatomic, copy, readonly) NSDictionary *params;

+ (YChatURLRequest *)requestWithURL:(NSString *)requestUrl andParams:(NSDictionary *)params;

+ (YChatURLRequest *)requestBuilder:(NSString*)requestFullUrl andParams:(NSDictionary*)params;

+ (YChatURLRequest *)requestWithCustumBaseURL:(NSString *)baseUrl
                                          URL:(NSString *)requestUrl andParams:(NSDictionary *)params;


@end

NS_ASSUME_NONNULL_END
