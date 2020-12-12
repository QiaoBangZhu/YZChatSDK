//
//  YChatUploadManager.h
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface YChatUploadManager : NSObject
AS_SINGLETON(YChatUploadManager);

+(void)post:(NSString *)url
       params:(NSDictionary * __nullable)params
       imageData:(NSData *)imageData
       imageName:(NSString *)imageName
       onComplete:(void(^)(NSDictionary* json, BOOL isSuccess)) onComplete;


@end

NS_ASSUME_NONNULL_END
