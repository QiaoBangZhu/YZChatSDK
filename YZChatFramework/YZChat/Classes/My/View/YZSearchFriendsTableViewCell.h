//
//  SearchFriendsTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "TCommonContactCellData.h"
#import "TCommonCell.h"
#import "YUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZSearchFriendsTableViewCell : TCommonTableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *subTitleLabel;

@property (readonly) YUserInfo *contactData;

- (void)fillWithData:(YUserInfo *)contactData;

@end

NS_ASSUME_NONNULL_END
