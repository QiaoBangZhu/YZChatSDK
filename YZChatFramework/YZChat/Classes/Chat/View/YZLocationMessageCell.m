//
//  LocationMessageCell.m
//  YChat
//
//  Created by magic on 2020/11/14.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZLocationMessageCell.h"

#import "MMLayout/UIView+MMLayout.h"

#import "UIColor+ColorExtension.h"
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

    self.shadowImageView.mm_fill();
    self.bgView.mm_fill().mm_left(6).mm_top(7).mm_flexToRight(7).mm_flexToBottom(7);
    self.titleLabel.mm_sizeToFit().mm_left(16).mm_top(12).mm_width(MIN(self.bgView.mm_w - 32, self.titleLabel.mm_w));
    self.addressLabel.mm_sizeToFit().mm_left(16).mm_top(self.titleLabel.mm_maxY + 4).mm_width(MIN(self.bgView.mm_w - 32, self.addressLabel.mm_w));
    self.mapImageView.mm_fill().mm_top(self.addressLabel.mm_maxY + 12).mm_flexToBottom(0);
}

@end
