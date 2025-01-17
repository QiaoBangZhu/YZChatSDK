//
//  YzIMKitAgent.m
//  YChat
//
//  Created by magic on 2020/12/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YzIMKitAgent.h"
#import "YChatNetworkEngine.h"
#import "THelper.h"
#import <YYModel/YYModel.h>
#import "YUserInfo.h"
#import "YChatSettingStore.h"
#import <ImSDKForiOS/ImSDK.h>
#import "TUIConversationCellData.h"
#import "YzInternalChatController.h"
#import "TNavigationController.h"
#import "YWorkZoneViewController.h"
#import "YZMyViewController.h"
#import "TUIKit.h"
#import "TUITabBarController.h"
#import "YZBaseManager.h"
#import "CommonConstant.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "YZUtil.h"
#import "NSBundle+YZBundle.h"
#import "UIColor+Foundation.h"
#import "YzContactsViewController.h"
#import "TUICallUtils.h"

#import "YZCardMsgData.h"
#import "YzIMKitAgent+Private.h"

NSString * const kYZChatNotification_ForceOffline = @"YZChatSDKNotification_ForceOffline";

typedef struct {
    NSUInteger c2c;
    NSUInteger group;
} YzUnreadCount;

@interface YzIMKitAgent()
@property (nonatomic,   copy)NSString* appId;
@property (nonatomic, strong)SysUser * user;
@property (nonatomic, strong)YUserInfo* userInfo;
@property(nullable, nonatomic, weak) id<YzIMKitAgentListener> listener;

@property(nonatomic,  copy) NSString *groupID;
@property(nonatomic,  copy) NSString *userID;
@property(nonatomic,strong) V2TIMSignalingInfo *signalingInfo;
@property(nonatomic,strong) NSData   *deviceToken;
@property(nullable, nonatomic, weak) id<YzConversationListener> conversationListener;

@property (nonatomic, strong) NSArray<V2TIMConversation *> *conversationList;
@property (nonatomic, assign) NSUInteger c2cUnreadCount;
@property (nonatomic, assign) NSUInteger groupUnreadCount;

/// 群申请列表
@property (nonatomic, strong) NSArray <TUIGroupPendencyCellData *>*groupApplicationList;
/// 有加群申请的群id
@property (nonatomic, strong) NSSet <NSString *>*groupApplicationGroupIDs;
@property (nonatomic, assign) BOOL isGroupApplicationLoading;

@end

@implementation YzIMKitAgent

+ (YzIMKitAgent *)shareInstance {
    static dispatch_once_t onceToken;
    static YzIMKitAgent * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[YzIMKitAgent alloc] init];
    });
    return g_sharedInstance;
}

- (void)initAppId:(NSString *)appId {
    self.appId = appId;
    [YZBaseManager shareInstance].appId = appId;
    [self configureTUIKit];
    [self configureObserver];
}

# pragma mark -- configure

- (void)configureTUIKit {
    [[TUIKit sharedInstance] setupWithAppId:SDKAPPID];
    [TUIKit sharedInstance].config.avatarType = TAvatarTypeRounded;
    [TUIKit sharedInstance].config.defaultAvatarImage = YZChatResource(@"defaultAvatarImage");
    [TUIKit sharedInstance].config.defaultGroupAvatarImage = YZChatResource(@"defaultGrpImage");
}

- (void)configureObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserStatus:)
                                                 name:TUIKitNotification_TIMUserStatusListener
                                               object:nil];
    // 有新的会话
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewConversation:)
                                                 name:TUIKitNotification_TIMRefreshListener_Add
                                               object:nil];

    // 某些会话的关键信息发生变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onConversationChanged:)
                                                 name:TUIKitNotification_TIMRefreshListener_Changed
                                               object:nil];

    // 加群申请
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiveJoinApplication:)
                                                 name:TUIKitNotification_onReceiveJoinApplication
                                               object:nil];
}

// 有新的会话（比如收到一个新同事发来的单聊消息、或者被拉入了一个新的群组中）
- (void)onNewConversation:(NSNotification *)notification {
    [self updateConversationList: notification];
}

// 某些会话的关键信息发生变化（未读计数发生变化、最后一条消息被更新等等）
- (void)onConversationChanged:(NSNotification *)notify {
    [self updateConversationList: notify];
}

// 收到加群申请
- (void)onReceiveJoinApplication:(NSNotification *)notify {
    [self reloadGroupApplicationList];
}

- (void)updateConversationList:(NSNotification *)notify {
    [self conversationUnRead:^(NSUInteger c2cUnreadCount, NSUInteger groupUnread) {
        if ([self.conversationListener respondsToSelector: @selector(updateUnreadCount:groupUnread:)]) {
            [self.conversationListener updateUnreadCount: c2cUnreadCount groupUnread: groupUnread];
        }
    } failure: nil];

    if ([self.conversationListener respondsToSelector: @selector(updateConversation:)]) {
        [self.conversationListener updateConversation: notify.object];
    }
}

# pragma mark -- Method

- (void)registerWithSysUser:(SysUser *)sysUser
               loginSuccess:(YzChatSysUserSuccess)success
                loginFailed:(YzChatSysUserFailure)fail {
    self.user = sysUser;
    if (![self.user.userId length]) {
        [THelper makeToast:@"userId不能为空"];
        return;
    }else if(![self.user.nickName length]) {
        [THelper makeToast:@"nickName不能为空"];
        return;
    }
    @weakify(self)
    [YChatNetworkEngine requestSysUserInfoWithAppId:self.appId
                                             userId:self.user.userId
                                           nickName:self.user.nickName
                                           userIcon:[self.user.userIcon length] == 0 ? @"":self.user.userIcon
                                             mobile:[self.user.mobile length] == 0 ? @"" :self.user.mobile
                                               card:[self.user.card length] == 0 ? @"" : self.user.card
                                           position:[self.user.position length] == 0 ? @"" : self.user.position
                                              email:[self.user.email length] == 0 ? @"" : self.user.email
                                       departmentId:[self.user.departMentId length] == 0 ? @"":self.user.departMentId
                                         departName:[self.user.departName length] == 0 ? @"":self.user.departName
                                               city:[self.user.city length] == 0 ? @"" : self.user.city
                                      userSignature:[self.user.userSignature length] == 0 ? @"" :self.user.userSignature
                                         completion:^(NSDictionary *result, NSError *error)  {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                YUserInfo* model = [YUserInfo yy_modelWithDictionary:result[@"data"]];
                model.nickName = sysUser.nickName;
                model.mobile = sysUser.mobile;
                model.card = sysUser.card;
                model.position = sysUser.position;
                model.email = sysUser.email;
                model.departName = sysUser.departName;
                model.city = sysUser.city;
                model.userSignature = sysUser.userSignature;
                model.token = result[@"token"];
                model.mobile = sysUser.mobile;
                model.companyId = self.appId;

                self.userInfo = model;
                self.groupApplicationList = @[];
                self.groupApplicationGroupIDs = [[NSSet alloc] init];
                
                [YZBaseManager shareInstance].userInfo = model;
                [[V2TIMManager sharedInstance] login:self.userInfo.userId userSig:self.userInfo.userSign succ:^{
                    @strongify(self)
                    [[YChatSettingStore sharedInstance]saveUserInfo:self.userInfo];
                    success();
                } fail:^(int code, NSString *msg) {
                    [[YChatSettingStore sharedInstance]logout];
                    fail(code, result[@"msg"]);
                }];
            }else {
                fail([result[@"code"]integerValue], result[@"msg"]);
            }
        }else {
            fail(error.code, error.localizedDescription);
        }
    }];
}

//打开元讯IM页面
- (void)startAutoWithCurrentVc:(nullable UIViewController *)rootVc{
    if ([V2TIMManager sharedInstance].getLoginStatus == V2TIM_STATUS_LOGOUT) {
        [THelper makeToast:@"必须先登录IM才能调用此函数"];
        return;
    }
    if (!rootVc) {
        [UIApplication sharedApplication].delegate.window.rootViewController = [[YZBaseManager shareInstance] getMainController];
        return;
    }
    [YZBaseManager shareInstance].rootViewController = rootVc;
    YzTabBarViewController* tab = [[YZBaseManager shareInstance] getMainController];
    tab.conversationListController.isNeedCloseBarButton = YES;
    tab.modalPresentationStyle =UIModalPresentationFullScreen;
    [rootVc presentViewController:tab animated:YES completion:nil];
}

- (UIViewController*)startChatWithChatId:(NSString *)toChatId
                                chatName:(NSString *)chatName
                    finishToConversation:(BOOL)finishToConversation  {
    if ([toChatId length] == 0) {
        [THelper makeToast:@"聊天对象的uid不能为空"];
        return nil;
    }
    if ([chatName length] == 0) {
        [THelper makeToast:@"聊天对象昵称不能为空"];
        return nil;
    }
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = [NSString stringWithFormat:@"c2c_%@",@""];
    data.userID = toChatId;
    data.title = chatName;
    YzInternalChatController *chat = [[YzInternalChatController alloc] initWithConversation: data];
    if(finishToConversation){
        YzTabBarViewController* tab = [[YZBaseManager shareInstance] getMainController];
        tab.conversationListController.isNeedCloseBarButton = YES;
        [tab.conversationListController.navigationController pushViewController:chat animated:YES];
        return tab;
    }
    return  chat;
}

- (UIViewController *)startCustomMessageWithChatId:(NSString *)toChatId
                                          chatName:(NSString *)chatName
                                           message:(YzCustomMsg *)message
                                           success:(YzChatSysUserSuccess)success
                                           failure:(YzChatSysUserFailure)failure {

    if ([message.title length] == 0) {
        !failure ?: failure(-1, @"标题不能为空");
        return nil;
    }
    if ([message.link length] == 0) {
        !failure ?: failure(-1, @"链接不能为空");
        return nil;
    }
    if ([message.desc length] == 0) {
        !failure ?: failure(-1, @"描述不能为空");
        return nil;
    }
    if ([message.logo length] == 0) {
        !failure ?: failure(-1, @"图片不能为空");
        return nil;
    }

    YZCardMsgData *msg = [[YZCardMsgData alloc] initWithTitle: message.title desc: message.desc logo: message.logo link: message.link];
    return [self sendCustomMessage: msg toConversation: toChatId success: success failure: failure];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.deviceToken = deviceToken;
    [YZBaseManager shareInstance].deviceToken = deviceToken;
    [self configureAPNSConfig];
}

- (void)configureAPNSConfig {
    TIMTokenParam *param = [[TIMTokenParam alloc] init];
    //企业证书 ID
    param.busiId = sdkBusiId;
    [param setToken: _deviceToken];
    [[TIMManager sharedInstance] setToken:param succ:^{
        NSLog(@"-----> 上传 token 成功 ");
        NSString *c2cSoundPath = [[NSBundle yzBundle] pathForResource:@"sms-received" ofType:@"caf"];
        NSString *groupSoundPath = [[NSBundle yzBundle] pathForResource:@"sms-received" ofType:@"caf"];
        //推送声音的自定义化设置
        TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
        config.openPush = 0;
        config.c2cSound = c2cSoundPath;
        config.groupSound = groupSoundPath;

        [[TIMManager sharedInstance] setAPNS:config succ:^{
            NSLog(@"-----> 设置 APNS 成功");
        } fail:^(int code, NSString *msg) {
            NSLog(@"-----> 设置 APNS 失败");
        }];
    } fail:^(int code, NSString *msg) {
        NSLog(@"-----> 上传 token 失败 ");
    }];

}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *extParam = [YZUtil jsonSring2Dictionary:userInfo[@"ext"]];
    NSDictionary *entity = extParam[@"entity"];
    if (!entity) {
        return;
    }
    // 业务，action : 1 普通文本推送；2 音视频通话推送
    NSString *action = entity[@"action"];
    if (!action) {
        return;
    }
    // 聊天类型，chatType : 1 单聊；2 群聊
    NSString *chatType = entity[@"chatType"];
    if (!chatType) {
        return;
    }
    // action : 1 普通消息推送
    if ([action intValue] == APNs_Business_NormalMsg) {
        if ([chatType intValue] == 1) {   //C2C
            self.userID = entity[@"sender"];
        } else if ([chatType intValue] == 2) { //Group
            self.groupID = entity[@"sender"];
        }
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveNormalMsgAPNs];
        }
    }
    // action : 2 音视频通话推送
    else if ([action intValue] == APNs_Business_Call) {
        // 单聊中的音视频邀请推送不需处理，APP 启动后，TUIkit 会自动处理
        if ([chatType intValue] == 1) {   //C2C
            return;
        }
        // 内容
        NSDictionary *content = [YZUtil jsonSring2Dictionary:entity[@"content"]];
        if (!content) {
            return;
        }
        UInt64 sendTime = [entity[@"sendTime"] integerValue];
        uint32_t timeout = [content[@"timeout"] intValue];
        UInt64 curTime = (UInt64)[[NSDate date] timeIntervalSince1970];
        if (curTime - sendTime > timeout) {
            [THelper makeToast:@"通话接收超时"];
            return;
        }
        self.signalingInfo = [[V2TIMSignalingInfo alloc] init];
        self.signalingInfo.actionType = (SignalingActionType)[content[@"action"] intValue];
        self.signalingInfo.inviteID = content[@"call_id"];
        self.signalingInfo.inviter = entity[@"sender"];
        self.signalingInfo.inviteeList = content[@"invited_list"];
        self.signalingInfo.groupID = content[@"group_id"];
        self.signalingInfo.timeout = timeout;
        self.signalingInfo.data = [YZUtil dictionary2JsonStr:@{SIGNALING_EXTRA_KEY_ROOM_ID : content[@"room_id"], SIGNALING_EXTRA_KEY_VERSION : content[@"version"], SIGNALING_EXTRA_KEY_CALL_TYPE : content[@"call_type"]}];
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveGroupCallAPNs];
        }
    }
}

- (void)onReceiveNormalMsgAPNs {
    if (!self.groupID && !self.userID) return;

    YzTabBarViewController *tab = [[YZBaseManager shareInstance] getMainController];
    [UIApplication sharedApplication].keyWindow.rootViewController = tab;

    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.groupID = self.groupID;
    data.userID = self.userID;
    YzInternalChatController *chat = [[YzInternalChatController alloc] initWithConversation: data];
    [tab.conversationListController.navigationController pushViewController:chat animated:YES];

    self.groupID = nil;
    self.userID = nil;
}

- (void)onReceiveGroupCallAPNs {
    if (self.signalingInfo) {
        [[TUIKit sharedInstance] onReceiveGroupCallAPNs:self.signalingInfo];
        self.signalingInfo = nil;
    }
}

- (void)onUserStatus:(NSNotification *)notification
{
    TUIUserStatus status = [notification.object integerValue];
    switch (status) {
        case TUser_Status_ForceOffline:
        {//强制下线
            [self didLogout];
        }
            break;
        case TUser_Status_ReConnFailed:
        {
            NSLog(@"连网失败");
        }
            break;
        case TUser_Status_SigExpired:
        {
            NSLog(@"userSig过期");
        }
            break;
        default:
            break;
    }
}

- (void)didLogout
{
    [[YChatSettingStore sharedInstance] logout];
    //退出登录
    if (self.listener && [self.listener respondsToSelector: @selector(logout)]) {
        [self.listener logout];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName: kYZChatNotification_ForceOffline object: nil];
    [THelper makeToast:@"您的账号已经在其他终端登录"];
}

- (void)openURL:(NSURL *)url options:(NSDictionary *)options {
    if ([[url scheme] isEqualToString:scheme]) {
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YzWorkzonePayReturn" object:nil];
    }
}

- (void)logout {
    [[V2TIMManager sharedInstance]logout:nil fail:nil];
    [[YChatSettingStore sharedInstance] logout];
}

- (void)reconnectWithId:(NSString *)userId
               userSign:(NSString *)usersign
                   fail:(nonnull loginFail)fail {
    if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGOUT) {
        @weakify(self);
        [[TUIKit sharedInstance] login:userId userSig:usersign succ:^{
            @strongify(self);
            if (self.deviceToken) {
                //企业证书 ID
                V2TIMAPNSConfig *confg = [[V2TIMAPNSConfig alloc] init];
                confg.businessID = sdkBusiId;
                confg.token = self.deviceToken;
                [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
                } fail:^(int code, NSString *msg) {
                }];
                [UIApplication sharedApplication].delegate.window.rootViewController = [[YZBaseManager shareInstance] getMainController];
            }
            //普通消息推送
            [self onReceiveNormalMsgAPNs];
            //音视频消息推送
            [self onReceiveGroupCallAPNs];
        } fail:^(int code, NSString *msg) {
            [[YChatSettingStore sharedInstance]logout];
            fail();
        }];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (UIViewController *)getRootViewController{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

- (UIViewController *)findVisibleViewController {
    UIViewController* currentViewController = [self getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    return currentViewController;
}

#pragma mark - Public

- (void)addListener:(id<YzIMKitAgentListener>)listener {
    self.listener = listener;
}

#pragma mark - Helper

+ (YzUnreadCount)calcUnreadForConversationList:(NSArray<V2TIMConversation *> *)conversationList {
    NSUInteger c2c = 0, group = 0;
    for (V2TIMConversation *conversation in conversationList) {
        if (conversation.userID == nil) {
            group += conversation.unreadCount;
        } else {
            c2c += conversation.unreadCount;
        }
    }

    YzUnreadCount unread = { c2c, group };
    return unread;
}

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              Conversation
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark -- 会话相关

const NSUInteger STEP_LENGTH = 100;

@implementation YzIMKitAgent (Conversation)

- (void)addConversationListener:(id<YzConversationListener>)listener {
    self.conversationListener = listener;
}

- (void)loadConversation:(NSUInteger)next
                    type:(YzChatType)type
                 success:(YzChatConversationListSuccess)success
                 failure:(YzChatSysUserFailure)failure {
    if (!success) return;

    // 截取开始位置
    NSUInteger startIndex = next * STEP_LENGTH;
    NSUInteger maxCount = startIndex + STEP_LENGTH;

    [[V2TIMManager sharedInstance] getConversationList: 0 count: INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {

        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (V2TIMConversation *conversation in list) {
            if ((type & conversation.type) == conversation.type) {
                [temp addObject: conversation];
            }

            // 多出一个用于判断是否还有更多
            if (temp.count > startIndex + STEP_LENGTH) break;
        }

        // 没有更多数据
        if (temp.count < startIndex) {
            success(@[], -1, YES);
        }
        // 有数据
        else {
            BOOL noMore = temp.count <= maxCount;
            NSUInteger length = STEP_LENGTH;
            if (noMore) {
                length = temp.count - startIndex;
            }
            NSArray *list = [temp subarrayWithRange: NSMakeRange(startIndex, length)];

            success(list, noMore ? -1 : next + 1, noMore);
        }

    } fail:^(int code, NSString *msg) {
        !failure ?: failure(code, msg);
    }];
}

- (void)getConversation:(NSString *)conversionId
                success:(YzChatConversationSuccess)success
                failure:(YzChatSysUserFailure)failure {
    if (!success) return;

    [[V2TIMManager sharedInstance] getConversation: conversionId succ:^(V2TIMConversation *conv) {
        success(conv);
    } fail:^(int code, NSString *msg) {
        !failure ?: failure(code, msg);
    }];
}

- (void)conversationUnRead:(YzChatUnreadCountSuccess)success
                   failure:(YzChatSysUserFailure)failure {
    if (!success) return;

    [[V2TIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {

        YzUnreadCount unread = [YzIMKitAgent calcUnreadForConversationList: list];
        self.c2cUnreadCount = unread.c2c;
        self.groupUnreadCount = unread.group;
        success(unread.c2c, unread.group);

    } fail:^(int code, NSString *msg) {
        !failure ?: failure(code, msg);
    }];
}

- (UIViewController *)sendCustomMessage:(YzCustomMessageData *)message
                         toConversation:(NSString *)conversationId
                                success:(YzChatSysUserSuccess)success
                                failure:(YzChatSysUserFailure)failure {
    if (!conversationId) {
        return [[YzContactsViewController alloc] initWithCustomMessage: message];
    }

    NSString *userId, *groupId;
    if ([conversationId hasPrefix: @"c2c_"]) {
        userId = [conversationId substringFromIndex: 4];
    } else if ([conversationId hasPrefix: @"group_"]) {
        groupId = [conversationId substringFromIndex: 6];
    }
    
    [self sendCustomMessage: message userId: userId groupId: groupId success: success failure: failure];

    return nil;
}

@end

#pragma mark - 消息相关

@implementation YzIMKitAgent (Private_Message)

- (void)sendCustomMessage:(YzCustomMessageData*)message
                   userId:(nullable NSString *)userId
                  groupId:(nullable NSString *)groupId
                  success:(YzChatSysUserSuccess)success
                  failure:(YzChatSysUserFailure)failure {

    if (!userId && !groupId) {
        !failure ?: failure(-1, @"未找到会话");
        return;
    }

    YzCustomMessageCellData *cellData = [[YzCustomMessageCellData alloc] initWithDirection: MsgDirectionOutgoing];
    cellData.customMessageData = message;
    cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage: message.data];
    // 设置推送
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
    NSDictionary *ext = @{
        @"entity": @{
                @"action": @(APNs_Business_NormalMsg),
                @"chatType": @(userId  ? 1 : 2),
                @"sender": userId ? [[V2TIMManager sharedInstance] getLoginUser] : groupId,
                @"version": @(APNs_Version)
        }
    };
    info.ext = [TUICallUtils dictionary2JsonStr: ext];

    // 发消息
    [[V2TIMManager sharedInstance] sendMessage: cellData.innerMessage receiver: userId groupID: groupId priority: V2TIM_PRIORITY_DEFAULT onlineUserOnly: NO offlinePushInfo: info progress:^(uint32_t progress) {
    } succ:^{
        !success ?: success();
    } fail:^(int code, NSString *desc) {
        !failure ?: failure(code, desc);
    }];
}

@end


#pragma mark - 群组相关

@implementation YzIMKitAgent (Private_Group)

// 重新获取加群申请列表
- (void)reloadGroupApplicationList {
    if (self.isGroupApplicationLoading) return;

    self.isGroupApplicationLoading = YES;
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupApplicationList:^(V2TIMGroupApplicationResult *result) {
        @strongify(self)
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        NSMutableSet *tempSet = [[NSMutableSet alloc] init];
        for (V2TIMGroupApplication *item in result.applicationList) {
            if (item.handleStatus == V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED) {
                TUIGroupPendencyCellData *data = [[TUIGroupPendencyCellData alloc] initWithPendency: item];
                [temp addObject: data];
                [tempSet addObject: item.groupID];
            }
        }
        self.groupApplicationList = [temp copy];
        [self p_updateGroupApplicationGroupIDs: tempSet];
        self.isGroupApplicationLoading = NO;
    } fail:nil];
}

// 同意加群
- (void)acceptGroupApplication:(TUIGroupPendencyCellData *)data {
    [data accept];
    NSMutableSet *tempSet = [[NSMutableSet alloc] init];
    for (TUIGroupPendencyCellData *data in self.groupApplicationList) {
        if (!data.isRejectd && !data.isAccepted) {
            [tempSet addObject: data.groupId];
        }
    }
    [self p_updateGroupApplicationGroupIDs: tempSet];
}

// 拒绝加群
- (void)rejectGroupApplication:(TUIGroupPendencyCellData *)data {
    [data reject];
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity: self.groupApplicationList.count - 1];
    NSMutableSet *tempSet = [[NSMutableSet alloc] init];
    for (TUIGroupPendencyCellData *data in self.groupApplicationList) {
        if (!data.isRejectd && !data.isAccepted) {
            [temp addObject: data];
            [tempSet addObject: data.groupId];
        }
    }
    self.groupApplicationList = [temp copy];
    [self p_updateGroupApplicationGroupIDs: tempSet];
}

- (void)p_updateGroupApplicationGroupIDs:(NSMutableSet *)groupIds {
    if (groupIds.count != self.groupApplicationGroupIDs.count ||
        ![groupIds isEqualToSet: self.groupApplicationGroupIDs]) {
        self.groupApplicationGroupIDs = [groupIds copy];
    }
}

@end
