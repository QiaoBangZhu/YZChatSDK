//
//  YzInternalConversationListController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/15.
//

#import "YzConversationListController.h"

#import "YzCommonTableViewController.h"

@class V2TIMConversation;

NS_ASSUME_NONNULL_BEGIN

@interface YzInternalConversationListController : YzCommonTableViewController

@property(nullable, nonatomic, weak) id<YzConversationListControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isNeedCloseBarButton;

- (instancetype)initWithChatType:(YzChatType)chatType;

@end

NS_ASSUME_NONNULL_END
