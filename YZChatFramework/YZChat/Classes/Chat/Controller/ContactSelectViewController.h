//
//  ContactSelectViewController.h
//  YChat
//
//  Created by magic on 2020/10/2.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCommonContactSelectCellData.h"
#import "TContactSelectViewModel.h"

typedef void(^ContactSelectFinishBlock)(NSArray<TCommonContactSelectCellData *> * _Nonnull selectArray);

/**
 * 【模块名称】好友选择界面（TUIContactSelectController）
 * 【功能说明】为用户提供好友选择功能，在创建群聊/讨论组时能够快速选择群组成员。
 */

@interface ContactSelectViewController : UIViewController

@property (nonatomic) TContactSelectViewModel *viewModel;

/**
 * 选择结束回调
 */
@property (nonatomic, copy)ContactSelectFinishBlock finishBlock;

/**
 * 最多选择个数
 */
@property NSInteger maxSelectCount;

/**
 * 自定义的数据列表
 */
@property NSArray *sourceIds;

@end

