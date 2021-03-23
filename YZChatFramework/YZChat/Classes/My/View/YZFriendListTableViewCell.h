//
//  YZFriendListTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "QMUITableViewCell.h"
#import "YUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZFriendListTableViewCell : QMUITableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *subTitleLabel;

@property (readonly) YUserInfo *contactData;

- (void)fillWithData:(YUserInfo *)contactData;

@end

NS_ASSUME_NONNULL_END
