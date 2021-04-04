//
//  YZChatSettingStore.h
//  YZChat_Example
//
//  Created by magic on 2021/3/26.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZCommonConstant.h"
#import "YZUserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZChatSettingStore : NSObject

AS_SINGLETON(YZChatSettingStore);

/**
 * userInfo
 */
- (void)saveUserInfo:(YZUserInfoModel *)userInfo;
- (YZUserInfoModel *)getUserInfo;

- (NSString *)getAuthToken;
- (NSString *)getUserId;
- (NSString *)getUserSign;
- (NSString *)getNickName;
- (NSString *)getMobile;
- (NSString *)getAppId;

- (BOOL)isLogin;

@end

NS_ASSUME_NONNULL_END
