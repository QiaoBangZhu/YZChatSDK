//
//  YChatRequestMan.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZChatRequestBuilder.h"
#import "YZChatURLRequest.h"
#import "YZChatNetworkEngine.h"



@class YZChatHTTPClient;

@interface YZChatRequestMan : NSObject

+ (NSURLSessionDataTask*)postRequest:(YZChatURLRequest *)request
                                completion:(YZChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask*)postRequest:(YZChatURLRequest *)request
                              mHTTPsClient:(YZChatHTTPClient *)mHTTPsClient
                          completion:(YZChatURLRequstCompletionBlock)block;

@end


