/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMPopupMenuButtonItem.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/8/21.
//

#import "CIGAMPopupMenuButtonItem.h"
#import "CIGAMButton.h"
#import "UIControl+CIGAM.h"
#import "CIGAMPopupMenuView.h"
#import "CIGAMCore.h"

@interface CIGAMPopupMenuButtonItem (UIAppearance)

- (void)updateAppearanceForMenuButtonItem;
@end

@implementation CIGAMPopupMenuButtonItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(nullable void (^)(CIGAMPopupMenuButtonItem *))handler {
    CIGAMPopupMenuButtonItem *item = [[self alloc] init];
    item.image = image;
    item.title = title;
    item.handler = handler;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
        
        _button = [[CIGAMButton alloc] init];
        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.button.tintColor = nil;
        self.button.cigam_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        [self updateAppearanceForMenuButtonItem];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.button sizeThatFits:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
    [self updateButtonImageEdgeInsets];
}

- (void)setImageMarginRight:(CGFloat)imageMarginRight {
    _imageMarginRight = imageMarginRight;
    [self updateButtonImageEdgeInsets];
}

- (void)updateButtonImageEdgeInsets {
    if (self.button.currentImage) {
        self.button.imageEdgeInsets = UIEdgeInsetsSetRight(self.button.imageEdgeInsets, self.imageMarginRight);
    }
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    self.button.highlightedBackgroundColor = highlightedBackgroundColor;
}

- (void)handleButtonEvent:(id)sender {
    if (self.handler) {
        self.handler(self);
    }
}

- (void)updateAppearance {
    self.button.titleLabel.font = self.menuView.itemTitleFont;
    [self.button setTitleColor:self.menuView.itemTitleColor forState:UIControlStateNormal];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, self.menuView.padding.left, 0, self.menuView.padding.right);
}

@end

@implementation CIGAMPopupMenuButtonItem (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearanceForPopupMenuView];
    });
}

+ (void)setDefaultAppearanceForPopupMenuView {
    CIGAMPopupMenuButtonItem *appearance = [CIGAMPopupMenuButtonItem appearance];
    appearance.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor;
    appearance.imageMarginRight = 6;
}

- (void)updateAppearanceForMenuButtonItem {
    CIGAMPopupMenuButtonItem *appearance = [CIGAMPopupMenuButtonItem appearance];
    self.highlightedBackgroundColor = appearance.highlightedBackgroundColor;
    self.imageMarginRight = appearance.imageMarginRight;
}

@end
