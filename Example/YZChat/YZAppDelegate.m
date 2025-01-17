//
//  YZAppDelegate.m
//  YZChat
//
//  Created by QiaoBangZhu on 12/11/2020.
//  Copyright (c) 2020 QiaoBangZhu. All rights reserved.
//

#import "YZAppDelegate.h"

#import <AMapFoundationKit/AMapServices.h>

#import "ReactiveObjC/ReactiveObjC.h"
#import <QMUIKit/QMUIKit.h>
#import "YZLoginViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "YZCommonConstant.h"
#import "YZChatNetworkEngine.h"
#import "YZChatSettingStore.h"

#import "MAGICNavigationViewController.h"

#import <YZChat/YZChat.h>

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
    [AMapServices sharedServices].apiKey = @"7892fa637e3dffeb7f7352790a510398";

    [[YzIMKitAgent shareInstance]initAppId:yzchatAppId];
    self.window.rootViewController = [self getLoginController];
    if ([YZChatSettingStore sharedInstance].isLogin) {
        [self fetchUserInfo];
    }else {
        [self getLoginController];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogout) name: @"YZChatNotification_UserLogout" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forceOffline) name: kYZChatNotification_ForceOffline object:nil];

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

- (void)fetchUserInfo {
    [YZChatNetworkEngine requestUserInfoWithUserId:[[YZChatSettingStore sharedInstance]getUserId] completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] != 200) {
                [[YzIMKitAgent shareInstance] logout];
            }else{
                SysUser *user = [SysUser yy_modelWithDictionary:result[@"data"]];
                [[YzIMKitAgent shareInstance] registerWithSysUser:user loginSuccess:^{
                    [[YzIMKitAgent shareInstance] startAutoWithCurrentVc: nil];
//                    self.window.rootViewController = [[MAGICNavigationViewController alloc] initWithRootViewController: [[YzChatController alloc] initWithChatInfo: [[YzChatInfo alloc] initWithChatId: @"@TGS#1JYI4QCH2" chatName: @"18869096849" isGroup: true] config: nil]];
//                    self.window.rootViewController = [[MAGICNavigationViewController alloc] initWithRootViewController: [[YzConversationListController alloc] initWithChatType: YzChatTypeC2C]];
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
