//
//  CardMsgCell.m
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "CardMsgCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

@implementation CardMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [self.container addSubview:_titleLabel];

        _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _desLabel.font = [UIFont systemFontOfSize:12];
        _desLabel.numberOfLines = 2;
        _desLabel.textColor = [UIColor colorWithHex:KCommonBubbleTextGrayColor];
        [self.container addSubview:_desLabel];
        
        _logoImageView = [[UIImageView alloc]init];
        [self.container addSubview:_logoImageView];

    }
    return self;
}

- (void)fillWithData:(CardMsgCellData *)data;
{
    [super fillWithData:data];
    self.msgData = data;
    self.titleLabel.text = data.title;
    self.desLabel.text = data.des;
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:data.logo] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect containFrame = self.container.frame;
    containFrame.size.height -= 15;
    self.container.frame = containFrame;
    
    CGRect readReceiptFrame = self.readReceiptLabel.frame;
    readReceiptFrame.origin.y -= 15;
    self.readReceiptLabel.frame = readReceiptFrame;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@12);
        make.right.equalTo(@-12);
        make.height.lessThanOrEqualTo(@35);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.right.equalTo(self.logoImageView.mas_left).offset(-12);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-12);
        make.bottom.equalTo(@-12);
        make.size.equalTo(@36);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
    }];
}

@end
