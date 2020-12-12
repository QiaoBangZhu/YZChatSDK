//
//  YChatSettingStore.h
//  YChat
//
//  Created by magic on 2020/9/24.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonConstant.h"

@class  UserInfo;

NS_ASSUME_NONNULL_BEGIN

@interface YChatSettingStore : NSObject

AS_SINGLETON(YChatSettingStore);

/**
 * userInfo
 */
- (void)saveUserInfo:(UserInfo *)userInfo;
- (UserInfo *)getUserInfo;
- (void)logout;

- (NSString *)getAuthToken;
- (NSString *)getUserId;
- (NSString *)getUserSign;
//当有第三方调用元信时候根据此字段判断展示几个tab
- (NSInteger)getfunctionPerm;

- (BOOL)isLogin;



@end

NS_ASSUME_NONNULL_END
