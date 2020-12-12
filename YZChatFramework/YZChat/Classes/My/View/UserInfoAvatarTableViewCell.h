//
//  UserInfoAvatarTableViewCell.h
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
@class UserInfoAvatarTableViewCell;
@protocol UserInfoAvatarTableViewCellDelegate <NSObject>
/**
 *  点击头像的回调委托。
 *  您可以通过该委托实现点击头像显示大图的功能。
 *
 *  @param cell 被点击的头像所在的 cell，
 */
-(void) didTapOnAvatar:(UserInfoAvatarTableViewCell *)cell;

@end


@interface AvatarProfileCardCellData : TCommonCellData
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mobile;
@property BOOL showAccessory;

@end

@interface UserInfoAvatarTableViewCell : TCommonTableViewCell

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *mobile;
@property (nonatomic, strong) AvatarProfileCardCellData *cardData;
//实现点击头像的回调委托。
@property (nonatomic, weak)  id<UserInfoAvatarTableViewCellDelegate> delegate;
- (void)fillWithData:(AvatarProfileCardCellData *)data;

@end


