//
//  LocationMessageCell.m
//  YChat
//
//  Created by magic on 2020/11/14.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "LocationMessageCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "MMLayout/UIView+MMLayout.h"

@implementation LocationMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithHex:KCommonBlackTextColor];
        [self.container addSubview:_titleLabel];

        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.textColor = [UIColor colorWithHex:KCommonBubbleTextGrayColor];
        [self.container addSubview:_addressLabel];
        
        [self.container.layer setMasksToBounds:YES];
        [self.container.layer setCornerRadius:4];
        
        self.mapImageView = [[UIImageView alloc]init];
        self.mapImageView.image = [UIImage imageNamed:@"sendlocation_mapimage"];
        [self.container addSubview:self.mapImageView];
    }
    return self;
}

- (void)fillWithData:(LocationMessageCellData *)data;
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
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@12);
        make.right.equalTo(@-16);
    }];

    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.equalTo(@12);
    }];

    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(self.addressLabel.mas_bottom).offset(12);
    }];
    
}




@end
