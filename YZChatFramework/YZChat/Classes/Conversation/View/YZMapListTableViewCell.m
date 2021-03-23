//
//  YZMapListTableViewCell.m
//  YChat
//
//  Created by magic on 2020/11/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZMapListTableViewCell.h"
#import "CommonConstant.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "NSBundle+YZBundle.h"

@implementation YZMapListTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
        [self makeConstraint];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    self.checkbox.hidden = !selected;
    
    // Configure the view for the selected state
}

- (void)setupView {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.checkbox];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)makeConstraint {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@15);
        make.right.equalTo(@-16);
    }];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.bottom.equalTo(@-15);
    }];
    [self.checkbox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-16);
        make.centerY.equalTo(@0);
        make.size.equalTo(@16);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.textColor = [UIColor colorWithHex:kCommonGrayTextColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _subTitleLabel;
}

- (UIImageView*)checkbox {
    if (!_checkbox) {
        _checkbox = [[UIImageView alloc]init];
        _checkbox.image = YZChatResource(@"checkmark");
        _checkbox.hidden = YES;
    }
    return _checkbox;
}

@end
