//
//  CommonPendencyCell.m
//  YChat
//
//  Created by magic on 2020/9/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "CommonPendencyCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIColor+ColorExtension.h"

@implementation CommonPendencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self.contentView addSubview:self.avatarView];
    self.avatarView.mm_width(50).mm_height(50).mm__centerY(36).mm_left(12);
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_top(15.5).mm_height(20).mm_width(200);
    
    self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.addWordingLabel];
    self.addWordingLabel.textColor = [UIColor d_systemGrayColor];
    self.addWordingLabel.font = [UIFont systemFontOfSize:15];
    self.addWordingLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY+6).mm_height(15).mm_width(200);

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

- (void)fillWithData:(TCommonPendencyCellData *)pendencyData
{
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addWordingLabel.text = pendencyData.addWording;
    self.avatarView.image = DefaultAvatarImage;
    
    if ([pendencyData.addWording length] == 0 || [pendencyData.addWording isEqualToString:@""] == YES) {
        self.titleLabel.mm_top(26);
    }else {
        self.titleLabel.mm_top(15.5);
    }
    
    if (pendencyData.avatarUrl) {
         [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl placeholderImage:DefaultAvatarImage];
    }
    
    if (pendencyData.application.type == V2TIM_FRIEND_APPLICATION_SEND_OUT) {
        [self.agreeButton setTitle:@"等待接受" forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.backgroundColor = [UIColor clearColor];
        [self.agreeButton setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
    }else {
        if (pendencyData.isAccepted) {
            [self.agreeButton setTitle:@"已同意" forState:UIControlStateNormal];
            self.agreeButton.enabled = NO;
            self.agreeButton.backgroundColor = [UIColor clearColor];
            [self.agreeButton setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
            
        } else {
            [self.agreeButton setTitle:@"同意" forState:UIControlStateNormal];
            self.agreeButton.enabled = YES;
            self.agreeButton.backgroundColor = [UIColor colorWithHex:kCommonBlueTextColor];
            [self.agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }

    self.agreeButton.mm_sizeToFit().mm_width(self.agreeButton.mm_w+20);
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
