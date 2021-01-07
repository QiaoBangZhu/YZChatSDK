//
//  YGroupMembersTableViewCell.m
//  YChat
//
//  Created by magic on 2020/12/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YGroupMembersTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIKit.h"
#import <ImSDKForiOS/ImSDK.h>
#import <MMLayout/UIView+MMLayout.h>

@interface YGroupMembersTableViewCell()
@property (nonatomic, strong)UIImageView *avatar;
@property (nonatomic, strong)UILabel     *nameLabel;

@end

@implementation YGroupMembersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor whiteColor];
        _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatar.layer.cornerRadius = 15;
        _avatar.layer.masksToBounds = true;
        [self addSubview:_avatar];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_nameLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(UserModel *)model
{
    _avatar.image = DefaultAvatarImage;
    [[V2TIMManager sharedInstance] getUsersInfo:@[model.userId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        if (infoList.firstObject) {
            [self.avatar sd_setImageWithURL:[NSURL URLWithString:infoList.firstObject.faceURL] placeholderImage:DefaultAvatarImage];
        };
    } fail:nil];
    if (model.name.length) {
        _nameLabel.text = model.name;
    } else {
        _nameLabel.text = model.userId;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _avatar.mm_width(30).mm_height(30).mm_left(12).mm__centerY(self.mm_h / 2);
    _nameLabel.mm_height(self.mm_h).mm_left(_avatar.mm_maxX + 8).mm_flexToRight(0);
}

@end
