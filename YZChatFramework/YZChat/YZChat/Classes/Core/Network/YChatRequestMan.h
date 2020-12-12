//
//  YChatRequestMan.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YChatRequestBuilder.h"
#import "YChatURLRequest.h"
#import "YChatNetworkEngine.h"



@class YChatHTTPClient;

@interface YChatRequestMan : NSObject

+ (NSURLSessionDataTask*)postRequest:(YChatURLRequest *)request
                                completion:(YChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask*)postRequest:(YChatURLRequest *)request
                              mHTTPsClient:(YChatHTTPClient *)mHTTPsClient
                          completion:(YChatURLRequstCompletionBlock)block;

@end


