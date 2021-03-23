//
//  TUISelectedUserCollectionViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUIVideoCallUserCell.h"
#import "THeader.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <Masonry/Masonry.h>
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"

@interface TUIVideoCallUserCell()
@property(nonatomic, strong)UILabel     * nameLabel;
@property(nonatomic, strong)UIImageView * avatar;
@property(nonatomic, strong)UILabel     * callingTipsLabel;
@property(nonatomic, strong)UIView      * callingBgContentView;
@end

@implementation TUIVideoCallUserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.callingBgContentView];
    [self.callingBgContentView addSubview:self.nameLabel];
    [self.callingBgContentView addSubview:self.avatar];
    [self.callingBgContentView addSubview:self.callingTipsLabel];
    self.callingBgContentView.frame = self.bounds;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.bottom.equalTo(@-12);
        make.right.equalTo(@-12);
    }];
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.size.equalTo(@64);
    }];
    
    [self.callingTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];
}

- (void)fillWithData:(CallUserModel *)model renderView:(TUIVideoRenderView *)renderView curState:(VideoCallState )state {
    BOOL noModel = (model.userId.length == 0);
    if (!noModel) {
        if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
            if (renderView) {
                if (![renderView.superview isEqual:self]) {
                    [renderView removeFromSuperview];
                    renderView.frame = self.bounds;
                    [self addSubview:renderView];
                }
                renderView.userModel = model;
                self.callingBgContentView.hidden = model.isVideoAvaliable;
                renderView.hidden = !model.isVideoAvaliable;
            } else {
                NSLog(@"renderView error");
                self.callingBgContentView.hidden = NO;
            }
            self.nameLabel.text = model.name;
            [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
            self.avatar.layer.cornerRadius = 32;
            [self.avatar.layer setMasksToBounds:YES];
            
        }else {
            self.callingBgContentView.hidden = model.isVideoAvaliable;
        }
    }
}

#pragma mark -- private by magic

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc]init];
    }
    return _avatar;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    return _nameLabel;
}

- (UILabel *)callingTipsLabel {
    if (!_callingTipsLabel) {
        _callingTipsLabel = [[UILabel alloc]init];
        _callingTipsLabel.text = @"呼叫中";
        _callingTipsLabel.font = [UIFont systemFontOfSize:12];
        _callingTipsLabel.textColor = [UIColor whiteColor];
    }
    return _callingTipsLabel;
}

- (UIView *)callingBgContentView {
    if (!_callingBgContentView) {
        _callingBgContentView = [[UIView alloc]initWithFrame:self.bounds];
        _callingBgContentView.backgroundColor = [UIColor blackColor];
        _callingBgContentView.hidden = YES;
    }
    return _callingBgContentView;
}

@end
