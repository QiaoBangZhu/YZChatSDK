//
//  LocationMessageCell.m
//  YChat
//
//  Created by magic on 2020/11/14.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZLocationMessageCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "MMLayout/UIView+MMLayout.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

@interface YZLocationMessageCell()
@property (nonatomic, strong)UIView* bgView;
@end


@implementation YZLocationMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container.backgroundColor = [UIColor clearColor];
        
        self.shadowImageView = [[UIImageView alloc]init];
        self.shadowImageView.image = YZChatResource(@"map_shadow");
        [self.container addSubview:self.shadowImageView];
        
        self.bgView = [[UIView alloc]init];
        [self.container addSubview:self.bgView];

        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor colorWithHex:KCommonBlackTextColor];
        [self.bgView addSubview:_titleLabel];

        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.textColor = [UIColor colorWithHex:KCommonBubbleTextGrayColor];
        _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bgView addSubview:_addressLabel];
        
        [self.container.layer setMasksToBounds:YES];
        [self.container.layer setCornerRadius:4];
        
        self.mapImageView = [[UIImageView alloc]init];
        self.mapImageView.image = YZChatResource(@"sendlocation_mapimage");
        [self.bgView addSubview:self.mapImageView];
    }
    return self;
}

- (void)fillWithData:(YZLocationMessageCellData *)data;
{
    [super fillWithData:data];
    self.locationData = data;
   
    if ([data.text length] > 0 && [data.text containsString:@"##"]) {
        NSArray* textArray = [data.text componentsSeparatedByString:@"##"];
        if ([textArray count] == 2) {
            self.titleLabel.text = textArray[0];
            self.addressLabel.text = textArray[1];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect containFrame = self.container.frame;
    containFrame.size.height -= 15;
    self.container.frame = containFrame;
    
    CGRect readReceiptFrame = self.readReceiptLabel.frame;
    readReceiptFrame.origin.y -= 15;
    self.readReceiptLabel.frame = readReceiptFrame;
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@6);
        make.right.equalTo(@-7);
        make.top.equalTo(@7);
        make.bottom.equalTo(@-7);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@12);
        make.right.lessThanOrEqualTo(@-16);
    }];

    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.equalTo(@12);
        make.right.lessThanOrEqualTo(@-16);
    }];

    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(self.addressLabel.mas_bottom).offset(12);
    }];
    
    [self.shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

@end
