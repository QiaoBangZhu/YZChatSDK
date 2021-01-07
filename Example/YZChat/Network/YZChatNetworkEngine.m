//
//  YZChatNetworkEngine.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZChatNetworkEngine.h"
#import "YZ_Precompile.h"
#import "YZChatURLRequest.h"
#import "YZChatRequestBuilder.h"
#import "YZChatRequestMan.h"

@implementation YZChatNetworkEngine

+ (NSURLSessionDataTask *)requestUserCodeWithMobile:(NSString *)mobile type:(YZSmscodeType )type completion:(YZChatURLRequstCompletionBlock)block {
    
    NSDictionary* params = @{@"mobile":mobile,
                             @"code":@(type)};
    YZChatURLRequest* request = [YZChatRequestBuilder requestWithURL:userSmsCode andParams:params];
    return [YZChatRequestMan postRequest:request completion:block];
}

//注册
+ (NSURLSessionDataTask*)requestUserRegisterWithMobile:(NSString *)mobile
                                             smsCode:(NSString *)smsCode
                                              passWord:(NSString *)password
                                            completion:(YZChatURLRequstCompletionBlock)block{
    NSDictionary* params = @{@"mobile":mobile,
                             @"smsCode":smsCode,
                             @"password":password};
    YZChatURLRequest* request = [YZChatRequestBuilder requestWithURL:userReg andParams:params];
    return [YZChatRequestMan postRequest:request completion:block];
}

//登录
+(NSURLSessionDataTask*)requestUserLoginMobile:(NSString*)loginMobile
                                      loginPwd:(NSString*)password
                                    completion:(YZChatURLRequstCompletionBlock)block {
    NSDictionary* params = @{@"mobile":loginMobile,
                             @"password":password};
    YZChatURLRequest* request = [YZChatRequestBuilder requestWithURL:login andParams:params];
    return [YZChatRequestMan postRequest:request completion:block];
}

//获取用户信息
+(NSURLSessionDataTask *)requestUserInfoWithUserId:(NSString *)userId
                                        completion:(YZChatURLRequstCompletionBlock)block {
    NSDictionary* params = @{@"userId":userId};
    YZChatURLRequest* request = [YZChatRequestBuilder requestWithURL:fetchUserInfo andParams:params];
    return [YZChatRequestMan postRequest:request completion:block];
}

//修改密码
+ (NSURLSessionDataTask *)requestModifyPasswordWithUserId:(NSString*)userId
                                                   oldPwd:(NSString *)oldPassword
                                              newPassword:(NSString *)newPassword
                                               completion:
                                            (YZChatURLRequstCompletionBlock)block {
    NSDictionary* params = @{@"userId":userId,
                             @"newPassword": newPassword,
                             @"oldPassword": oldPassword
    };
    YZChatURLRequest* request = [YZChatRequestBuilder requestWithURL:modifyPassword andParams:params];
    return [YZChatRequestMan postRequest:request completion:block];
}

//重置密码
+ (NSURLSessionDataTask *)requestResetPasswordWithMobile:(NSString*)mobile
                                                   smsCode:(NSString *)code
                                              password:(NSString *)password
                                               completion:
                                            (YZChatURLRequstCompletionBlock)block{
    NSDictionary* params = @{@"mobile":mobile,
                             @"password": password,
                             @"smsCode": code
    };
    YZChatURLRequest* request = [YZChatRequestBuilder requestWithURL:resetPassword andParams:params];
    return [YZChatRequestMan postRequest:request completion:block];
}

@end
