//
//  YzInternalChatController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/17.
//


#import "TUIMessageController.h"
#import "TUIConversationCellData.h"
#import "TUICallModel.h"
#import "TUIInputController.h"

#import "YzCommonViewController.h"
#import "YzChatController.h"
#import "YzCustomMessageCellData.h"
#import "YzCustomMessageCell.h"

//#import "YUIMessageController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzInternalChatController : YzCommonViewController

@property(nullable, nonatomic, weak) id<YzChatControllerDelegate> delegate;
@property(nullable, nonatomic, weak) id<YzChatControllerDataSource> dataSource;
@property(nonatomic, strong, readonly) NSMutableDictionary <NSString *, Class> * registeredCustomMessageClass;

/**
 *  TUIKit 聊天消息控制器
 *  负责消息气泡的展示，同时负责响应用户对于消息气泡的交互，比如：点击消息发送者头像、轻点消息、长按消息等操作。
 *  聊天消息控制器的详细信息请参考 Section\Chat\TUIMessageController.h
 */
@property (nonatomic, strong) TUIMessageController *messageController;

/**
 *  TUIKit 信息输入控制器。
 *  负责接收用户输入，同时显示“+”按钮与语音输入按钮、表情按钮等。
 *  同时 TUIInputController 整合了消息的发送功能，您可以直接使用 TUIInputController 进行消息的输入采集与发送。
 *  信息输入控制器的详细信息请参考 Section\Chat\Input\TUIInputController.h
 */
@property (nonatomic, strong) TUIInputController *inputController;

/**
 *  更多菜单视图数据的数据组
 *  更多菜单视图包括：拍摄、图片、视频、文件。详细信息请参考 Section\Chat\TUIMoreView.h
 */
@property (nonatomic, strong) NSArray<TUIInputMoreCellData *> *moreMenus;

- (instancetype)initWithConversation:(TUIConversationCellData *)conversationData;
- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo config:(YzChatControllerConfig *)config;

/**
 * 注册自定义消息视图
 *
 * @param viewClass 自定义消息视图类型，需继承自 YzCustomMessageView
 * @param identifier 复用标识
 */
- (void)registerClass:(nullable Class)viewClass forCustomMessageViewReuseIdentifier:(NSString *)identifier;

/**
 * 触发了@功能并且选择完成员
 *
 * @param users 成员列表
 */
- (void)updateInputTextByUsers:(NSArray <UserModel *> *)users;

@end

NS_ASSUME_NONNULL_END
