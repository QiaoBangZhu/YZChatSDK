//
//  CommonTextImageTableViewCell.m
//  YChat
//
//  Created by magic on 2020/10/1.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "CommonTextImageTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "CommonConstant.h"
#import <Masonry/Masonry.h>
#import <QMUIKit/QMUIKit.h>

@implementation CommonTextCellData
- (instancetype)init {
    self = [super init];

    return self;
}

@end

@interface CommonTextImageTableViewCell()
@property CommonTextCellData *textData;

@end

@implementation CommonTextImageTableViewCell

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
        make.left.equalTo(@16);
        make.centerY.equalTo(@0);
        make.size.equalTo(@24);
    }];
    
    [_keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbnail.mas_right).offset(12);
        make.centerY.equalTo(@0);
        make.width.equalTo(@60);
    }];
    
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-16);
        make.centerY.equalTo(@0);
    }];
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@52);
        make.height.equalTo(@1);
        make.top.right.equalTo(@0);
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
        self.thumbnail.image = [textData.thumbnail qmui_imageWithTintColor:[UIColor colorWithHex:kCommonIconGrayColor]];
    }
    
    if (textData.showAccessory) {
        self.accessoryImageView.hidden = false;
    } else {
        self.accessoryImageView.hidden = true;
    }
    _line.hidden = !textData.showTopLine;
}

@end
