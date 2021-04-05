//
//  YChatSettingStore.m
//  YChat
//
//  Created by magic on 2020/9/24.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YChatSettingStore.h"
#import "YUserInfo.h"
#import "CommonConstant.h"
#import "YzFileManager.h"

static NSString * const kUserInfo = @"kYZUserInfo";

@interface YChatSettingStore() {
    YUserInfo * _userInfo;
}

@end
@implementation YChatSettingStore
DEF_SINGLETON(YChatSettingStore);

- (NSString *)getMobile {
    return self.userInfo.mobile;
}

- (NSString*)getNickName {
    return self.userInfo.nickName;
}

- (NSInteger)getFunctionPerm {
    return self.userInfo.functionPerm;
}

- (NSString *)getUserId{
    return self.userInfo.userId;
}

- (NSString *)getUserSign {
    return self.userInfo.userSign;
}

- (NSString *)getAuthToken {
    return self.userInfo.token;
}

- (NSString *)getAppId {
    return self.userInfo.companyId;
}

- (BOOL)isLogin{
    if ([[self getUserSign] length] > 0 && [[self getUserId] length] > 0 && [self getAuthToken] > 0) {
        return YES;
    }
    return NO;
}

- (void)saveUserInfo:(YUserInfo *)userInfo{
    _userInfo = userInfo;
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:userInfo requiringSecureCoding: YES error: nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:kUserInfo];
    [userDefaults setObject:userInfo.userSign forKey:@"YUserSign"];
    [userDefaults setObject:userInfo.userId  forKey:@"YUserId"];
    [userDefaults synchronize];
    [self p_YZSync];
}

// 元讯同步
-(void)p_YZSync {
    Class cls = NSClassFromString(@"AbstractUserModel");
    if (!cls) return;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *kAbstractUser = @"kAbstractUser";
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey: kAbstractUser];
    NSError *error = nil;
    id user = [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:data error:&error];
    if (!error) {
        [user setValue:_userInfo.token forKey:@"token"];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding: YES error: nil];
        [userDefaults setObject:data forKey:kAbstractUser];
    }
    [userDefaults synchronize];
}

- (YUserInfo *)userInfo {
    if(!_userInfo){
        NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInfo];
        NSError *error = nil;
        _userInfo = [NSKeyedUnarchiver unarchivedObjectOfClass:[YUserInfo class] fromData:data error:&error];
        if (error) {
            _userInfo = [[YUserInfo alloc] init];
        }
    }
    return  _userInfo;
}

- (void)logout {
    _userInfo = [[YUserInfo alloc] init];
    [YzFileManager removeItemAtPath:kHeadImageContentFile error:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey: kUserInfo];
    [userDefaults setObject:@"" forKey:@"YUserSign"];
    [userDefaults setObject:@"" forKey:@"YUserId"];
    [userDefaults setObject:@"" forKey:@"yapplicationNameForUserAgent"];
    [userDefaults synchronize];
}

@end
