//
//  GroupInfoController.h
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//
/**
*  本文件实现了群组信息的展示页面
*
*  您可以通过此界面查看特定群组的信息，包括群名称、群成员、群类型等
*
*  本类依赖于腾讯云 TUIKit和IMSDK 实现
*/

#import <UIKit/UIKit.h>
#import "TUIGroupInfoController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupInfoController : UIViewController
@property (nonatomic, strong) NSString *groupId;

@end

NS_ASSUME_NONNULL_END
