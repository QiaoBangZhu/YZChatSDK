/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMImagePickerCollectionViewCell.m
//  cigam
//
//  Created by CIGAM Team on 16/8/29.
//

#import "CIGAMImagePickerCollectionViewCell.h"
#import "CIGAMCore.h"
#import "CIGAMImagePickerHelper.h"
#import "CIGAMPieProgressView.h"
#import "UIControl+CIGAM.h"
#import "UILabel+CIGAM.h"
#import "CALayer+CIGAM.h"
#import "CIGAMButton.h"
#import "UIView+CIGAM.h"
#import "NSString+CIGAM.h"
#import "CIGAMAppearance.h"

@interface CIGAMImagePickerCollectionViewCell ()

@property(nonatomic, strong, readwrite) UIImageView *favoriteImageView;
@property(nonatomic, strong, readwrite) CIGAMButton *checkboxButton;
@property(nonatomic, strong, readwrite) CAGradientLayer *bottomShadowLayer;

@end


@implementation CIGAMImagePickerCollectionViewCell

@synthesize videoDurationLabel = _videoDurationLabel;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [CIGAMImagePickerCollectionViewCell appearance].favoriteImage = [CIGAMHelper imageWithName:@"CIGAM_pickerImage_favorite"];
        [CIGAMImagePickerCollectionViewCell appearance].favoriteImageMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [CIGAMImagePickerCollectionViewCell appearance].checkboxImage = [CIGAMHelper imageWithName:@"CIGAM_pickerImage_checkbox"];
        [CIGAMImagePickerCollectionViewCell appearance].checkboxCheckedImage = [CIGAMHelper imageWithName:@"CIGAM_pickerImage_checkbox_checked"];
        [CIGAMImagePickerCollectionViewCell appearance].checkboxButtonMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [CIGAMImagePickerCollectionViewCell appearance].videoDurationLabelFont = UIFontMake(12);
        [CIGAMImagePickerCollectionViewCell appearance].videoDurationLabelTextColor = UIColorWhite;
        [CIGAMImagePickerCollectionViewCell appearance].videoDurationLabelMargins = UIEdgeInsetsMake(5, 5, 5, 7);
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initImagePickerCollectionViewCellUI];
        [self cigam_applyAppearance];
    }
    return self;
}

- (void)initImagePickerCollectionViewCellUI {
    _contentImageView = [[UIImageView alloc] init];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.contentImageView];
    
    self.bottomShadowLayer = [CAGradientLayer layer];
    [self.bottomShadowLayer cigam_removeDefaultAnimations];
    self.bottomShadowLayer.colors = @[(id)UIColorMakeWithRGBA(0, 0, 0, 0).CGColor, (id)UIColorMakeWithRGBA(0, 0, 0, .6).CGColor];
    self.bottomShadowLayer.hidden = YES;
    [self.contentView.layer addSublayer:self.bottomShadowLayer];
    [self setNeedsLayout];
    
    self.favoriteImageView = [[UIImageView alloc] init];
    self.favoriteImageView.hidden = YES;
    [self.contentView addSubview:self.favoriteImageView];
    
    self.checkboxButton = [[CIGAMButton alloc] init];
    self.checkboxButton.cigam_automaticallyAdjustTouchHighlightedInScrollView = YES;
    self.checkboxButton.cigam_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.checkboxButton.hidden = YES;
    [self.contentView addSubview:self.checkboxButton];
}

- (void)renderWithAsset:(CIGAMAsset *)asset referenceSize:(CGSize)referenceSize {
    self.assetIdentifier = asset.identifier;
    
    // 异步请求资源对应的缩略图
    [asset requestThumbnailImageWithSize:referenceSize completion:^(UIImage *result, NSDictionary *info) {
        if ([self.assetIdentifier isEqualToString:asset.identifier]) {
            self.contentImageView.image = result;
        } else {
            self.contentImageView.image = nil;
        }
    }];
    
    if (asset.assetType == CIGAMAssetTypeVideo) {
        [self initVideoDurationLabelIfNeeded];
        self.videoDurationLabel.text = [NSString cigam_timeStringWithMinsAndSecsFromSecs:asset.duration];
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoDurationLabel.hidden = YES;
    }
    
    self.favoriteImageView.hidden = !asset.phAsset.favorite;
    
    self.bottomShadowLayer.hidden = !((self.videoDurationLabel && !self.videoDurationLabel.hidden) || !self.favoriteImageView.hidden);
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentImageView.frame = self.contentView.bounds;
    if (_selectable) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - CGRectGetWidth(self.checkboxButton.bounds), self.checkboxButtonMargins.top);
    }
    
    CGFloat bottomShadowLayerHeight = 0;
    
    if (!self.favoriteImageView.hidden) {
        self.favoriteImageView.frame = CGRectSetXY(self.favoriteImageView.frame, self.favoriteImageMargins.left, CGRectGetHeight(self.contentView.bounds) - self.favoriteImageMargins.bottom - CGRectGetHeight(self.favoriteImageView.frame));
        bottomShadowLayerHeight = CGRectGetHeight(self.favoriteImageView.frame) + UIEdgeInsetsGetVerticalValue(self.favoriteImageMargins);
    }
    
    if (self.videoDurationLabel && !self.videoDurationLabel.hidden) {
        [self.videoDurationLabel sizeToFit];
        self.videoDurationLabel.frame = CGRectSetXY(self.videoDurationLabel.frame, CGRectGetWidth(self.contentView.bounds) - self.videoDurationLabelMargins.right - CGRectGetWidth(self.videoDurationLabel.frame), CGRectGetHeight(self.contentView.bounds) - self.videoDurationLabelMargins.bottom - CGRectGetHeight(self.videoDurationLabel.frame));
        bottomShadowLayerHeight = MAX(bottomShadowLayerHeight, CGRectGetHeight(self.videoDurationLabel.frame) + UIEdgeInsetsGetVerticalValue(self.videoDurationLabelMargins));
    }
    
    if (!self.bottomShadowLayer.hidden) {
        self.bottomShadowLayer.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - bottomShadowLayerHeight, CGRectGetWidth(self.contentView.bounds), bottomShadowLayerHeight);
    }
}

- (void)setFavoriteImage:(UIImage *)favoriteImage {
    if (![self.favoriteImage isEqual:favoriteImage]) {
        self.favoriteImageView.image = favoriteImage;
        [self.favoriteImageView sizeToFit];
        [self setNeedsLayout];
    }
    _favoriteImage = favoriteImage;
}

- (void)setCheckboxImage:(UIImage *)checkboxImage {
    if (![self.checkboxImage isEqual:checkboxImage]) {
        [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxImage = checkboxImage;
}

- (void)setCheckboxCheckedImage:(UIImage *)checkboxCheckedImage {
    if (![self.checkboxCheckedImage isEqual:checkboxCheckedImage]) {
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected];
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxCheckedImage = checkboxCheckedImage;
}

- (void)setVideoDurationLabelFont:(UIFont *)videoDurationLabelFont {
    if (![self.videoDurationLabelFont isEqual:videoDurationLabelFont]) {
        _videoDurationLabel.font = videoDurationLabelFont;
        [_videoDurationLabel cigam_calculateHeightAfterSetAppearance];
        [self setNeedsLayout];
    }
    _videoDurationLabelFont = videoDurationLabelFont;
}

- (void)setVideoDurationLabelTextColor:(UIColor *)videoDurationLabelTextColor {
    if (![self.videoDurationLabelTextColor isEqual:videoDurationLabelTextColor]) {
        _videoDurationLabel.textColor = videoDurationLabelTextColor;
    }
    _videoDurationLabelTextColor = videoDurationLabelTextColor;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (_selectable) {
        self.checkboxButton.selected = checked;
        [CIGAMImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        if (checked) {
            [CIGAMImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        }
    }
}

- (void)setSelectable:(BOOL)editing {
    _selectable = editing;
    if (self.downloadStatus == CIGAMAssetDownloadStatusSucceed) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)setDownloadStatus:(CIGAMAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (_selectable) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)initVideoDurationLabelIfNeeded {
    if (!self.videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] cigam_initWithFont:self.videoDurationLabelFont textColor:self.videoDurationLabelTextColor];
        [self.contentView addSubview:_videoDurationLabel];
        [self setNeedsLayout];
    }
}

@end
