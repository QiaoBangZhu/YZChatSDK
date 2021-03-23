//
//  TransferGrpOwnerCell.m
//  YChat
//
//  Created by magic on 2020/10/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZTransferGrpOwnerCell.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import <Masonry/Masonry.h>

@implementation TransferGrpOwnerCell

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
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        [self.contentView addSubview:self.titleLabel];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.centerY.equalTo(@0);
            make.size.equalTo(@50);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.left.equalTo(self.avatarView.mas_right).offset(10);
        }];
        
        if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = 25;
        } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
        }
    }
    return self;
}

- (void)fillWithData:(TGroupMemberCellData *)data
{
    if (data.avatarImage) {
        self.avatarView.image = data.avatarImage;
    } else {
        self.avatarView.image = DefaultAvatarImage;
        [[V2TIMManager sharedInstance] getUsersInfo:@[data.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            if (infoList.firstObject) {
                [self.avatarView sd_setImageWithURL:[NSURL URLWithString:infoList.firstObject.faceURL] placeholderImage:DefaultAvatarImage];
            };
        } fail:nil];
    }

    if (data.name.length) {
        self.titleLabel.text = data.name;
    } else {
        self.titleLabel.text = data.identifier;
    }
}


@end
