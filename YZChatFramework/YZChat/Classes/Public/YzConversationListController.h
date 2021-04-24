//
//  YzConversationListController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/9.
//

#import <UIKit/UIKit.h>

#import "YzIMKitAgent.h"

@class V2TIMConversation;

NS_ASSUME_NONNULL_BEGIN

@protocol YzConversationListControllerDelegate <NSObject>
@optional

/**
 * 点击某个会话cell
 *
 * @param conversation 会话信息
 * @param indexPath 下标
 *
 * @return 如果返回YES，则内部不做任何处理
 */
- (BOOL)didSelectConversation:(V2TIMConversation *)conversation indexPath:(NSIndexPath *)indexPath;

@end

@interface YzConversationListController : UIViewController

@property(nullable, nonatomic, weak) id<YzConversationListControllerDelegate> delegate;

- (instancetype)initWithChatType:(YzChatType)chatType NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
