//
//  YZBaseManager.m
//  YChat
//
//  Created by magic on 2020/12/12.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZBaseManager.h"
#import "YConversationViewController.h"
#import "ContactsViewController.h"
#import "YWorkZoneViewController.h"
#import "YZMyViewController.h"
#import "TNavigationController.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"
#import "YzIMKitAgent.h"
#import "YChatSettingStore.h"
#import "YChatNetworkEngine.h"
#import "YZBaseManager.h"

@interface YZBaseManager()
@end

@implementation YZBaseManager

+ (YZBaseManager *)shareInstance {
    static dispatch_once_t onceToken;
    static YZBaseManager * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[YZBaseManager alloc] init];
    });
    return g_sharedInstance;
}

- (void)logout {
    [[YChatSettingStore sharedInstance] logout];
    //退出登录
    [[NSNotificationCenter defaultCenter]postNotificationName:YZChatSDKNotification_UserStatusListener object:nil];
}

- (TUITabBarController *)getMainController {
    TUITabBarController *tbc = [[TUITabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    self.userInfo = [[YChatSettingStore sharedInstance]getUserInfo];
    if ((self.userInfo.functionPerm & 1) > 0) {
        TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
        msgItem.title = @"消息";
        msgItem.normalImage = YZChatResource(@"message_normal");
        msgItem.selectedImage = YZChatResource(@"message_pressed");
        msgItem.controller = [[TNavigationController alloc] initWithRootViewController:[[YConversationViewController alloc] init]];
        [items addObject:msgItem];
    }
    
    if ((self.userInfo.functionPerm & 2) > 0) {
        TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
        contactItem.title = @"通讯录";
        contactItem.selectedImage = YZChatResource(@"contacts_pressed");
        contactItem.normalImage = YZChatResource(@"contacts_normal");
        contactItem.controller = [[TNavigationController alloc] initWithRootViewController:[[ContactsViewController alloc] init]];
        [items addObject:contactItem];
    }
    
    if ((self.userInfo.functionPerm & 4) > 0) {
        TUITabBarItem *workZoneItem = [[TUITabBarItem alloc] init];
        workZoneItem.title = @"工作台";
        workZoneItem.normalImage = YZChatResource(@"workzone_normal");
        workZoneItem.selectedImage = YZChatResource(@"workzone_selected");
        workZoneItem.controller = [[TNavigationController alloc] initWithRootViewController:[[YWorkZoneViewController alloc] init]];
        [items addObject:workZoneItem];
    }
   
    if ((self.userInfo.functionPerm & 8) >0) {
        TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
        setItem.title = @"我";
        setItem.selectedImage = YZChatResource(@"setting_pressed");
        setItem.normalImage = YZChatResource(@"setting_normal");
        setItem.controller = [[TNavigationController alloc] initWithRootViewController:[[YZMyViewController alloc] init]];
        [items addObject:setItem];
    }
    
    tbc.tabBarItems = items;
    self.tabController = tbc;
    tbc.tabBar.translucent = NO;
    
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *standardAppearance = [[UITabBarAppearance alloc] init];
        standardAppearance.backgroundColor = [UIColor whiteColor];//根据自己的情况设置
        standardAppearance.shadowColor = [UIColor clearColor];//也可以设置为白色或任何颜色
        UITabBarItemStateAppearance *normal = standardAppearance.stackedLayoutAppearance.normal;
          if (normal) {
              normal.titlePositionAdjustment = UIOffsetMake(0,0);
          }
        tbc.tabBar.standardAppearance = standardAppearance;
    }else{
        [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
        [[UITabBar appearance] setShadowImage:[[UIImage alloc]init]];
        [UITabBar appearance].backgroundColor = [UIColor whiteColor];//根据自己的情况设置
    }
    return tbc;
}

//统计视频/语音通话的使用时间(如果视频通话过程中切换成了语音也按视频统计)
-(void)statisticsUsedTime:(int)seconds isVideo:(BOOL)isVideo {
    if (seconds <= 0) {return;}
    int minutes = (int)seconds / 60 + 1;
    [YChatNetworkEngine requestAppUsedInfoByAppId:self.appId UserId:[[YChatSettingStore sharedInstance]getUserId] AudioMinutes:(isVideo == true?0:minutes) VideoMinutes:(isVideo == true ? minutes : 0) Source:@"ios" completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                NSLog(@"同步成功");
            }
        }
    }];
}

@end
