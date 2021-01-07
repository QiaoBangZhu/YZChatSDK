//
//  YzIMKitAgent.h
//  YChat
//
//  Created by magic on 2020/12/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SysUser.h"
NS_ASSUME_NONNULL_BEGIN

//手动退出YZChatSDKUI的通知
#define YZChatSDKNotification_UserStatusListener @"YZChatSDKNotification_UserStatusListener"
//强制下线通知
#define YZChatSDKNotification_ForceOffline @"YZChatSDKNotification_ForceOffline"

/// 成功回调
typedef void (^YChatSysUserSucc)(void);
/// 失败回调
typedef void (^YChatSysUserFail)(int errCode, NSString * errMsg);

@interface YzIMKitAgent : NSObject

/**
 *  获取 YzIMKitAgent 管理实例
 */
+(YzIMKitAgent *)shareInstance;

/**
 * 初始化时候调用 传入appId
 */
- (void)initAppId:(NSString *)appId;

/**
 * 同步数据,最好每次启动的时候可以调用该接口保持数据同步
 */
- (void)registerWithSysUser:(SysUser*)sysUser
               loginSuccess:(YChatSysUserSucc)success
                loginFailed:(YChatSysUserFail)fail;

/**
 * 直接启动IM(必须登录成功才可以启动)
 */
- (void)startAutoWithDeviceToken:(NSData*)deviceToken;

/*
 *  直接聊天
 *  @param toChatId 同步数据时候的唯一ID。
 *  @param chatName 聊天人的昵称。
 *  @param finishToConversation
            false 从聊天界面返回到你发起的页面，
            true  回到sdk会话页面。
 */
- (void)startChatWithChatId:(NSString*)toChatId
                   chatName:(NSString*)chatName
       finishToConversation:(BOOL)finishToConversation;
/*
 * 获取device Token(必须调用)
 */
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/*
 * 收到的推送消息(必须调用)
 **/
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

/*
 * 如使用工作台的打车功能则需要 在需要在appdegate内
 - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
    方法内调用此函数,并设置app的url scheme 为 tg.tripg.com
 */
- (void)openURL:(NSURL *)url options:(NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
