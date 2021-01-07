//
//  FriendListTableViewCell.m
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "FriendListTableViewCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import <Masonry/Masonry.h>
#import "UIColor+ColorExtension.h"

@interface FriendListTableViewCell ()

@property UserInfo *contactData;

@end

@implementation FriendListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(50).mm_height(50).mm__centerY(36).mm_left(16);
        if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
        } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
        }

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
     
                
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.subTitleLabel];
        self.subTitleLabel.textColor = [UIColor colorWithHex:KCommonBorderColor];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(12);
            make.top.equalTo(self.avatarView.mas_top).offset(4);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_left);
            make.bottom.equalTo(self.avatarView.mas_bottom).offset(-4);
        }];
    }
    return self;
}

- (void)fillWithData:(UserInfo *)contactData
{
    self.contactData = contactData;

    self.titleLabel.text = contactData.nickName;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:contactData.userIcon] placeholderImage:DefaultAvatarImage];
//    self.subTitleLabel.text = [contactData.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    self.subTitleLabel.text = contactData.mobile;
}

@end
