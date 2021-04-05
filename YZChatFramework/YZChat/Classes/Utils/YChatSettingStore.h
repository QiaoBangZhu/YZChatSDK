//
//  YChatSettingStore.h
//  YChat
//
//  Created by magic on 2020/9/24.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonConstant.h"

@class  YUserInfo;

NS_ASSUME_NONNULL_BEGIN

@interface YChatSettingStore : NSObject

AS_SINGLETON(YChatSettingStore);

/**
 * userInfo
 */
@property (nonatomic, strong, setter=saveUserInfo:, getter=getUserInfo) YUserInfo *userInfo;

- (void)logout;

- (NSString *)getAuthToken;
- (NSString *)getUserId;
- (NSString *)getUserSign;
- (NSString *)getNickName;
- (NSString *)getMobile;
- (NSString *)getAppId;
//当有第三方调用元讯时候根据此字段判断展示几个tab
- (NSInteger)getFunctionPerm;

- (BOOL)isLogin;



@end

NS_ASSUME_NONNULL_END
