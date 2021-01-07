//
//  ProfileCardCell.m
//  YChat
//
//  Created by magic on 2020/9/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ProfileCardCell.h"
#import "THeader.h"
#import <Masonry.h>
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+TUIKIT.h"
#import "UIColor+TUIDarkMode.h"
#import "CommonConstant.h"
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
    return 160;
}

@end

@implementation ProfileCardCell
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
    self.backgroundColor = [UIColor whiteColor];
    UIView* cardbgView = [[UIView alloc]initWithFrame:CGRectMake(16, 20, Screen_Width-32, 160)];
    [self addSubview:cardbgView];
//    cardbgView.backgroundColor = [UIColor colorWithRed:32/255.0 green:126/255.0 blue:214/255.0 alpha:1.0];
    cardbgView.layer.masksToBounds = YES;
//    cardbgView.layer.cornerRadius = 8;
    
//    UIImageView* accessoryImageView =  [[UIImageView alloc]init];
//    accessoryImageView.image = [UIImage imageNamed:@"right_arrow"];
//    [cardbgView addSubview:accessoryImageView];
//    [accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//       make.right.equalTo(@-16);
//       make.centerY.equalTo(@0);
//    }];
    
    // gradient
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,Screen_Width-32,160);
    gl.startPoint = CGPointMake(1, 0.5);
    gl.endPoint = CGPointMake(0, 0.5);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:32/255.0 green:126/255.0 blue:214/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:51/255.0 green:134/255.0 blue:242/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    cardbgView.layer.cornerRadius = 8;
    cardbgView.layer.shadowColor = [UIColor colorWithRed:54/255.0 green:61/255.0 blue:75/255.0 alpha:0.05].CGColor;
    cardbgView.layer.shadowOffset = CGSizeMake(0,2);
    cardbgView.layer.shadowOpacity = 1;
    cardbgView.layer.shadowRadius = 12;
    [cardbgView.layer addSublayer:gl];
    
    
    UIImageView* iconImageView = [[UIImageView alloc]init];
    iconImageView.image = YZChatResource(@"card_bg");
    [cardbgView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(@0);
        make.top.equalTo(@0);
    }];
    
    UIImageView* qrcodeImageView = [[UIImageView alloc]init];
    qrcodeImageView.image = YZChatResource(@"icon_qrcode");
    [cardbgView addSubview:qrcodeImageView];
    
    [qrcodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-16);
        make.top.equalTo(@26);
        make.size.equalTo(@16);
    }];
    
    //添加点击二维码的手势
    UITapGestureRecognizer *tapQrcode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onQrcode)];
    [qrcodeImageView addGestureRecognizer:tapQrcode];
    qrcodeImageView.userInteractionEnabled = YES;

    CGSize headSize = CGSizeMake(56, 56);
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, headSize.width, headSize.height)];
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    //添加点击头像的手势
    UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAvatar)];
    [_avatar addGestureRecognizer:tapAvatar];
    _avatar.userInteractionEnabled = YES;
    
    self.avatar.layer.masksToBounds = YES;
    self.avatar.layer.cornerRadius = headSize.height/2;
    [cardbgView addSubview:_avatar];
    
    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]];
    [_name setTextColor:[UIColor whiteColor]];
    [cardbgView addSubview:_name];
    
    _signature = [[UILabel alloc] init];
    [_signature setFont:[UIFont systemFontOfSize:14]];
    _signature.numberOfLines = 2;
    _signature.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6];
    _signature.lineBreakMode = NSLineBreakByCharWrapping;
    [cardbgView addSubview:_signature];
        
    _genderView = [[UIView alloc]init];
    _genderView.layer.cornerRadius = 6;
    _genderView.layer.masksToBounds = YES;
    _genderView.hidden = YES;
    [cardbgView addSubview:_genderView];
    
    _genderImageView = [[UIImageView alloc]init];
    _genderImageView.backgroundColor = [UIColor whiteColor];
    [_genderView addSubview:_genderImageView];

    _company = [[UILabel alloc] init];
    [_company setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium]];
    [_company setTextColor:[UIColor whiteColor]];
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
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(12);
        make.top.equalTo(_avatar.mas_top).offset(8);
        make.right.lessThanOrEqualTo(@-48);
    }];
    
    [_signature mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.top.equalTo(self.name.mas_bottom).offset(2);
        make.right.equalTo(@-26);
    }];

    [_genderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_right).offset(8);
        make.centerY.equalTo(self.name.mas_centerY);
        make.width.equalTo(@18);
        make.height.equalTo(@12);
    }];
    
    [_genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.center.equalTo(@0);
    }];
    
    [_locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.bottom.equalTo(@-16);
        make.size.equalTo(@16);
    }];
    
    [_company mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_locationImageView.mas_right).offset(3);
        make.centerY.equalTo(_locationImageView.mas_centerY);
        make.right.lessThanOrEqualTo(@-16);
        make.height.equalTo(@22);
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

@end
