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

#if USE_POD
#import "YZChat/YZChat.h"
#else
#import <YZChat/YZChat.h>
#endif

@interface YZAppDelegate()<UNUserNotificationCenterDelegate>

@end

@implementation YZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureNavigationBar];
    [self registNotification];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

    [[YzIMKitAgent shareInstance]initAppId:@"de241446a50499bb77a8684cf610fd04"];


    SysUser* u = [[SysUser alloc]init];
    u.mobile = @"17774942222";
    u.nickName = @"我的IOS";
    u.userId = @"ios20210104";
    [[YzIMKitAgent shareInstance]registerWithSysUser:u loginSuccess:^{
        YZLoginViewController* loginvc = [[YZLoginViewController alloc]init];
        self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:loginvc];
    } loginFailed:^(int errCode, NSString * _Nonnull errMsg) {
            
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didlogout) name:YZChatSDKNotification_UserStatusListener object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forceOffline) name:YZChatSDKNotification_ForceOffline object:nil];

    // Override point for customization after application launch.
    return YES;
}

- (void)startLogin {
    [[YzIMKitAgent shareInstance]startAutoWithDeviceToken:self.deviceToken];
}

- (void)didlogout {
    [UIApplication sharedApplication].keyWindow.rootViewController = [self getLoginController];
}

- (void)forceOffline {
    [UIApplication sharedApplication].keyWindow.rootViewController = [self getLoginController];
    [QMUITips showWithText:@"您的账号已经在其他终端登录"];
}

- (UIViewController *)getLoginController {
    YZLoginViewController *login = [[YZLoginViewController alloc]init];
    return [[UINavigationController alloc]initWithRootViewController:login];
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

- (void)configureNavigationBar {
    //隐藏返回标题文字
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}forState:UIControlStateHighlighted];
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"icon_back"];
    if (@available(iOS 11.0, *)) {
        [UINavigationBar appearance].backIndicatorImage = backButtonImage;
        [UINavigationBar appearance].backIndicatorTransitionMaskImage = backButtonImage;
    }else {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
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
