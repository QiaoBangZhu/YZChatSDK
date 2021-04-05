//
//  YZChatSettingStore.h
//  YZChat_Example
//
//  Created by magic on 2021/3/26.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZCommonConstant.h"
#import "AbstractUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZChatSettingStore : NSObject

AS_SINGLETON(YZChatSettingStore);

/**
 * userInfo
 */
@property (nonatomic, strong, setter=saveUserInfo:) AbstractUserModel *userInfo;

- (NSString *)getUserId;
- (NSString *)getUserSign;
- (NSString *)getAuthToken;
- (NSString *)getAppId;

- (BOOL)isLogin;

@end

NS_ASSUME_NONNULL_END
