//
//  YChatNetworkEngine.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YChat_Precompile.h"

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
/**修改登录手机号码*/
DEF_URL(changePhone, user/updateMobile)
/**用户列表*/
DEF_URL(fetchUserList, user/getUserByParam)
/**工具箱*/
DEF_URL(fetchToolBox, tool/getToolListByUserId)
/**获取某个工具对应的token*/
DEF_URL(fetchToolToken, tool/getToolToken)
/**根据手机号搜索好友*/
DEF_URL(fetchFriendsByMobile, user/getFriendByMobile)
/**数据统计*/
DEF_URL(fetchAppUsedInfo, apply/addApplyStatics)
/**第三方调用元信时候同步用户信息*/
DEF_URL(sysUserInfo, api/sysUser)
/**验证工具的key接口*/
DEF_URL(checkToolKey, api/checkToolToken)

/**根据手机号码获取用户列表
 * 1.这些手机号中和当前用户已经是好友，userType=1
 * 2.这些手机号和当前用户不是好友，但是已经是系统的注册用户了,返回这个用户的userId，用户前端可以加好友 userType=2
 * 3.这些手机号完全不在系统，这时候需要一个邀请的接口 userType=3)
 */
DEF_URL(fetchUserListByMobiles, user/getUserListByMobiles)

DEF_URL(fetchCityList, api/getCityList)

DEF_URL(fetchInviteFriend, user/inviteUser)



//群相关

/**创建群组*/
DEF_URL(creatGroup, group/createGroup)
/**修改群组信息*/
DEF_URL(updateGroup, group/updateGroup)
/**解散群组*/
DEF_URL(dismissGroup, group/destroyGroup)
/**获取用户加入的群组*/
DEF_URL(fetchMyGroups, group/createGroup)
/**添加群组成员*/
DEF_URL(addGroupUser, group/addGroupUser)
/**删除群组成员*/
DEF_URL(deleteGroupUser, group/deleteGroupUser)
/**获取群基础资料*/
DEF_URL(fetchGroupInfo, group/getGroupMsg)

typedef NS_ENUM(NSInteger, SmscodeType)
{
    SmscodeTypeRegUser = 1,
    SmscodeTypeModifyPassword = 2,
    SmscodeTypeModifyPhone = 3,
};

typedef void (^YChatURLRequstCompletionBlock)( NSDictionary * result, NSError *error);

@interface YChatNetworkEngine : NSObject


//获取验证码 type 1,注册，2，修改密码，3修改手机号
+(NSURLSessionDataTask*)requestUserCodeWithMobile:(NSString*)mobile
                                   type:(SmscodeType)type
                                 completion:(YChatURLRequstCompletionBlock)block;

//注册
+ (NSURLSessionDataTask*)requestUserRegisterWithMobile:(NSString *)mobile
                                             smsCode:(NSString *)smsCode
                                              passWord:(NSString *)password
                                            completion:(YChatURLRequstCompletionBlock)block;
//登录
+(NSURLSessionDataTask*)requestUserLoginMobile:(NSString*)loginMobile
                                        loginPwd:(NSString*)password
                                      completion:(YChatURLRequstCompletionBlock)block;


//获取登录信息
+(NSURLSessionDataTask *)requestUserInfoWithUserId:(NSString *)userId
                                           completion:(YChatURLRequstCompletionBlock)block;


//修改密码
+ (NSURLSessionDataTask *)requestModifyPasswordWithUserId:(NSString*)userId
                                                   oldPwd:(NSString *)oldPassword
                                              newPassword:(NSString *)newPassword
                                               completion:
                                                (YChatURLRequstCompletionBlock)block;

//重置密码
+ (NSURLSessionDataTask *)requestResetPasswordWithMobile:(NSString*)mobile
                                                   smsCode:(NSString *)code
                                              password:(NSString *)newPassword
                                               completion:
                                                (YChatURLRequstCompletionBlock)block;
//修改登录的手机号码
+ (NSURLSessionDataTask *)requestChangeMobileWithUserId:(NSString*)userId
                                                 mobile:(NSString*)mobile
                                                 oldMobile:(NSString*)mobile
                                                   smsCode:(NSString *)code
                                               completion:
                                                (YChatURLRequstCompletionBlock)block;
//添加好友时候查询用户列表(手机号/昵称)
+ (NSURLSessionDataTask *)requestUserListWithParam:(NSString*)param
                                         completion:(YChatURLRequstCompletionBlock)block;
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
                                                (YChatURLRequstCompletionBlock)block;

//获取工具箱信息
+ (NSURLSessionDataTask *)requestToolBoxWithUserId:(NSString*)userId
                                            completion:
                                            (YChatURLRequstCompletionBlock)block;

//创建群组(不包含群成员信息)
+ (NSURLSessionDataTask *)requestCreateGroupWithOwnerUserId:(NSString *)userId
                                                  groupType:(NSString *)type
                                                  groupName:(NSString *)name
                                               introduction:(NSString *)introduction
                                               notification:(NSString *)notification
                                                  avatarUrl:(NSString *)url
                                                 maxMembers:(NSInteger )count
                                                   joinType:(NSString *)joinType
                                                 completion:(YChatURLRequstCompletionBlock)block;
//创建群组(包含群成员)
+ (NSURLSessionDataTask *)requestCreateMembersGroupWithGroupName:(NSString *)name
                                                            type:(NSString *)type
                                                      memberList:(NSMutableArray *)members
                                                    ownerAccount:(NSString *)owner
                                                      completion:(YChatURLRequstCompletionBlock)block;


//修改群组信息
+ (NSURLSessionDataTask *)requestUpdateGroupInfoWithGroupId:(NSString *)groupId
                                                       name:(NSString *)name
                                               introduction:(NSString *)introduction
                                               notification:(NSString *)notification
                                                  avatarUrl:(NSString *)url
                                                 maxMembers:(NSInteger )count
                                                   joinType:(NSString *)joinType
                                            shutUpAllMember:(BOOL)isShutUp
                                                 completion:(YChatURLRequstCompletionBlock)block;
//解散群
+ (NSURLSessionDataTask *)requestDismissGroupWithGroupId:(NSString *)groupId
                                         completion:(YChatURLRequstCompletionBlock)block;
//获取用户加入的群组
//+ (NSURLSessionDataTask *)requestUserJoinedGroupsInfo:(NSString *)userId
//                                           limitCount:(NSInteger)count Offset:(NSString *)offset completion:(YChatURLRequstCompletionBlock)block;

//

+ (NSURLSessionDataTask *)requestFetchGroupMsgWithGroupIdList:(NSArray *)groupList
                                                   completion:(YChatURLRequstCompletionBlock)block;

//获取工具箱内某一个工具对应的token
+ (NSURLSessionDataTask *)requestToolTokenWithUserId:(NSString *)userId
                                            toolCode:(NSString *)toolCode toolName:(NSString *)toolName completion:(YChatURLRequstCompletionBlock)block;
//获取打车的url
+ (NSURLSessionTask *)requestCarWebUrlWithBaseUrl:(NSString *)baseUrl
                                              url:(NSString *)url
                                       completion:(YChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask *)requestFriendsInfoByMobile:(NSString *)mobile
                                          completion:(YChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask *)requestFriendsListByMobiles:(NSMutableArray *)mobiles
                                          completion:(YChatURLRequstCompletionBlock)block;

//使用情况统计
+ (NSURLSessionDataTask *)requestAppUsedInfoByAppId:(NSString *)appId
                                            UserId:(NSString *)userId
                                            AudioMinutes:(NSInteger)aminutes
                                            VideoMinutes:(NSInteger)vminutes
                                            Source:(NSString *)deviceSource
                                            completion:(YChatURLRequstCompletionBlock)block;

//第三方用户同步用户信息
+ (NSURLSessionDataTask *)requestSysUserInfoWithAppId:(NSString*)appId
                                               userId:(NSString*)userId
                                             nickName:(NSString*)nickName
                                             userIcon:(NSString*)userIcon
                                               mobile:(NSString*)mobile
                                                 card:(NSString*)card
                                             position:(NSString*)position
                                                email:(NSString*)email
                                         departmentId:(NSString*)departmentId
                                           departName:(NSString*)departName
                                           completion:(YChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask *)requestToolKey:(NSString*)toolDomain
                                 toolKey:(NSString*)toolKey
                              completion:(YChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask *)requestFetchCityListWithCompletion:(YChatURLRequstCompletionBlock)block;

+ (NSURLSessionDataTask *)requestInviteFriendBy:(NSString*)mobile
                                     Completion:(YChatURLRequstCompletionBlock)block;

/**
 
 7，获取群基础资料
 post链接地址:{serviceurl}/group/getGroupMsg
 参数：{
   "GroupIdList": [ // 群组列表（必填）
       "@TGS#1NVTZEAE4",//群组id
       "@TGS#1CXTZEAET"
   ]
 }
 
 */

@end

