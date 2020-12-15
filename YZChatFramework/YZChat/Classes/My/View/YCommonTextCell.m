//
//  YCommonTextCell.m
//  YChat
//
//  Created by magic on 2020/10/21.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YCommonTextCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+ColorExtension.h"
#import <Masonry.h>

@implementation YCommonTextCellData
- (instancetype)init {
    self = [super init];

    return self;
}

@end

@interface YCommonTextCell()
@property YCommonTextCellData *textData;
@property (nonatomic, strong)UIImageView *accessoryImageView;
@end

@implementation YCommonTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        _keyLabel = self.textLabel;
        _keyLabel.font = [UIFont systemFontOfSize:16];
        _keyLabel.textColor = [UIColor colorWithHex:KCommonBlackTextColor];
        
        _valueLabel = [[UILabel alloc]init];
        _valueLabel.font = [UIFont systemFontOfSize:14];
        _valueLabel.textColor = [UIColor colorWithHex:kCommonBlueTextColor];
        [self.contentView addSubview:_valueLabel];
        
        _accessoryImageView = [[UIImageView alloc]init];
        _accessoryImageView.image = YZChatResource(@"accessory_icon");
        [self.contentView addSubview:_accessoryImageView];
        
        [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.right.equalTo(_accessoryImageView.mas_left).offset(-5);
        }];
        
        [_accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-24);
            make.centerY.equalTo(@0);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.changeColorWhenTouched = YES;
    }
    return self;
}


- (void)fillWithData:(YCommonTextCellData *)textData
{
    [super fillWithData:textData];

    self.textData = textData;
    RAC(_keyLabel, text) = [RACObserve(textData, key) takeUntil:self.rac_prepareForReuseSignal];
    RAC(_valueLabel, text) = [RACObserve(textData, value) takeUntil:self.rac_prepareForReuseSignal];

    if (textData.showAccessory) {
        self.accessoryImageView.hidden = false;
    } else {
        self.accessoryImageView.hidden = true;
    }
}


@end
