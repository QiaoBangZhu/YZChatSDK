//
//  ConversationViewController.h
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConversationViewController : YBaseViewController
/**
 *跳转到对应的聊天界面
 */
- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
