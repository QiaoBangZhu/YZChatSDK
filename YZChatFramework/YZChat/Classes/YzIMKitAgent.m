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
#import "UserInfo.h"
#import "YChatSettingStore.h"
#import <ImSDKForiOS/ImSDK.h>
#import "TUIConversationCellData.h"
#import "ChatViewController.h"
#import "ConversationViewController.h"
#import "TNavigationController.h"
#import "ContactsViewController.h"
#import "WorkZoneViewController.h"
#import "MyViewController.h"
#import "TUIKit.h"
#import "TUITabBarController.h"
#import "YZBaseManager.h"
#import "CommonConstant.h"
#import <AMapFoundationKit/AMapFoundationKit.h>


@interface YzIMKitAgent()
@property (nonatomic,   copy)NSString* appId;
@property (nonatomic, strong)SysUser * user;
@property (nonatomic, strong)UserInfo* userInfo;

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
    [self configureTUIKit];
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
    [YChatNetworkEngine requestSysUserInfoWithAppId:self.appId
                                             userId:self.user.userId
                                           nickName:self.user.nickName
                                           userIcon:[self.user.userIcon length] == 0 ? @"":self.user.userIcon
                                             mobile:@""
                                               card:@""
                                           position:@""
                                              email:@""
                                       departmentId:@""
                                         departName:@""
                                         completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                UserInfo* model = [UserInfo yy_modelWithDictionary:result[@"data"]];
                model.token = result[@"token"];
                self.userInfo = model;
                [YZBaseManager shareInstance].userInfo = model;
                success();
            }else {
                fail([result[@"code"]intValue], result[@"msg"]);
            }
        }else {
            fail(error.code, error.localizedDescription);
        }
    }];
}

//登录腾讯IM
- (void)startAutoWithDeviceToken:(NSData *)deviceToken {
    [YZBaseManager shareInstance].deviceToken = deviceToken;
    
    [[V2TIMManager sharedInstance] login:self.userInfo.userId userSig:self.userInfo.userSign succ:^{
        if (deviceToken) {
            TIMTokenParam *param = [[TIMTokenParam alloc] init];
            //企业证书 ID
            param.busiId = sdkBusiId;
            [param setToken:deviceToken];
            [[TIMManager sharedInstance] setToken:param succ:^{
                NSLog(@"-----> 上传 token 成功 ");
                //推送声音的自定义化设置
                TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
                config.openPush = 0;
                config.c2cSound = @"sms-received.caf";
                config.groupSound = @"sms-received.caf";
                [[TIMManager sharedInstance] setAPNS:config succ:^{
                    NSLog(@"-----> 设置 APNS 成功");
                } fail:^(int code, NSString *msg) {
                    NSLog(@"-----> 设置 APNS 失败");
                }];
            } fail:^(int code, NSString *msg) {
                NSLog(@"-----> 上传 token 失败 ");
            }];
        }
        [[YChatSettingStore sharedInstance]saveUserInfo:self.userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].keyWindow.rootViewController = [[YZBaseManager shareInstance]getMainController];
        });
    } fail:^(int code, NSString *msg) {
        [[YChatSettingStore sharedInstance]logout];
    }];

}

- (void)startChatWithChatId:(NSString *)toChatId
                   chatName:(NSString *)chatName
       finishToConversation:(BOOL)finishToConversation  {
    
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.conversationID = [NSString stringWithFormat:@"c2c_%@",toChatId];
    data.userID = self.userInfo.userId;
    data.title = self.userInfo.nickName;
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversationData = data;
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

    UIImage* backButtonImage = YZChatResource(@"icon_back");
    if (@available(iOS 11.0, *)) {
        [UINavigationBar appearance].backIndicatorImage = backButtonImage;
        [UINavigationBar appearance].backIndicatorTransitionMaskImage = backButtonImage;
    }else {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
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
