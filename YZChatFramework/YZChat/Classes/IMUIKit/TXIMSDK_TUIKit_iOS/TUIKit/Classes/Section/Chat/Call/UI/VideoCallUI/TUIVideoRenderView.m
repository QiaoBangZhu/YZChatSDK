//
//  TUIVideoRenderView.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/8.
//

#import "TUIVideoRenderView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import <Masonry/Masonry.h>
#import "NSBundle+YZBundle.h"

@interface TUIVideoRenderView ()

@property (nonatomic, strong)UIImageView * avatarImageView;
@property (nonatomic, strong)UILabel     * nicknameLabel;

@end


@implementation TUIVideoRenderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nicknameLabel];
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
    }
    return _avatarImageView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc]init];
        _nicknameLabel.font = [UIFont systemFontOfSize:14];
        _nicknameLabel.textColor = [UIColor whiteColor];
        _nicknameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nicknameLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self makeConstraint];
}

- (void)fillWithData:(CallUserModel *)user layout:(CallViewLayoutStyle)style {
    self.layout = style;
    BOOL noModel = user.userId.length == 0;
    if (!noModel) {
        self.nicknameLabel.text = user.name;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"defaultAvatarImage"] options:SDWebImageHighPriority];
        self.avatarImageView.hidden = user.isVideoAvaliable;
        self.nicknameLabel.hidden = user.isVideoAvaliable;
    }
}

- (void)setUserModel:(CallUserModel *)userModel {
    _userModel = userModel;
    if (userModel) {
        self.nicknameLabel.text = userModel.name;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userModel.avatar] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageHighPriority];
        self.avatarImageView.hidden = userModel.isVideoAvaliable;
        self.nicknameLabel.hidden = userModel.isVideoAvaliable;
    }
}

- (void)setLayout:(CallViewLayoutStyle)layout {
    _layout = layout;
    [self makeConstraint];
}

- (void)makeConstraint {
    CGFloat width = 64;
    if (self.layout == CallViewLayoutStyleSmall) {
        width = 64;
    }
    if (self.layout == CallViewLayoutStyleBig) {
        width = 100;
    }
    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(width));
        make.center.equalTo(@0);
    }];
    
    [self.nicknameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
    }];
}

@end
