//
//  YZCardMsgData.h
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCellData.h"

#import "YzCustomMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZCardMsgData : YzCustomMessageData

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *des;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *link;

@end

NS_ASSUME_NONNULL_END
