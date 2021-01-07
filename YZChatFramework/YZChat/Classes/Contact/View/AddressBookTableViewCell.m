//
//  AddressBookTableViewCell.m
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "AddressBookTableViewCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIColor+Foundation.h"
#import "CommonConstant.h"

@implementation AddressBookTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self.contentView addSubview:self.avatarView];
    self.avatarView.mm_width(30).mm_height(30).mm__centerY(27).mm_left(12);
    
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
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_top(6.5).mm_height(20).mm_width(200);
    
    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.nicknameLabel];
    self.nicknameLabel.textColor = [UIColor colorWithHex:KCommonBorderColor];
    self.nicknameLabel.font = [UIFont systemFontOfSize:12];
    self.nicknameLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY+6).mm_height(15).mm_width(200);

    self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.agreeButton.backgroundColor = [UIColor colorWithHex:kCommonBlueTextColor];
    self.accessoryView = self.agreeButton;
    self.agreeButton.layer.masksToBounds = YES;
    self.agreeButton.layer.cornerRadius = 2;
    [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];

    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillWithData:(AddressBookCellData *)pendencyData
{
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    
    self.avatarView.image = DefaultAvatarImage;
    
    if ([pendencyData.nickname length] == 0 || [pendencyData.nickname isEqualToString:@""] == YES) {
        self.titleLabel.mm_top(17);
    }else {
        self.titleLabel.mm_top(6.5);
    }
    if (pendencyData.avatarUrl) {
         [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl placeholderImage:DefaultAvatarImage];
    }
    
    if ([pendencyData.nickname length] > 0 && pendencyData.type != ADDRESSBOOK_APPLICATION_INVITE) {
        self.nicknameLabel.hidden = NO;
        self.nicknameLabel.text = [NSString stringWithFormat:@"昵称:%@",pendencyData.nickname];
    }else {
        self.nicknameLabel.hidden = YES;
    }
    
    if (pendencyData.type == ADDRESSBOOK_APPLICATION_FRIEND) {
        [self.agreeButton setTitle:@"已是好友" forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.backgroundColor = [UIColor clearColor];
        [self.agreeButton setTitleColor:[UIColor colorWithHex:kCommonGrayTextColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        
    }else if (pendencyData.type == ADDRESSBOOK_APPLICATION_INVITE) {
        [self.agreeButton setTitle:@"邀请下载" forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.backgroundColor = [UIColor clearColor];
        [self.agreeButton setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderWidth = 1;
        self.agreeButton.layer.borderColor = [UIColor colorWithHex:kCommonBlueTextColor].CGColor;
    }else if (pendencyData.type == ADDRESSBOOK_APPLICATION_NOT_FRIEND){
        [self.agreeButton setTitle:@"添加好友" forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.backgroundColor = [UIColor colorWithHex:kCommonBlueTextColor];
        [self.agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderWidth = 0;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    if (pendencyData.readyAgree == YES) {
        [self.agreeButton setTitle:@"等待通过" forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.backgroundColor = [UIColor clearColor];
        [self.agreeButton setTitleColor:[UIColor colorWithHex:kCommonGrayTextColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    if ([pendencyData.identifier isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
        self.agreeButton.hidden = YES;
    }else {
        self.agreeButton.hidden = NO;
    }
    
    self.agreeButton.mm_sizeToFit().mm_width(self.agreeButton.mm_w+10).mm_height(26);
}

- (void)agreeClick
{
    if (self.pendencyData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == self.agreeButton)) {
        return NO;
    }
    return YES;
}

@end
