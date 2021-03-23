//
//  YUIGroupConversationListController.h
//  YChat
//
//  Created by magic on 2020/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIGroupConversationListController.h"
#import "YzCustomMsg.h"

NS_ASSUME_NONNULL_BEGIN

@interface YUIGroupConversationListController : TUIGroupConversationListController
@property (nonatomic, assign)BOOL isFromOtherApp;
@property (nonatomic, strong)YzCustomMsg * customMsg;

@end

NS_ASSUME_NONNULL_END
