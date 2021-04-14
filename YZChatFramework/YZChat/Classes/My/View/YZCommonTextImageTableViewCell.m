//
//  YZCommonTextImageTableViewCell.m
//  YChat
//
//  Created by magic on 2020/10/1.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZCommonTextImageTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "CommonConstant.h"
#import <Masonry/Masonry.h>
#import "CIGAMKit.h"
#import "NSBundle+YZBundle.h"

@implementation CommonTextCellData
- (instancetype)init {
    self = [super init];

    return self;
}

@end

@interface YZCommonTextImageTableViewCell()
@property CommonTextCellData *textData;

@end

@implementation YZCommonTextImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        _thumbnail = [[UIImageView alloc]init];
        [self.contentView addSubview:_thumbnail];
        
        _keyLabel = [[UILabel alloc]init];;
        _keyLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        _keyLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_keyLabel];
        
        _valueLabel = [[UILabel alloc]init];
        _valueLabel.textColor = [UIColor colorWithHex: kCommonBlueTextColor];
        _valueLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_valueLabel];
        
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        [self.contentView addSubview:_line];
        
        _accessoryImageView = [[UIImageView alloc]init];
        _accessoryImageView.image = YZChatResource(@"accessory_icon");
        [self.contentView addSubview:_accessoryImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsZero];
         }
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
    
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_thumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@24);
        make.centerY.equalTo(@0);
        make.size.equalTo(@32);
    }];
    
    [_keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbnail.mas_right).offset(13);
        make.centerY.equalTo(@0);
        make.width.equalTo(@100);
    }];
    
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-24);
        make.centerY.equalTo(@0);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@68);
        make.height.equalTo(@0.5);
        make.top.right.equalTo(@0);
        make.right.equalTo(@-24);
    }];
    
    [_accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.right.equalTo(@-24);
    }];
}

- (void)fillWithData:(CommonTextCellData *)textData
{
    [super fillWithData:textData];

    self.textData = textData;
    RAC(_keyLabel, text) = [RACObserve(textData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(textData, value) takeUntil:self.rac_prepareForReuseSignal];
    
    if (@available(iOS 13.0, *)) {
        self.thumbnail.image = textData.thumbnail;
    } else {
        // Fallback on earlier versions
        self.thumbnail.image = [textData.thumbnail cigam_imageWithTintColor:[UIColor colorWithHex:kCommonIconGrayColor]];
    }
    
    if (textData.showAccessory) {
        self.accessoryImageView.hidden = false;
    } else {
        self.accessoryImageView.hidden = true;
    }
    _line.hidden = !textData.showTopLine;
    

    if (self.textData.showTopCorner || self.textData.showBottomCorner || self.textData.showCorner) {
        [self configureCorner];
    }
}

- (void)configureCorner {
    
    UIRectCorner corners = UIRectCornerTopRight | UIRectCornerTopLeft;
    
    if (self.textData.showTopCorner) {
        corners = UIRectCornerTopRight | UIRectCornerTopLeft;
    }
    if (self.textData.showBottomCorner) {
        corners = UIRectCornerBottomRight | UIRectCornerBottomLeft;
    }
    
    if (self.textData.showCorner) {
        corners = UIRectCornerTopRight | UIRectCornerTopLeft | UIRectCornerBottomRight | UIRectCornerBottomLeft;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds   byRoundingCorners: corners cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


@end
