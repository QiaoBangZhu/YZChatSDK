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
- (void)saveUserInfo:(YUserInfo *)userInfo;
- (YUserInfo *)getUserInfo;
- (void)logout;

- (NSString *)getAuthToken;
- (NSString *)getUserId;
- (NSString *)getUserSign;
- (NSString *)getNickName;
- (NSString *)getMobile;
- (NSString *)getAppId;
//当有第三方调用元讯时候根据此字段判断展示几个tab
- (NSInteger)getfunctionPerm;

- (BOOL)isLogin;



@end

NS_ASSUME_NONNULL_END
