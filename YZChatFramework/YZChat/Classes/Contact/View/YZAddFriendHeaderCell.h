//
//  YZAddFriendHeaderCell.h
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "CIGAMKit.h"
#import "YZProfileCardCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddFriendHeaderCellDelegate <NSObject>
@optional
- (void)addFriendWords:(NSString *)words;
- (void)didTapOnAvatar:(ProfileCardCellData*)data;

@end

@interface YZAddFriendHeaderCell : TCommonTableViewCell
@property (nonatomic, strong) UIImageView  *avatar;
@property (nonatomic, strong) UILabel      *name;
@property (nonatomic, strong) UILabel      *mobile;
@property (nonatomic, strong) CIGAMTextView *textView;
@property (nonatomic, strong) ProfileCardCellData *cardData;
@property (nonatomic, assign) id<AddFriendHeaderCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
