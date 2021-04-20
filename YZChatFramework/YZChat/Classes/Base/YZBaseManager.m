//
//  YZBaseManager.m
//  YChat
//
//  Created by magic on 2020/12/12.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZBaseManager.h"
#import "YWorkZoneViewController.h"
#import "YZMyViewController.h"

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

- (YzTabBarViewController *)getMainController {
    return [[YzTabBarViewController alloc] init];
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
