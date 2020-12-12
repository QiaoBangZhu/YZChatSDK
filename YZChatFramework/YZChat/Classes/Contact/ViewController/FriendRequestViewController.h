//
//  FriendRequestViewController.h
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//
/**
 *  本文件实现了添加好友时的视图，在您想要添加其他用户为好友时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>
#import <ImSDKForiOS/TIMFriendshipManager.h>
//#import "TIMFriendshipManager.h"
#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestViewController : UIViewController
@property V2TIMUserFullInfo *profile;
@property (nonatomic, strong)UserInfo * user;
@end

NS_ASSUME_NONNULL_END
