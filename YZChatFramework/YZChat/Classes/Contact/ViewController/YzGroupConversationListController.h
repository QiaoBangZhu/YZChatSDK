//
//  YzGroupConversationListController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/21.
//

#import "YzCommonTableViewController.h"

#import "YzCustomMessageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzGroupConversationListController : YzCommonTableViewController

- (instancetype)initWithCustomMessage:(YzCustomMessageData *)customMessage;

@end

NS_ASSUME_NONNULL_END
