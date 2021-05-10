//
//  YChatNetworkEngine.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YChatNetworkEngine.h"
#import "YChat_Precompile.h"
#import "YChatURLRequest.h"
#import "YChatRequestBuilder.h"
#import "YChatRequestMan.h"
#import "YChatSettingStore.h"

@implementation YChatNetworkEngine

+ (NSURLSessionDataTask *)requestUserCodeWithMobile:(NSString *)mobile type:(SmscodeType )type completion:(YChatURLRequestCompletionBlock)block {
    
    NSDictionary* params = @{@"mobile":mobile,
                             @"code":@(type)};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:userSmsCode andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//注册
+ (NSURLSessionDataTask*)requestUserRegisterWithMobile:(NSString *)mobile
                                             smsCode:(NSString *)smsCode
                                              passWord:(NSString *)password
                                            completion:(YChatURLRequestCompletionBlock)block{
    NSDictionary* params = @{@"mobile":mobile,
                             @"smsCode":smsCode,
                             @"password":password};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:userReg andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//登录
+(NSURLSessionDataTask*)requestUserLoginMobile:(NSString*)loginMobile
                                      loginPwd:(NSString*)password
                                    completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"mobile":loginMobile,
                             @"password":password};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:login andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//获取用户信息
+(NSURLSessionDataTask *)requestUserInfoWithUserId:(NSString *)userId
                                        completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"userId":userId};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchUserInfo andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//修改密码
+ (NSURLSessionDataTask *)requestModifyPasswordWithUserId:(NSString*)userId
                                                   oldPwd:(NSString *)oldPassword
                                              newPassword:(NSString *)newPassword
                                               completion:
                                            (YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"userId":userId,
                             @"newPassword": newPassword,
                             @"oldPassword": oldPassword
    };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:modifyPassword andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//重置密码
+ (NSURLSessionDataTask *)requestResetPasswordWithMobile:(NSString*)mobile
                                                   smsCode:(NSString *)code
                                              password:(NSString *)password
                                               completion:
                                            (YChatURLRequestCompletionBlock)block{
    NSDictionary* params = @{@"mobile":mobile,
                             @"password": password,
                             @"smsCode": code
    };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:resetPassword andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//修改登录的手机号码
+ (NSURLSessionDataTask *)requestChangeMobileWithUserId:(NSString*)userId
                                                 mobile:(NSString*)mobile
                                                 oldMobile:(NSString*)oldmobile
                                                   smsCode:(NSString *)code
                                               completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"userId":userId,
                             @"oldMobile": oldmobile,
                             @"smsCode": code,
                             @"mobile": mobile
     };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:changePhone andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//添加好友时候查询用户列表
+ (NSURLSessionDataTask *)requestUserListWithParam:(NSString *)param
                                        completion:(YChatURLRequestCompletionBlock)block{
      NSDictionary* params = @{@"param":param};
      YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchUserList andParams:params];
      return [YChatRequestMan postRequest:request completion:block];
}

//修改用户信息
+ (NSURLSessionDataTask *)requestUpdateUserInfoWithUserId:(NSString*)userId
                                                avatar:(NSString*)avatar
                                                nickname:(NSString*)nickname
                                                cardNum:(NSString*)cardNum
                                                position:(NSString*)position
                                                emali:(NSString*)email
                                                password:(NSString*)password
                                                signature:(NSString*)signature
                                                     city:(NSString*)city
                                                   gender:(int)gender
                                                completion:
                                                (YChatURLRequestCompletionBlock)block{
    NSDictionary* params = @{@"userId":userId,
                             @"userIcon":avatar,
                             @"nickName": nickname,
                             @"card": cardNum,
                             @"position": position,
                             @"email": email,
                             @"password": password,
                             @"userSignature":signature,
                             @"city":city,
                             @"gender":@(gender)
    };
     YChatURLRequest* request = [YChatRequestBuilder requestWithURL:modifyInfo andParams:params];
     return [YChatRequestMan postRequest:request completion:block];
}

//获取工具箱信息
+ (NSURLSessionDataTask *)requestToolBoxWithUserId:(NSString*)userId
                                        completion:
                                        (YChatURLRequestCompletionBlock)block {
     NSDictionary* params = @{@"userId":userId};
     YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchToolBox andParams:params];
     return [YChatRequestMan postRequest:request completion:block];
}

//创建群组（包含成员）
+ (NSURLSessionDataTask *)requestCreateMembersGroupWithGroupName:(NSString *)name
                                                            type:(NSString *)type
                                                      memberList:(NSMutableArray *)members
                                                    ownerAccount:(NSString *)owner
                                                      completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{
        @"Type": type,
        @"Name": name,
        @"MemberList": members,
        @"Owner_Account": owner,
    };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:createGroup andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}


//{
//  "Name": "TestGroup", // 群名称（必填）
//  "Type": "Public", // 群组类型：Private/Public/ChatRoom(不支持AVChatRoom和BChatRoom)（必填）
//  "MemberList": [ // 初始群成员列表，最多500个（选填）
//       {
//          "Member_Account": "bob", // 成员（必填）
//          "Role": "Admin" // 赋予该成员的身份，目前备选项只有 Admin（选填）
//       },
//       {
//          "Member_Account": "peter"
//       }
//   ]


+ (NSURLSessionDataTask *)requestUpdateGroupInfoWithGroupId:(NSString *)groupId
                                                       name:(NSString *)name
                                               introduction:(NSString *)introduction
                                               notification:(NSString *)notification
                                                  avatarUrl:(NSString *)url
                                                 maxMembers:(NSInteger )count
                                                   joinType:(NSString *)joinType
                                            shutUpAllMember:(BOOL)isShutUp
                                                 completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"GroupId": groupId,
                             @"Name": name,
                             @"Introduction": introduction,
                             @"Notification": notification,
                             @"FaceUrl": url,
                             @"MaxMemberCount": @(count),
                             @"ApplyJoinOption": joinType,
                             @"ShutUpAllMember": (isShutUp == true ? @"On" : @"Off")
    };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:updateGroup andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//解散群组
+ (NSURLSessionDataTask *)requestDismissGroupWithGroupId:(NSString *)groupId
                                              completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"GroupId": groupId};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:dismissGroup andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

//获取群资料
+ (NSURLSessionDataTask *)requestFetchGroupMsgWithGroupIdList:(NSArray *)groupList
                                                   completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"GroupIdList": groupList};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchGroupInfo andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestToolTokenWithUserId:(NSString *)userId
                                            toolCode:(NSString *)toolCode toolName:(NSString *)toolName completion:(YChatURLRequestCompletionBlock)block{
    NSDictionary* params = @{@"userId":userId,@"toolCode": toolCode,@"userName": toolName};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchToolToken andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestCarWebUrlWithBaseUrl:(NSString *)baseUrl
                                              url:(NSString *)url
                                       completion:(YChatURLRequestCompletionBlock)block {
    YChatURLRequest* request = [YChatRequestBuilder requestWithCustumBaseURL:baseUrl URL:url andParams:@{}];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestFriendsInfoByMobile:(NSString *)mobile
                                          completion:(YChatURLRequestCompletionBlock)block {
    
    NSDictionary* params = @{@"paramVal":mobile,
                             @"userId":[YChatSettingStore sharedInstance].getUserId};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchFriendsByMobile andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestFriendsListByMobiles:(NSMutableArray *)mobiles
                                          completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"paramVal":mobiles,
                             @"userId":[YChatSettingStore sharedInstance].getUserId};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchUserListByMobiles andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestAppUsedInfoByAppId:(NSString *)appId
                                            UserId:(NSString *)userId
                                            AudioMinutes:(NSInteger)aminutes
                                            VideoMinutes:(NSInteger)vminutes
                                            Source:(NSString *)deviceSource
                                         completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"appid":appId,
                             @"userId":[YChatSettingStore sharedInstance].getUserId,
                             @"audioMinutes":@(aminutes),
                             @"videoMinutes":@(vminutes),
                             @"createType": deviceSource
    };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchAppUsedInfo andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestSysUserInfoWithAppId:(NSString *)appId
                                               userId:(NSString *)userId
                                             nickName:(NSString *)nickName
                                             userIcon:(NSString *)userIcon
                                               mobile:(NSString *)mobile
                                                 card:(NSString *)card
                                             position:(NSString *)position
                                                email:(NSString *)email
                                         departmentId:(NSString *)departmentId
                                           departName:(NSString *)departName
                                                 city:(NSString *)city
                                        userSignature:(NSString *)userSignature
                                           completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"appid":appId,
                             @"userId":userId,
                             @"nickName":nickName,
                             @"userIcon":userIcon,
                             @"mobile": mobile,
                             @"card": card,
                             @"position":position,
                             @"email": email,
                             @"departmentId": departmentId,
                             @"departName":departName,
                             @"city":city,
                             @"userSignature": userSignature,
    };
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:sysUserInfo andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestToolKey:(NSString*)toolDomain
                                 toolKey:(NSString*)toolKey
                              completion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{@"toolDomain":toolDomain,
                             @"toolKey":toolKey};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:checkToolKey andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestFetchCityListWithCompletion:(YChatURLRequestCompletionBlock)block {
    NSDictionary* params = @{};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchCityList andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

+ (NSURLSessionDataTask *)requestInviteFriendBy:(NSString*)mobile
                                     Completion:(YChatURLRequestCompletionBlock)block{
    NSDictionary* params = @{@"mobile": mobile, @"userId": [YChatSettingStore sharedInstance].getUserId};
    YChatURLRequest* request = [YChatRequestBuilder requestWithURL:fetchInviteFriend andParams:params];
    return [YChatRequestMan postRequest:request completion:block];
}

@end
