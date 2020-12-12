//
//  YUIBlackListViewController.h
//  YChat
//
//  Created by magic on 2020/10/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIBlackListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】黑名单界面（TUIBlackListController）
 * 【功能说明】负责拉取用户的黑名单信息，并在页面中显示。
 *  界面（Controller）提供了黑名单的展示功能，同时也实现了对用户交互动作的响应。
 *  用户也可点击黑名单中的某位用户，将其移出黑名单或对其发送消息。
 */

@interface YUIBlackListViewController : UIViewController
/**
 *  黑名单界面的视图模型。
 *  负责黑名单数据的拉取、加载等操作。
 */
@property TUIBlackListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
