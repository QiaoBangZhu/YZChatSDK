//
//  FriendListTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "QMUITableViewCell.h"
#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendListTableViewCell : QMUITableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *subTitleLabel;

@property (readonly) UserInfo *contactData;

- (void)fillWithData:(UserInfo *)contactData;

@end

NS_ASSUME_NONNULL_END
