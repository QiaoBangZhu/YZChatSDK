//
//  VideoCallUserView.m
//  YChat
//
//  Created by magic on 2020/11/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "VideoCallUserView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@implementation VideoCallUserView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nicknameLabel];
}
//
//- (UIImageView *)avatarImageView {
//    if (!_avatarImageView) {
//        _avatarImageView = [[UIImageView alloc]init];
//    }
//    return _avatarImageView;
//}
//
//- (UILabel *)nicknameLabel {
//    if (!_nicknameLabel) {
//        _nicknameLabel = [[UILabel alloc]init];
//        _nicknameLabel.font = [UIFont systemFontOfSize:14];
//        _nicknameLabel.textColor = [UIColor whiteColor];
//    }
//    return _nicknameLabel;
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self makeConstraint];
//}
//
//- (void)configureData:(CallUserModel *)user layout:(CallViewLayoutStyle)style {
//    self.layout = style;
//    self.nicknameLabel.text = user.name;
//    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"defaultAvatarImage"] options:SDWebImageHighPriority];
//}
//
//- (void)setLayout:(CallViewLayoutStyle)layout {
//    _layout = layout;
//    [self makeConstraint];
//}
//
//- (void)makeConstraint {
//    CGFloat width = 64;
//    if (self.layout == CallViewLayoutStyleSmall) {
//        width = 64;
//    }
//    if (self.layout == CallViewLayoutStyleBig) {
//        width = 100;
//    }
//    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(@(width));
//        make.center.equalTo(@0);
//    }];
//    
//    [self.nicknameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(@0);
//        make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
//    }];
//}


@end
