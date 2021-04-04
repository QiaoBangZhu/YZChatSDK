//
//  YZChatSettingStore.m
//  YZChat_Example
//
//  Created by magic on 2021/3/26.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import "YZChatSettingStore.h"
#import "YZUserInfoModel.h"

static NSString * const kYZUserInfo = @"kYZUserInfo";

@interface YZChatSettingStore() {
    YZUserInfoModel *_userInfo;
}

@end

@implementation YZChatSettingStore
DEF_SINGLETON(YZChatSettingStore);

- (instancetype)init
{
    self = [super init];
    if (self) {}
    return self;
}

- (NSString *)mobile {
    return self.userInfo.mobile;
}

- (NSString*)nickName {
    return self.userInfo.nickName;
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

- (void)saveUserInfo:(YZUserInfoModel *)userInfo{
    _userInfo = userInfo;
    NSError *error = nil;
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:userInfo requiringSecureCoding: YES error:&error];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:data forKey:kYZUserInfo];
    [userDefault synchronize];
}

- (YZUserInfoModel *)userInfo {
    if(!_userInfo){
        NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:kYZUserInfo];
        NSError *error = nil;
        _userInfo = [NSKeyedUnarchiver unarchivedObjectOfClass:[YZUserInfoModel class] fromData:data error:&error];
        if (error) {
            _userInfo = [[YZUserInfoModel alloc] init];
        }
    }
    return  _userInfo;
}

@end
