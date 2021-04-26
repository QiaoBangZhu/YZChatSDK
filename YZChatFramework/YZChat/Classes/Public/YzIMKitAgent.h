//
//  YzIMKitAgent.h
//  YChat
//
//  Created by magic on 2020/12/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SysUser.h"
#import "YzCustomMsg.h"

NS_ASSUME_NONNULL_BEGIN

//手动退出YZChatSDKUI的通知
#define YZChatSDKNotification_UserStatusListener @"YZChatSDKNotification_UserStatusListener"
//强制下线通知
#define YZChatSDKNotification_ForceOffline @"YZChatSDKNotification_ForceOffline"

@interface YzIMKitAgent : NSObject

/// 成功回调
typedef void (^YzChatSysUserSuccess)(void);
/// 失败回调
typedef void (^YzChatSysUserFailure)(NSInteger errCode, NSString * errMsg);
///登录失败
typedef void (^loginFail)(void);

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
               loginSuccess:(YzChatSysUserSuccess)success
                loginFailed:(YzChatSysUserFailure)fail;

/**
 * 直接启动IM(必须登录成功才可以启动)
 *  @param rootVc 当前调用类，如为空则无法返回当前页面
 */
- (void)startAutoWithCurrentVc:(nullable UIViewController *)rootVc;

/*
 *  直接聊天
 *  @param toChatId 同步数据时候的唯一ID。
 *  @param chatName 聊天人的昵称。
 *  @param finishToConversation
            false 从聊天界面返回到你发起的页面，
            true  回到sdk会话页面。
 */
- (UIViewController *)startChatWithChatId:(NSString*)toChatId
                                 chatName:(NSString*)chatName
                     finishToConversation:(BOOL)finishToConversation;
/*
 * 打开通讯录页面 发送卡片
 * @param toChatId 同步数据时候的唯一ID,如果不传将启动通讯里列表。
 * @param chatName 聊天人的昵称。
 * @param message  数据模型
 */
- (UIViewController *)startCustomMessageWithChatId:(NSString*)toChatId
                                          chatName:(NSString*)chatName
                                           message:(YzCustomMsg*)message
                                           success:(YzChatSysUserSuccess)success
                                           failure:(YzChatSysUserFailure)failure;

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
/*
 * 退出IM
 */
- (void)logout;
/*
 * 掉线重新登录
 */
- (void)reconnectWithId:(NSString*)userId
               userSign:(NSString*)usersign
                   fail:(loginFail)fail;

@end

@class V2TIMConversation;
@class V2TIMGroupAtInfo;

@protocol YzConversationListener <NSObject>
@optional

- (void)updateUnreadCount:(NSUInteger)c2cUnreadCount groupUnread:(NSUInteger)groupUnread;
- (void)updateConversation:(NSArray<V2TIMConversation *>*)conversationList;

@end

@interface YzIMKitAgent (Conversation)

typedef NS_OPTIONS(NSUInteger, YzChatType) {
    // 单聊
    YzChatTypeC2C = 1 << 0,
    // 群聊
    YzChatTypeGroup  = 1 << 1,
};

/// 获取会话列表成功的回调，next：下一次分页拉取的游标 isFinished：会话列表是否已经拉取完毕
typedef void(^YzChatConversationListSuccess)(NSArray<V2TIMConversation *>*list, NSUInteger next, BOOL isFinished);
/// 获取单个会话成功回调
typedef void(^YzChatConversationSuccess)(V2TIMConversation *conversation);
/// 获取未读消息成功回调，c2cUnreadCount单聊未读数，groupUnread群聊未读数
typedef void(^YzChatUnreadCountSuccess)(NSUInteger c2cUnreadCount, NSUInteger groupUnread);

/**
 * 设置会话监听器
 */
- (void)addConversationListener:(id<YzConversationListener>)listener;

/**
 * 获取会话列表
 * @param next 下一次分页拉取的游标
 * @param type 会话列表类型
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)loadConversation:(NSUInteger)next
                    type:(YzChatType)type
                 success:(YzChatConversationListSuccess)success
                 failure:(nullable YzChatSysUserFailure)failure;

/**
 * 获取跟某个人的会话（单聊/群聊）
 * @param conversationId 会话id
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)getConversation:(NSString *)conversationId
                success:(YzChatConversationSuccess)success
                failure:(nullable YzChatSysUserFailure)failure;

/**
 * 获取消息未读数
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)conversationUnRead:(YzChatUnreadCountSuccess)success
                   failure:(nullable YzChatSysUserFailure)failure;

/**
 * 发送自定义消息
 *
 * @param message 自定义消息
 * @param conversationId 会话id
 */
- (nullable UIViewController *)sendCustomMessage:(YzCustomMessageData *)message
                                  toConversation:(nullable NSString *)conversationId
                                         success:(nullable YzChatSysUserSuccess)success
                                         failure:(nullable YzChatSysUserFailure)failure;

@end

NS_ASSUME_NONNULL_END
