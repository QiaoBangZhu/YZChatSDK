//
//  YZChatNetworkEngine.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZ_Precompile.h"

/**通用上传接口*/
DEF_URL(commonUploadFile, api/upload);
/**发送验证码(用户相关)*/
DEF_URL(userSmsCode, user/sendSms)
/**用户注册*/
DEF_URL(userReg, user/register)
/**修改信息*/
DEF_URL(modifyInfo, user/update)
/**修改密码*/
DEF_URL(modifyPassword, user/updatePwd)
/**登录*/
DEF_URL(login, user/login)
/**重置密码*/
DEF_URL(resetPassword, user/resetPwd)
/**获取用户信息*/
DEF_URL(fetchUserInfo, user/getUserByUserId)

typedef NS_ENUM(NSInteger, YZSmscodeType)
{
    YZSmscodeTypeRegUser = 1,
    YZSmscodeTypeModifyPassword = 2,
    YZSmscodeTypeModifyPhone = 3,
};

typedef void (^YZChatURLRequstCompletionBlock)( NSDictionary * result, NSError *error);

@interface YZChatNetworkEngine : NSObject


//获取验证码 type 1,注册，2，修改密码，3修改手机号
+(NSURLSessionDataTask*)requestUserCodeWithMobile:(NSString*)mobile
                                   type:(YZSmscodeType)type
                                 completion:(YZChatURLRequstCompletionBlock)block;

//注册
+ (NSURLSessionDataTask*)requestUserRegisterWithMobile:(NSString *)mobile
                                             smsCode:(NSString *)smsCode
                                              passWord:(NSString *)password
                                            completion:(YZChatURLRequstCompletionBlock)block;
//登录
+(NSURLSessionDataTask*)requestUserLoginMobile:(NSString*)loginMobile
                                        loginPwd:(NSString*)password
                                      completion:(YZChatURLRequstCompletionBlock)block;


//获取登录信息
+(NSURLSessionDataTask *)requestUserInfoWithUserId:(NSString *)userId
                                           completion:(YZChatURLRequstCompletionBlock)block;


//修改密码
+ (NSURLSessionDataTask *)requestModifyPasswordWithUserId:(NSString*)userId
                                                   oldPwd:(NSString *)oldPassword
                                              newPassword:(NSString *)newPassword
                                               completion:
                                                (YZChatURLRequstCompletionBlock)block;

//重置密码
+ (NSURLSessionDataTask *)requestResetPasswordWithMobile:(NSString*)mobile
                                                   smsCode:(NSString *)code
                                              password:(NSString *)newPassword
                                               completion:
                                                (YZChatURLRequstCompletionBlock)block;


@end

