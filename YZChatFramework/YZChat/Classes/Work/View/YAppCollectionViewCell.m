//
//  AppCollectionViewCell.m
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YAppCollectionViewCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface YAppCollectionViewCell()
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel     *titleLabel;

@end

@implementation YAppCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.thumbnail = [[UIImageView alloc] init];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        self.thumbnail.backgroundColor = [UIColor whiteColor];
        self.thumbnail.layer.masksToBounds = YES;
        self.thumbnail.layer.cornerRadius = 20;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackTextColor];
        self.titleLabel.preferredMaxLayoutWidth = 48;
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.titleLabel];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        
        [self.thumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@40);
            make.top.equalTo(@0);
            make.centerX.equalTo(@0);
        }];
    }
    return self;
}

- (void)cellData:(YAppInfoModel *)appInfo {
    self.titleLabel.text = appInfo.toolName;
    [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:appInfo.iconUrl]];
}


@end
