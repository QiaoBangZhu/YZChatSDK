//
//  YChatRequestBuilder.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZChatURLRequest.h"

NS_ASSUME_NONNULL_BEGIN


static NSString *YZCHAT_REQUEST_BASE_URLS_PRODUCTION = @"https://dev-imapi.yzmetax.com/";

@interface YZChatRequestBuilder : NSObject
@property(nonatomic, copy, readonly) NSString *requestUrl;
@property(nonatomic, copy, readonly) NSDictionary *params;

+ (YZChatURLRequest *)requestWithURL:(NSString *)requestUrl andParams:(NSDictionary *)params;

+ (YZChatURLRequest *)requestBuilder:(NSString*)requestFullUrl andParams:(NSDictionary*)params;

+ (YZChatURLRequest *)requestWithCustumBaseURL:(NSString *)baseUrl
                                          URL:(NSString *)requestUrl andParams:(NSDictionary *)params;


@end

NS_ASSUME_NONNULL_END
