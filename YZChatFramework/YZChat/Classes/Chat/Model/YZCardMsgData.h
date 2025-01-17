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
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *link;

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                         logo:(NSString *)logo
                         link:(NSString *)link;

@end

NS_ASSUME_NONNULL_END
