//
//  TUIAudioCallUserCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/7.
//

#import "TUIAudioCallUserCell.h"
#import <Masonry/Masonry.h>
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"


@implementation TUIAudioCallUserCell
{
    UIImageView *_cellImgView;
    UILabel *_cellUserLabel;
    UILabel *_cellAlertLabel;
    UIProgressView *_volumeProgress;
    UIActivityIndicatorView *_actvity;
    UILabel  *_pointLabel;
    UIImageView * _shadowImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
        
//        _cellImgView.layer.masksToBounds = YES;
//        _cellImgView.layer.cornerRadius = _cellImgView.frame.size.height/2;
    }
    return self;
}

- (void)setupViews {
    _cellImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_cellImgView];
    
    _cellUserLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _cellUserLabel.backgroundColor = [UIColor blackColor];
    _cellUserLabel.textColor = [UIColor whiteColor];
//    _cellUserLabel.alpha = 0.7;
    _cellUserLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_cellUserLabel];
    
    _cellAlertLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _cellAlertLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    _cellAlertLabel.text = @"呼叫中";
    _cellAlertLabel.font = [UIFont systemFontOfSize:14];
    _cellAlertLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_cellAlertLabel];
    
//    _volumeProgress = [[UIProgressView alloc] initWithFrame:CGRectZero];
//    [self addSubview:_volumeProgress];
    
    _shadowImageView = [[UIImageView alloc]init];
    _shadowImageView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    _shadowImageView.hidden = NO;
    [_cellImgView addSubview:_shadowImageView];
    
    _pointLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _pointLabel.textColor = [UIColor whiteColor];
    _pointLabel.textAlignment = NSTextAlignmentCenter;
    _pointLabel.text = @"...";
    _pointLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    _pointLabel.hidden = YES;
    [self.contentView addSubview:_pointLabel];
}

- (void)defaultLayout
{
    [_cellImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.height.equalTo(_cellImgView.mas_width);
    }];
    
    [_shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    [_pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_cellImgView.mas_centerX);
        make.centerY.equalTo(_cellImgView.mas_centerY);
    }];

    [_cellUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@20);
    }];

    [_cellAlertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(_cellUserLabel.mas_bottom).offset(4);
    }];
    
//    _cellImgView.mm_width(self.mm_h).mm_height(self.mm_h).mm_left(0);
//    _cellUserLabel.mm_width(self.mm_h).mm_height(24).mm_left(_cellImgView.mm_x).mm_flexToRight(_cellImgView.mm_r).mm_bottom(_cellImgView.mm_b);
//    _volumeProgress.mm_width(self.mm_h).mm_height(4).mm_left(_cellImgView.mm_x).mm_flexToRight(_cellImgView.mm_r).mm_bottom(_cellImgView.mm_b);

}

- (void)fillWithData:(CallUserModel *)model isCurSponsor:(BOOL)iscurSponsor count: (NSInteger)count {
    [self defaultLayout];
    [_cellImgView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
    _cellUserLabel.text = model.name.length > 0 ? model.name : model.userId;
//    _volumeProgress.progress = model.volume;
    BOOL noModel = (model.userId.length == 0);
    [_cellImgView setHidden:noModel];
    [_cellUserLabel setHidden:noModel];
    [_cellAlertLabel setHidden:model.isEnter];
    [_pointLabel setHidden:model.isEnter];
    [_shadowImageView setHidden:model.isEnter];
    
//    [_volumeProgress setHidden:(noModel || !model.isEnter)];
    
    if (iscurSponsor) {
        _cellUserLabel.hidden =  YES;
        _cellAlertLabel.hidden = YES;
        _pointLabel.hidden =  YES;
        _shadowImageView.hidden = YES;
    
        _cellImgView.layer.masksToBounds = YES;
        _cellImgView.layer.cornerRadius = 15;
        
        
    }else {
        if (count == 1) {
            _cellImgView.layer.masksToBounds = YES;
            _cellImgView.layer.cornerRadius = 80;
        }else {
            _cellImgView.layer.masksToBounds = YES;
            _cellImgView.layer.cornerRadius = 32;
        }
        
    }
}


@end
