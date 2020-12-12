//
//  TransferGrpOwnerCell.h
//  YChat
//
//  Created by magic on 2020/10/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "QMUITableViewCell.h"
#import "TUIGroupMemberCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransferGrpOwnerCell : QMUITableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;

- (void)fillWithData:(TGroupMemberCellData *)data;


@end

NS_ASSUME_NONNULL_END
