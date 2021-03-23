//
//  YZProfileCardCell.m
//  YChat
//
//  Created by magic on 2020/9/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZProfileCardCell.h"
#import "THeader.h"
#import <Masonry.h>
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "UIColor+TUIDarkMode.h"
#import "UIColor+ColorExtension.h"
#import "NSBundle+YZBundle.h"

@implementation ProfileCardCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarImage = DefaultAvatarImage;
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return 175;
}

@end

@implementation YZProfileCardCell
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
    self.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    UIView* cardbgView = [[UIView alloc]initWithFrame:CGRectMake(0, 66, Screen_Width-32, 130)];
    cardbgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:cardbgView];
    
    //这里设置的是左上和右上角的圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cardbgView.bounds   byRoundingCorners:UIRectCornerTopRight |    UIRectCornerTopLeft    cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = cardbgView.bounds;
    maskLayer.path = maskPath.CGPath;
    cardbgView.layer.mask = maskLayer;
    
    //[cardbgView YZ_SetShadowPathWith:[UIColor colorWithRed:174/255.0 green:174/255.0 blue:192/255.0 alpha:0.13] shadowOpacity:1 shadowRadius:5 shadowSide:YZShadowPathTop shadowPathWidth:3];

    _avatar = [[UIImageView alloc] init];
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    //添加点击头像的手势
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAvatar)];
    [_avatar addGestureRecognizer:tapAvatar];
    _avatar.userInteractionEnabled = YES;
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = 50;
    [self.contentView addSubview:_avatar];
    
    UIButton* signatureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signatureBtn setBackgroundImage:YZChatResource(@"signature_icon") forState:UIControlStateNormal];
    [signatureBtn addTarget:self action:@selector(signatureAction) forControlEvents:UIControlEventTouchUpInside];
    [cardbgView addSubview:signatureBtn];
    [signatureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-24);
        make.top.equalTo(@16);
        make.size.equalTo(@32);
    }];
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
    [_name setTextColor:[UIColor colorWithHex:KCommonBlackColor]];
    [cardbgView addSubview:_name];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    _signature.numberOfLines = 2;
    _signature.textAlignment = NSTextAlignmentCenter;
    _signature.textColor = [UIColor colorWithHex:KCommonGraySubTextColor];
    _signature.lineBreakMode = NSLineBreakByCharWrapping;
    [cardbgView addSubview:_signature];
        
    _genderImageView = [[UIImageView alloc]init];
    _genderImageView.backgroundColor = [UIColor whiteColor];
    [cardbgView addSubview:_genderImageView];

    _company = [[UILabel alloc] init];
    [_company setFont:[UIFont systemFontOfSize:14]];
    [_company setTextColor:[UIColor colorWithHex:KCommonGraySubTextColor]];
    _company.text = @"未设置";
    [cardbgView addSubview:_company];
    
    _locationImageView = [[UIImageView alloc]init];
    _locationImageView.image = YZChatResource(@"icon_location");
    [cardbgView addSubview:_locationImageView];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)fillWithData:(ProfileCardCellData *)data
{
    [super fillWithData:data];
    self.cardData = data;
    //set data
    @weakify(self)
    
    RAC(_signature, text) = [RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal];
    [[[RACObserve(data, signature) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.signature.text = data.signature;//[data.signature stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]
    }];
    
    [[[RACObserve(data, name) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.name.text = x;
    }];
    
    [[RACObserve(data, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.avatar sd_setImageWithURL:x placeholderImage:self.cardData.avatarImage];
    }];
    
    [[[RACObserve(data, company) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.company.text = [x length] == 0 ? @"未设置" : x;
    }];
    
    [[[RACObserve(data, gender) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber* x) {
        @strongify(self)
        int gender = [x intValue];
        if (gender == 1) {
            self.genderImageView.image = YZChatResource(@"icon_male");
            self.genderView.hidden = NO;
        }else if (gender == 2) {
            self.genderImageView.image = YZChatResource(@"icon_female");
            self.genderView.hidden = NO;
        }else {
            self.genderImageView.image = nil;
            self.genderView.hidden = YES;
        }
    }];
    
    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.size.equalTo(@100);
        make.top.equalTo(@0);
    }];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@47);
        make.centerX.equalTo(@0);
        make.width.lessThanOrEqualTo(@200);
    }];
    
    [_signature mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.name.mas_bottom).offset(8);
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
    }];

    [_genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_name.mas_right).offset(3);
        make.centerY.equalTo(_name.mas_centerY);
    }];
    
    [_company mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_locationImageView.mas_right).offset(2);
        make.top.equalTo(_signature.mas_bottom).offset(2);
        make.centerX.equalTo(@14);
        make.right.lessThanOrEqualTo(@-16);
    }];
    
    [_locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_company.mas_left).offset(-2);
        make.size.equalTo(@14);
        make.centerY.equalTo(_company.mas_centerY);
    }];
    
}


-(void) onTapAvatar{
    if(_delegate && [_delegate respondsToSelector:@selector(didTapOnAvatar:)])
        [_delegate didTapOnAvatar:self];
}

- (void)onQrcode {
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnQrcode:)]) {
        [_delegate didTapOnQrcode:self];
    }
}

- (void)signatureAction {
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSignature)]) {
        [_delegate didTapSignature];
    }
}

@end
