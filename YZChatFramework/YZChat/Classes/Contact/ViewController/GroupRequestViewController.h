//
//  GroupRequestViewController.h
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//
/** 
 *
 * 本文件实现了加入群组时的视图，使得使用者能够对只能群组发送申请加入的请求
 *
 * 本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupRequestViewController : UIViewController
@property V2TIMGroupInfo *groupInfo;
@end

NS_ASSUME_NONNULL_END
