//
//  YzInternalConversationListController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/15.
//

#import "YzConversationListController.h"
#import "YzCommonViewController.h"

@class V2TIMConversation;

NS_ASSUME_NONNULL_BEGIN

@protocol YzInternalConversationListControllerDelegate <NSObject>
@optional

- (void)onTitleChanged:(NSString *)title;
- (void)didSelectConversation:(V2TIMConversation *)conversation indexPath:(NSIndexPath *)indexPath;

@end

@interface YzInternalConversationListController : YzCommonViewController

@property(nullable, nonatomic, weak) id<YzInternalConversationListControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isNeedCloseBarButton;

- (instancetype)initWithChatType:(YzChatType)chatType;

@end

NS_ASSUME_NONNULL_END
