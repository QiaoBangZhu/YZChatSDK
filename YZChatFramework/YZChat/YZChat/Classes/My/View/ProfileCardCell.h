//
//  ProfileCardCell.h
//  YChat
//
//  Created by magic on 2020/9/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ProfileCardCell;
@protocol ProfileCardDelegate <NSObject>
/**
 *  点击头像的回调委托。
 *  您可以通过该委托实现点击头像显示大图的功能。
 *
 *  @param cell 被点击的头像所在的 cell，
 */
- (void)didTapOnAvatar:(ProfileCardCell *)cell;

- (void)didTapOnQrcode:(ProfileCardCell *)cell;

@end

@interface ProfileCardCellData : TCommonCellData
@property (nonatomic, strong) UIImage  *avatarImage;
@property (nonatomic, strong) NSURL    *avatarUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) NSString *company;
@property BOOL showAccessory;

@end

@interface ProfileCardCell : TCommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UILabel *company;

@property (nonatomic, strong) ProfileCardCellData *cardData;
//实现点击头像的回调委托。
@property (nonatomic, weak)  id<ProfileCardDelegate> delegate;
- (void)fillWithData:(ProfileCardCellData *)data;

@end

NS_ASSUME_NONNULL_END
