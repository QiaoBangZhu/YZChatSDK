//
//  CardMsgCell.h
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCell.h"
#import "CardMsgCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface CardMsgCell : TUIMessageCell
@property UILabel     *titleLabel;
@property UILabel     *desLabel;
@property UIImageView *logoImageView;

@property CardMsgCellData *msgData;
- (void)fillWithData:(CardMsgCellData *)data;

@end

NS_ASSUME_NONNULL_END
