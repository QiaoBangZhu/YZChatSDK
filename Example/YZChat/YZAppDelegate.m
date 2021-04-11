//
//  YZAppDelegate.m
//  YZChat
//
//  Created by QiaoBangZhu on 12/11/2020.
//  Copyright (c) 2020 QiaoBangZhu. All rights reserved.
//

#import "YZAppDelegate.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <QMUIKit/QMUIKit.h>
#import "YZLoginViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "YZCommonConstant.h"
#import "YZChatNetworkEngine.h"
#import "YZChatSettingStore.h"

#import "MAGICNavigationViewController.h"

#if USE_POD
#import "YZChat/YZChat.h"
#else
#import <YZChat/YZChat.h>
#endif

@interface YZAppDelegate()<UNUserNotificationCenterDelegate>

@end

YZAppDelegate *appdel;

@implementation YZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    appdel = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [self registNotification];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

    [[YzIMKitAgent shareInstance]initAppId:yzchatAppId];
    self.window.rootViewController = [self getLoginController];
    if ([YZChatSettingStore sharedInstance].isLogin) {
           [self fetchUserInfo];
       }else {
           [self getLoginController];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogout) name:YZChatSDKNotification_UserStatusListener object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forceOffline) name:YZChatSDKNotification_ForceOffline object:nil];

    // Override point for customization after application launch.
    return YES;
}


- (void)didLogout {
    [UIApplication sharedApplication].keyWindow.rootViewController = [self getLoginController];
}

- (void)forceOffline {
    [UIApplication sharedApplication].keyWindow.rootViewController = [self getLoginController];
    [QMUITips showWithText:@"您的账号已经在其他终端登录"];
}

- (UIViewController *)getLoginController {
    YZLoginViewController *login = [[YZLoginViewController alloc]init];
    return [[MAGICNavigationViewController alloc] initWithRootViewController:login];
}

//list->(
//   "V2TIMConversation = type:1 conversationID:c2c_4624e6e2fd351a0eeaee47490997258e userID:4624e6e2fd351a0eeaee47490997258e groupID:(null) groupType:(null) showName:\U4e00\U4e8c\U4e00 faceUrl:https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/1610885063886file.png unreadCount:0 recvOpt:0 lastMessage:V2TIMMessage = msgID:144115226648592205-1618120601-820671915 timestamp:2021-04-11 05:56:42 +0000 sender:4624e6e2fd351a0eeaee47490997258e nickName:\U4e00\U4e8c\U4e00 friendRemark:(null) nameCard:(null) faceURL:https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/1610885063886file.png groupID:(null) seq:12523 userID:4624e6e2fd351a0eeaee47490997258e status:2 isSelf:0 isRead:1 isPeerRead:1 groupAtUserList:(null) elemType:2 textElem:(null) customElem:V2TIMCustomElem = data:{length = 347, bytes = 0x7b0a2020 226f6e6c 696e6555 7365724f ... 4422203a 20310a7d } imageElem:(null) soundElem:(null) videoElem:(null) fileElem:(null) locationElem:(null) faceElem:(null) groupTipsElem:(null) localCustomData:{length = 0, bytes = 0x} localCustomInt:0 draftText:(null) draftTimestamp:(null)",
//   "V2TIMConversation = type:2 conversationID:group_@TGS#1JYI4QCH2 userID:(null) groupID:@TGS#1JYI4QCH2 groupType:Work showName:1886909684 faceUrl: unreadCount:0 recvOpt:0 lastMessage:V2TIMMessage = msgID:144115233885213750-1617965556-1656311012 timestamp:2021-04-09 10:52:37 +0000 sender:5078f38d8480589cb5d3136bcfe6d734 nickName:18869096849 friendRemark:(null) nameCard: faceURL:https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/1617535520125file.png groupID:@TGS#1JYI4QCH2 seq:8 userID:(null) status:2 isSelf:1 isRead:1 isPeerRead:0 groupAtUserList:(null) elemType:2 textElem:(null) customElem:V2TIMCustomElem = data:{length = 390, bytes = 0x7b0a2020 226f6e6c 696e6555 7365724f ... 4422203a 20310a7d } imageElem:(null) soundElem:(null) videoElem:(null) fileElem:(null) locationElem:(null) faceElem:(null) groupTipsElem:(null) localCustomData:{length = 0, bytes = 0x} localCustomInt:0 draftText:(null) draftTimestamp:(null)"
//), next->-1, isFinished->1

- (void)fetchUserInfo {
    [YZChatNetworkEngine requestUserInfoWithUserId:[[YZChatSettingStore sharedInstance]getUserId] completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] != 200) {
                [[YzIMKitAgent shareInstance] logout];
            }else{
                SysUser *user = [SysUser yy_modelWithDictionary:result[@"data"]];
                [[YzIMKitAgent shareInstance] registerWithSysUser:user loginSuccess:^{
                    [[YzIMKitAgent shareInstance] startAutoWithCurrentVc: nil];
                 } loginFailed:^(NSInteger errCode, NSString * _Nonnull errMsg) {
                     NSLog(@"error =%@",errMsg);
                }];
            }
        }
    }];
}

- (void)registNotification
{
    //iOS10特有
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    // 点击允许
                  [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        NSLog(@"%@", settings);
                    }];
          } else {
                    // 点击不允许
                    NSLog(@"注册失败");
         }
    }];
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    _deviceToken = deviceToken;
    [[YzIMKitAgent shareInstance]didRegisterForRemoteNotificationsWithDeviceToken: deviceToken];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [[YzIMKitAgent shareInstance]didReceiveRemoteNotification:userInfo];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
