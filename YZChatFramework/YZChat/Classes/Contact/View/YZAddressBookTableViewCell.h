//
//  YZAddressBookTableViewCell.h
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "YZAddressBookCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZAddressBookTableViewCell : TCommonTableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *nicknameLabel;
@property UIButton *agreeButton;
@property NSString *identifier;

@property (nonatomic) YZAddressBookCellData *pendencyData;

- (void)fillWithData:(YZAddressBookCellData *)pendencyData;

@end

NS_ASSUME_NONNULL_END
