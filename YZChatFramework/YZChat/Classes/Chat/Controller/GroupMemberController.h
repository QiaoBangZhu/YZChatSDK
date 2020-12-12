//
//  GroupMemberController.h
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//
/**
*  本文件实现了群成员管理视图，在管理员进行群内人员管理时提供UI
*
*  本类依赖于腾讯云 TUIKit和IMSDK 实现
*
*/
#import <UIKit/UIKit.h>
#import "TUIGroupMemberController.h"
#import "TUIContactSelectController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "Toast/Toast.h"
#import "THelper.h"
#import <ImSDKForiOS/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupMemberController : UIViewController<TGroupMemberControllerDelegagte>
@property (nonatomic, strong) NSString *groupId;

@end

NS_ASSUME_NONNULL_END
