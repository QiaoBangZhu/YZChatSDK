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
#import <FCFileManager/FCFileManager.h>

@interface YChatSettingStore() {
    NSUserDefaults* _userDefault;
    YUserInfo * _userInfo;
}

@end
@implementation YChatSettingStore
DEF_SINGLETON(YChatSettingStore);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userDefault = [NSUserDefaults standardUserDefaults];
        _userInfo = [[YUserInfo alloc]init];
    }
    return self;
}

- (NSString *)getMobile {
    return _userInfo.mobile;
}

- (NSString*)getNickName {
    return _userInfo.nickName;
}

- (NSInteger)getfunctionPerm {
    return _userInfo.functionPerm;
}

- (NSString *)getUserId{
    return _userInfo.userId;
}

- (NSString *)getUserSign {
    return _userInfo.userSign;
}

- (NSString *)getAuthToken {
    return _userInfo.token;
}

- (NSString *)getAppId {
    return _userInfo.companyId;
}



- (BOOL)isLogin{
    if ([[self getUserSign] length] > 0 && [[self getUserId] length] > 0 && [self getAuthToken] > 0) {
        return YES;
    }
    return NO;
}

- (void)saveUserInfo:(YUserInfo *)userInfo{
    _userInfo = userInfo;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
    [_userDefault setObject:data forKey:@"userInfo"];
    [_userDefault setObject:userInfo.userSign forKey:@"YUserSign"];
    [_userDefault setObject:userInfo.userId  forKey:@"YUserId"];
    [_userDefault synchronize];
}

- (YUserInfo *)getUserInfo{
    if([_userInfo.userId length]){
        return _userInfo;
    }
    NSData* data = [_userDefault objectForKey:@"userInfo"];
    _userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!_userInfo) {
        _userInfo = [[YUserInfo alloc] init];
    }
    return _userInfo;
}

- (void)logout {
      YUserInfo *userInfo = [[YUserInfo alloc] init];
      _userInfo = userInfo;
      [FCFileManager removeItemAtPath:kHeadImageContentFile error:nil];
      NSData *archiveUserInfo = [NSKeyedArchiver archivedDataWithRootObject:_userInfo];
      [_userDefault setObject:archiveUserInfo forKey:@"userInfo"];
      [_userDefault setObject:@"" forKey:@"YUserSign"];
      [_userDefault setObject:@"" forKey:@"YUserId"];
      [_userDefault setObject:@"" forKey:@"applicationNameForUserAgent"];
}


@end
