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
@property (nonatomic, strong, setter=saveUserInfo:) YZUserInfoModel *userInfo;
@property (nonatomic, copy, readonly, getter=getAuthToken) NSString *authToken;
@property (nonatomic, copy, readonly, getter=getUserId) NSString *userId;
@property (nonatomic, copy, readonly, getter=getUserSign) NSString *userSign;
@property (nonatomic, copy, readonly) NSString *nickName;
@property (nonatomic, copy, readonly) NSString *mobile;
@property (nonatomic, copy, readonly, getter=getAppId) NSString *appId;

@property (nonatomic, assign, readonly, getter=isLogin) BOOL isLogin;

@end

NS_ASSUME_NONNULL_END
