//
//  YUIContactViewController.h
//  YChat
//
//  Created by magic on 2020/10/11.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * 【模块名称】消息列表界面（YUIContactController）
 * 【功能说明】显示消息列表总界面，为用户提供消息管理的操作入口。
 *  消息列表包含了：
 *  1、好友请求管理（TUINewFriendViewController）
 *  2、群聊菜单（TUIGroupConversationListController）
 *  3、黑名单（TUIBlackListController）
 *  4、好友列表
 */

@interface YUIContactViewController : UIViewController

/**
 *  消息列表界面的视图模型
 *  视图模型负责通过 IM SDK 的接口，拉取好友列表、好友请求等信息并将其加载，以便客户端的进一步处理。
 *  详细信息请参考 Section\Contact\ViewModel\TContactViewModel.h
 */
@property (nonatomic)TContactViewModel *viewModel;
@property UITableView *tableView;

@end

NS_ASSUME_NONNULL_END