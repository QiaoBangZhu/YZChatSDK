//
//  YzChatController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import <UIKit/UIKit.h>

#import "YzCustomMessageView.h"

@class V2TIMConversation;

NS_ASSUME_NONNULL_BEGIN

@interface YzChatInfo : NSObject

/// 会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
@property (nonatomic, copy) NSString *conversationId;
/// 会话展示名称（群组：群名称 >> 群 ID；C2C：对方好友备注 >> 对方昵称 >> 对方的 userID）
@property (nonatomic, copy) NSString *showName;

- (instancetype)initWithConversationId:(NSString *)conversationId
                              showName:(NSString *)showName;

@end

@interface YzChatControllerConfig : NSObject

/**
 *  是否关闭发送图片功能
 *
 *  @default NO
 */
@property (nonatomic, assign) BOOL disableSendPhotoAction;

/**
 *  是否关闭拍照功能
 *
 *  @default NO
 */
@property (nonatomic, assign) BOOL disableCaptureAction;

/**
 *  是否关闭摄像功能
 *
 *  @default NO
 */
@property (nonatomic, assign) BOOL disableVideoRecordAction;

/**
 *  是否关闭发文件功能
 *  
 *  @default NO
 */
@property (nonatomic, assign) BOOL disableSendFileAction;

/**
 *  是否关闭发送位置
 *
 *  @default NO
 */
@property (nonatomic, assign) BOOL disableSendLocationAction;

/**
 *  是否关闭音频电话
 *
 *  @default YES
 */
@property (nonatomic, assign) BOOL disableAudioCall;

/**
 *  是否关闭视频电话
 *
 *  @default YES
 */
@property (nonatomic, assign) BOOL disableVideoCall;

/**
 *  是否关闭聊天面板，只能看聊天记录
 *
 *  @default NO
 */
@property (nonatomic, assign) BOOL disableChatInput;

@end

@protocol YzChatControllerDelegate <NSObject>
@optional

/**
 * 点击头像
 *
 * 默认点击头像是打开联系人资料页
 *
 * @param userId 头像用户id
 * @return 如果返回YES，则内部不做任何处理
 */
- (BOOL)onUserIconClick:(NSString *)userId;

/**
 * 触发了@功能
 *
 * @return 如果返回YES，则内部不做任何处理
 */
- (BOOL)onAtGroupMember;

/**
 *  更新自定义会话消息内容回调
 *
 *  @param customMessageView 所更新的自定义会话消息视图
 */
- (void)updatedCustomMessageView:(YzCustomMessageView *)customMessageView;

/**
 *  点击自定义会话消息内容回调
 *
 *  @param customMessageView 所点击的自定义会话消息视图
 */
- (void)onSelectedCustomMessageView:(YzCustomMessageView *)customMessageView;

@end

@protocol YzChatControllerDataSource <NSObject>

/**
 * 自定义消息二进制数据
 *
 * @param data 自定义消息二进制数据
 * @return 自定义消息
 */
- (YzCustomMessageData * _Nullable)customMessageForData:(NSData *)data;

@end

@interface YzChatController : UIViewController

@property(nullable, nonatomic, weak) id<YzChatControllerDelegate> delegate;
@property(nullable, nonatomic, weak) id<YzChatControllerDataSource> dataSource;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo
                          config:(nullable YzChatControllerConfig *)config NS_DESIGNATED_INITIALIZER;

/**
 * 触发了@功能并且选择完成员
 *
 * @param names 成员姓名列表
 * @param ids 成员id列表
 */
- (void)updateInputTextByNames:(NSArray <NSString *> *)names
                           ids:(NSArray <NSString *> *)ids;

/**
 * 注册自定义消息视图
 *
 * @param viewClass 自定义消息视图类型，需继承自 YzCustomMessageView
 * @param identifier 复用标识
 */
- (void)registerClass:(nullable Class)viewClass forCustomMessageViewReuseIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
