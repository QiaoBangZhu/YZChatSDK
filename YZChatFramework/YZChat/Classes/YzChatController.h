//
//  YzChatController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import <UIKit/UIKit.h>

@class V2TIMConversation;

NS_ASSUME_NONNULL_BEGIN

@interface YzChatInfo : NSObject

/// 用户id或者群id
@property (nonatomic, copy) NSString *chatId;
/// 标题
@property (nonatomic, copy) NSString *chatName;
/**
 *  是否是群
 *
 *  @default NO
 */
@property (nonatomic, assign) BOOL isGroup;

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
 * 默认点击头像是打开联系人资料页，如果实现了此方法，则内部不做任何处理
 *
 * @param userId 头像用户id
 */
- (void)onUserIconClick:(NSString *)userId;

/**
 * 触发了@功能
 *
 * @return 如果返回YES，则内部不做任何处理
 */
- (BOOL)onAtGroupMember;

@end

@interface YzChatController : UIViewController

@property(nullable, nonatomic, weak) id<YzChatControllerDelegate> delegate;

- (instancetype)initWithChatInfo:(YzChatInfo *)chatInfo
                          config:(YzChatControllerConfig *)config;

/**
 * 触发了@功能并且选择完成员
 *
 * @param names 成员姓名列表
 * @param ids 成员id列表
 */
- (void)updateInputTextByNames:(NSArray <NSString *> *)names
                           ids:(NSArray <NSString *> *)ids;

@end

NS_ASSUME_NONNULL_END
