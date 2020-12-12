//
//  ChatViewController.h
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUIChatController.h"
#import "TUnReadView.h"

NS_ASSUME_NONNULL_BEGIN
@class TUIMessageCellData;

@interface ChatViewController : UIViewController

@property (nonatomic, strong) TUIConversationCellData *conversationData;
@property (nonatomic, strong) TUnReadView *unRead;
- (void)sendMessage:(TUIMessageCellData*)msg;

@end

NS_ASSUME_NONNULL_END
