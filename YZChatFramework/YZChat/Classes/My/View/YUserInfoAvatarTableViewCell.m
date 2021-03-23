//
//  YUserInfoAvatarTableViewCell.m
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUserInfoAvatarTableViewCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "UIColor+TUIDarkMode.h"
#import <Masonry.h>
#import "UIColor+ColorExtension.h"
#import "NSBundle+YZBundle.h"

@implementation AvatarProfileCardCellData

- (instancetype)init {
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return 100;
}

@end

@implementation YUserInfoAvatarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.contentView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    
    CGSize headSize = CGSizeMake(70, 70);
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    //添加点击头像的手势
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAvatar)];
    [_avatar addGestureRecognizer:tapAvatar];
    _avatar.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatar];
    
    //阴影
    _avatar.layer.shadowColor = [UIColor colorWithRed:166/255.0 green:171/255.0 blue:189/255.0 alpha:0.3].CGColor;
    _avatar.layer.shadowOffset = CGSizeMake(3,3);
    _avatar.layer.shadowOpacity = 1;
    _avatar.layer.shadowRadius = 6;
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = headSize.height/2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:20]];
    _name.textAlignment = NSTextAlignmentCenter;
    [_name setTextColor:[UIColor colorWithHex:KCommonBlackColor]];
    [self.contentView addSubview:_name];
    
    _mobile = [[UILabel alloc] init];
    [_mobile setFont:[UIFont systemFontOfSize:12]];
    [_mobile setTextColor:[UIColor colorWithHex:KCommonGraySubTextColor]];
    [self.contentView addSubview:_mobile];
    
    _createGrp = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createGrp  addTarget:self action:@selector(createGrpAction) forControlEvents:UIControlEventTouchUpInside];
    [_createGrp setBackgroundImage:YZChatResource(@"icon_group_add") forState:UIControlStateNormal];
    _createGrp.hidden =  YES;
    [self.contentView addSubview:_createGrp];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)fillWithData:(AvatarProfileCardCellData *)data
{
    [super fillWithData:data];
    self.cardData = data;
    //set data
    @weakify(self)
    
    RAC(_mobile, text) = [RACObserve(data, mobile) takeUntil:self.rac_prepareForReuseSignal];
    [[[RACObserve(data, mobile) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
//        if ([data.mobile length] > 7) {
//            self.mobile.text = [data.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
//        }
        self.mobile.text = data.mobile;
    }];
    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.name.text = x;
    }];
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];
    
    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (data.isShowGrpBtn) {
        self.mobile.hidden = YES;
        self.createGrp.hidden = NO;
    }else {
        self.mobile.hidden = NO;
        self.createGrp.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.cardData.isShowGrpBtn) {
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_avatar.mas_centerX);
            make.top.equalTo(_avatar.mas_bottom).offset(4);
            make.width.equalTo(@100);
        }];
        
        [_createGrp mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.mas_right).offset(12);
            make.centerY.equalTo(_avatar.mas_centerY);
            make.size.equalTo(@88);
        }];
    }else {
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.mas_right).offset(12);
            make.top.equalTo(_avatar.mas_top).offset(4);
            make.right.lessThanOrEqualTo(@-10);
        }];
        
        [_mobile mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.name.mas_left);
            make.top.equalTo(self.name.mas_bottom).offset(8);
            make.right.equalTo(@-10);
        }];
    }
}


- (void)onTapAvatar{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)])
        [_delegate didTapOnAvatar:self];
}

- (void)createGrpAction{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapCreateGrp:)]) {
        [_delegate didTapCreateGrp:self];
    }
}


@end
