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
#import "YZChatViewController.h"
#import "YZConversationViewController.h"
#import "TNavigationController.h"
#import "ContactsViewController.h"
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
#import "YZMsgManager.h"
#import <Aspects/Aspects.h>

@interface YzIMKitAgent()
@property (nonatomic,   copy)NSString* appId;
@property (nonatomic, strong)SysUser * user;
@property (nonatomic, strong)YUserInfo* userInfo;

@property(nonatomic,  copy) NSString *groupID;
@property(nonatomic,  copy) NSString *userID;
@property(nonatomic,strong) V2TIMSignalingInfo *signalingInfo;
@property(nonatomic,strong) NSData   *deviceToken;

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
    [self configureNavigationBar];
    [self configureAmap];
}

//高德地图
- (void)configureAmap {
    [AMapServices sharedServices].apiKey = amapKey;
}

- (void)registerWithSysUser:(SysUser *)sysUser
               loginSuccess:(YChatSysUserSucc)success
                     loginFailed:(YChatSysUserFail)fail {
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
- (void)startAutoWithCurrentVc:(UIViewController *)rootVc{
    if ([V2TIMManager sharedInstance].getLoginStatus == V2TIM_STATUS_LOGOUT) {
        [THelper makeToast:@"必须先登录IM才能调用此函数"];
        return;
    }
    if (!rootVc) {
        [UIApplication sharedApplication].delegate.window.rootViewController = [[YZBaseManager shareInstance] getMainController];
        return;
    }
    [YZBaseManager shareInstance].rootViewController = rootVc;
    TUITabBarController* tab = [[YZBaseManager shareInstance] getMainController];
    TNavigationController* nav = (TNavigationController*)tab.viewControllers[0];
    YZConversationViewController * convc = (YZConversationViewController*)nav.viewControllers[0];
    convc.isNeedCloseBtn = YES;
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
    YZChatViewController *chat = [[YZChatViewController alloc] init];
    chat.conversationData = data;
    if(finishToConversation){
        TUITabBarController* tab = [[YZBaseManager shareInstance] getMainController];
        TNavigationController* nav = (TNavigationController*)tab.viewControllers[0];
        YZConversationViewController * convc = (YZConversationViewController*)nav.viewControllers[0];
        convc.isNeedCloseBtn = YES;
        [nav pushViewController:chat animated:YES];
        return tab;
    }
    return  chat;
}

- (UIViewController *)startCustomMessageWithChatId:(NSString *)toChatId chatName:(NSString *)chatName message:(YzCustomMsg *)message {
    if ([toChatId length] > 0 && [chatName length]> 0) {
        //直接发送消息
        [[YZMsgManager shareInstance]sendMessageWithMsgType:YZSendMsgTypeC2C message:message userId:toChatId grpId:nil loginSuccess:^{
        } loginFailed:^(int errCode, NSString *errMsg) {
            [THelper makeToastError:errCode msg:errMsg];
        }];
        return nil;
    }else {
        ContactsViewController* vc = [[ContactsViewController alloc]init];
        vc.customMsg = message;
        vc.isFromOtherApp = YES;
        return vc;
    }
}

- (void)configureTUIKit {
    [[TUIKit sharedInstance] setupWithAppId:SDKAPPID];
    [TUIKit sharedInstance].config.avatarType = TAvatarTypeRounded;
    [TUIKit sharedInstance].config.defaultAvatarImage = YZChatResource(@"defaultAvatarImage");
    [TUIKit sharedInstance].config.defaultGroupAvatarImage = YZChatResource(@"defaultGrpImage");
}

- (void)configureNavigationBar {
    //隐藏返回标题文字
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}forState:UIControlStateHighlighted];
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    UIImage* backButtonImage = [YZChatResource(@"icon_back") imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    if (@available(iOS 11.0, *)) {
        [UINavigationBar appearance].backIndicatorImage = backButtonImage;
        [UINavigationBar appearance].backIndicatorTransitionMaskImage = backButtonImage;
    }else {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
//    if (@available(iOS 11.0, *)) {
//        NSError *error;
//           [UIViewController aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
//               UIViewController *controller = aspectInfo.instance;
//               controller.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//           } error:&error];
//           if (error) NSLog(@"%@", error);
//    }else {
//        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    }

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
            [self onReceiveNomalMsgAPNs];
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

- (void)onReceiveNomalMsgAPNs {
    if (self.groupID.length > 0 || self.userID.length > 0) {
        TUITabBarController *tab = [[YZBaseManager shareInstance]getMainController];
        if (tab.selectedIndex != 0) {
            [tab setSelectedIndex:0];
        }
        [UIApplication sharedApplication].keyWindow.rootViewController = tab;
        UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
        YZConversationViewController *vc = (YZConversationViewController *)nav.viewControllers.firstObject;
        [vc pushToChatViewController:self.groupID userID:self.userID];
        self.groupID = nil;
        self.userID = nil;
    }
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
    [[NSNotificationCenter defaultCenter]postNotificationName:YZChatSDKNotification_ForceOffline object:nil];
}

- (void)openURL:(NSURL *)url options:(NSDictionary *)options {
    if ([[url scheme] isEqualToString:scheme]) {
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"YzWorkzonePayReturn" object:nil];
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

/**
 
 {
     code = 200;
     data =     {
         departName = "\U5e73\U53f0\U7814\U53d1\U4e2d\U5fc3";
         departmentId = de241446a50499bb77a8684cf610fd04;
         functionPerm = 15;
         nickName = "\U5927\U7edf\U9886";
         userIcon = "https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/1607087952606file.png";
         userId = 95e6bd162f019b60ad8380fba5e0db41;
         userSign = "eJwtjdEKgjAYhd9lt4X8-za3KXQRFEFJQdZNd47NWpEsHZpE755ol*c7fOd8yCnLo9bWJCU0AjIfszO2Cq50I05iK7RBQUvARAsojGIKSl3EFozm*Hca8yi8d4akyAE4o5Ti1Ni3d7UlqQCuACYW3HMgKECiAsbkf8Ndh0NdNYfkbmXYVUr067z23abF175v5ep8O2Yyu*hZsQ39sluQ7w-rKDh4";
     };
     msg = "";
     token = 7e19d8fa3c6f8e2a5a4767a2bbf8c4e1;
 }
 
 
 
 
 */

@end
