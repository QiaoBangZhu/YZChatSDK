//
//  YZFriendListTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "CIGAMKit.h"
#import "YUserInfo.h"

#define kReuseIdentifier_FriendListTableViewCell @"ReuseIdentifier_FriendListTableViewCell"

NS_ASSUME_NONNULL_BEGIN

@interface YZFriendListTableViewCell : CIGAMTableViewCell

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong, readonly) YUserInfo *contactData;

- (void)fillWithData:(YUserInfo *)contactData;

@end

NS_ASSUME_NONNULL_END
