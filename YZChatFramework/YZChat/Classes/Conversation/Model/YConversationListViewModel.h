//
//  YConversationListViewModel.h
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIConversationCell.h"


NS_ASSUME_NONNULL_BEGIN
/**
 * 【模块名称】消息列表视图模型（TConversationListViewModel）
 *
 * 【功能说明】负责实现消息列表中的部分数据处理和业务逻辑
 *  1、视图模型能够通过 IM SDK 提供的接口从服务端拉取会话列表数据，并将数据加载。
 *  2、视图模型能够在用户需要删除会话列表时，同步移除会话列表的数据。
 */

@interface YConversationListViewModel : NSObject
/**
 * 会话数据
 */
@property (strong) NSArray<TUIConversationCellData *> *dataList;

/**
 * 加载会话数据
 */
- (void)loadConversation;

/**
 * 删除会话数据
 */
- (void)removeData:(TUIConversationCellData *)data;

@end

NS_ASSUME_NONNULL_END