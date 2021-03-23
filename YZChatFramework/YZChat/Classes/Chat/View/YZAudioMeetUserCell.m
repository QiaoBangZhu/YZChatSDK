//
//  YZAudioMeetUserCell.m
//  YChat
//
//  Created by magic on 2020/11/1.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZAudioMeetUserCell.h"
#import <Masonry/Masonry.h>

@implementation YZAudioMeetUserCell {
    UIImageView *_cellImgView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    _cellImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_cellImgView];
}

- (void)defaultLayout
{
    [_cellImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
}

- (void)fillWithData:(CallUserModel *)model {
    [self defaultLayout];
    [_cellImgView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
    
    BOOL noModel = (model.userId.length == 0);
    [_cellImgView setHidden:noModel];
}

#pragma mark -- private by magic
- (void)layoutSubviews {
    [super layoutSubviews];
    _cellImgView.layer.masksToBounds = YES;
    _cellImgView.layer.cornerRadius = 5;
}

@end
