//
//  YChatHTTPClient.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZChatHTTPClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (NSDictionary *)setHttpHeader;


@end

NS_ASSUME_NONNULL_END
