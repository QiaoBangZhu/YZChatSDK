//
//  YUISelectMemberCell.m
//  YChat
//
//  Created by magic on 2020/10/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUISelectMemberCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"
#import "CommonConstant.h"

@implementation YUISelectMemberCell{
    UIImageView *_selectedMark;
    UIImageView *_userImg;
    UILabel *_nameLabel;
    UserModel *_userModel;
}

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
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        _selectedMark = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_selectedMark];
      
        _userImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_userImg];
        _userImg.layer.cornerRadius = 15;
        _userImg.layer.masksToBounds = true;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_nameLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(UserModel *)model isSelect:(BOOL)isSelect
{
    _userModel = model;
    _selectedMark.image = isSelect ? YZChatResource(@"checkbox_selected") : YZChatResource(@"checkbox_unselect");
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage")];
    _nameLabel.text = model.name;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _selectedMark.mm_width(20).mm_height(20).mm_left(16).mm__centerY(self.mm_h / 2);
    _userImg.mm_width(30).mm_height(30).mm_left(_selectedMark.mm_maxX + 8).mm__centerY(self.mm_h / 2);
    _nameLabel.mm_height(self.mm_h).mm_left(_userImg.mm_maxX + 12).mm_flexToRight(0);
}

@end
