//
//  YZAppDelegate.m
//  YZChat
//
//  Created by QiaoBangZhu on 12/11/2020.
//  Copyright (c) 2020 QiaoBangZhu. All rights reserved.
//

#import "YZAppDelegate.h"
#import "ReactiveObjC/ReactiveObjC.h"

#if USE_POD
#import "YZChat/YZChat.h"
#else
#import <YZChat/YZChat.h>
#endif

@implementation YZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureNavigationBar];
    [self registNotification];
    [[YzIMKitAgent shareInstance]initAppId:@"de241446a50499bb77a8684cf610fd04"];
    SysUser* user = [[SysUser alloc]init];
    user.userId = @"95e6bd162f019b60ad8380fba5e0db41";
    user.nickName = @"大统领";
    @weakify(self)
    [[YzIMKitAgent shareInstance]registerWithSysUser:user loginSuccess:^{
    @strongify(self)
//        if (self.deviceToken) {
            [self startLogin];
//        }r
     } loginFailed:^(int errCode, NSString * _Nonnull errMsg) {
         NSLog(@"error =%@",errMsg);
    }];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)startLogin {
    [[YzIMKitAgent shareInstance]startAutoWithDeviceToken:self.deviceToken];
}

- (void)registNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)configureNavigationBar {
    //隐藏返回标题文字
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}forState:UIControlStateHighlighted];
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    NSBundle* yzBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[YZAppDelegate class]] pathForResource:@"YZChatResource" ofType:@"bundle"]];
    UIImage *backButtonImage = [[UIImage imageNamed:@"icon_back" inBundle:yzBundle compatibleWithTraitCollection:nil] imageWithTintColor:[UIColor blackColor] renderingMode:UIImageRenderingModeAlwaysOriginal];

    if (@available(iOS 11.0, *)) {
        [UINavigationBar appearance].backIndicatorImage = backButtonImage;
        [UINavigationBar appearance].backIndicatorTransitionMaskImage = backButtonImage;
    }else {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    _deviceToken = deviceToken;
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
