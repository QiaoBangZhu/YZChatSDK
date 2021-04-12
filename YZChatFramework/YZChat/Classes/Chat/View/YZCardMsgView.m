//
//  CardMsgCell.m
//  YChat
//
//  Created by magic on 2020/11/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZCardMsgView.h"

#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

#import "NSBundle+YZBundle.h"
#import "UIColor+ColorExtension.h"
#import "CommonConstant.h"

@implementation YZCardMsgView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark: TCell_Nomal_Dark];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [self addSubview:_titleLabel];

        _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _desLabel.font = [UIFont systemFontOfSize:12];
        _desLabel.numberOfLines = 2;
        _desLabel.textColor = [UIColor colorWithHex:KCommonBubbleTextGrayColor];
        [self addSubview:_desLabel];

        _logoImageView = [[UIImageView alloc]init];
        [self addSubview:_logoImageView];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@12);
            make.right.equalTo(@-12);
        }];

        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_left);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
            make.right.equalTo(self.logoImageView.mas_left).offset(-12);
        }];

        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-12);
            make.bottom.lessThanOrEqualTo(@-12);
            make.size.equalTo(@36);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        }];
    }
    return self;
}

- (void)fillWithData:(YZCardMsgData *)data {
    [super fillWithData: data];
    self.messageData = data;
    self.titleLabel.text = data.title;
    self.desLabel.text = data.des;

    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:data.logo] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
}

@end
