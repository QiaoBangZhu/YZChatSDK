//
//  YZCardMsgView.h
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCell.h"

#import "YZCardMsgData.h"
#import "YzCustomMessageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZCardMsgView : YzCustomMessageView

@property UILabel     *titleLabel;
@property UILabel     *desLabel;
@property UIImageView *logoImageView;

@property YZCardMsgData *messageData;
- (void)fillWithData:(YZCardMsgData *)data;

@end

NS_ASSUME_NONNULL_END
