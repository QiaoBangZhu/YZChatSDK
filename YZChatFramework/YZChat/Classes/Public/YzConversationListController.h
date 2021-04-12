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

- (void)didSelectConversation:(V2TIMConversation *)conversation indexPath:(NSIndexPath *)indexPath;

@end

@interface YzConversationListController : UIViewController

@property(nullable, nonatomic, weak) id<YzConversationListControllerDelegate> delegate;

- (instancetype)initWithChatType:(YzChatType)chatType;

@end

NS_ASSUME_NONNULL_END
