//
//  TUISelectUserTableViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUISelectMemberCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "TUIKit.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"

@implementation TUISelectMemberCell
{
    UIImageView *_selectedMark;
    UIImageView *_userImg;
    UILabel *_nameLabel;
    UserModel *_userModel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        _selectedMark = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_selectedMark];
        _userImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_userImg];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_nameLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
       
    }
    return self;
}

- (void)fillWithData:(UserModel *)model isSelect:(BOOL)isSelect
{
    _userModel = model;
    _selectedMark.image = isSelect ? [UIImage imageNamed:TUIKitResource(@"add_selected")] : [UIImage imageNamed:TUIKitResource(@"icon_contact_select_pressed")];
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage")];
    _nameLabel.text = model.name;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _selectedMark.mm_width(16).mm_height(16).mm_left(12).mm__centerY(self.mm_h / 2);
    _userImg.mm_width(32).mm_height(32).mm_left(_selectedMark.mm_maxX + 12).mm__centerY(self.mm_h / 2);
    _nameLabel.mm_height(self.mm_h).mm_left(_userImg.mm_maxX + 12).mm_flexToRight(0);
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        _userImg.layer.masksToBounds = YES;
        _userImg.layer.cornerRadius = 16;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        _userImg.layer.masksToBounds = YES;
        _userImg.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
}

@end
