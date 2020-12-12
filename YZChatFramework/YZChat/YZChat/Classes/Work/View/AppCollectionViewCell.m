//
//  AppCollectionViewCell.m
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "AppCollectionViewCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface AppCollectionViewCell()
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel     *titleLabel;

@end

@implementation AppCollectionViewCell

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
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackTextColor];
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

- (void)cellData:(AppInfoModel *)appInfo {
    self.titleLabel.text = appInfo.toolName;
    [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:appInfo.iconUrl]];
}


@end
