//
//  AddressBookTableViewCell.h
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "AddressBookCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddressBookTableViewCell : TCommonTableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *nicknameLabel;
@property UIButton *agreeButton;
@property NSString *identifier;

@property (nonatomic) AddressBookCellData *pendencyData;

- (void)fillWithData:(AddressBookCellData *)pendencyData;

@end

NS_ASSUME_NONNULL_END
