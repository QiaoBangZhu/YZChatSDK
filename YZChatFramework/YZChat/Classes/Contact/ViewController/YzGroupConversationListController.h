//
//  YzGroupConversationListController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/21.
//

#import "YzCommonTableViewController.h"

#import "YzCustomMsg.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzGroupConversationListController : YzCommonTableViewController

- (instancetype)initWithCustomMessage:(YzCustomMsg *)customMessage;

@end

NS_ASSUME_NONNULL_END
