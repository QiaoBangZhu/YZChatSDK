/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMTableViewHeaderFooterView.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2017/12/7.
//

#import "CIGAMTableViewHeaderFooterView.h"
#import "CIGAMCore.h"
#import "UIView+CIGAM.h"
#import "UITableView+CIGAM.h"
#import "UITableViewHeaderFooterView+CIGAM.h"

@implementation CIGAMTableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    
    // remove system subviews
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    self.backgroundView = [[UIView alloc] init];// 去掉默认的背景，以便屏蔽系统对背景色的控制
}

// 系统的 UITableViewHeaderFooterView 不允许修改 backgroundColor，都应该放到 backgroundView 里，但却没有在文档中写明，只有不小心误用时才会在 Xcode 控制台里提示，所以这里做个转换，保护误用的情况。
- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:backgroundColor];
    self.backgroundView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor {
//    return [super backgroundColor];
    return self.backgroundView.backgroundColor;
}

- (void)updateAppearance {
    if (!CIGAMCMIActivated || (!self.parentTableView && !self.cigam_tableView) || self.type == CIGAMTableViewHeaderFooterViewTypeUnknow) return;
    
    UITableViewStyle style = (self.parentTableView ?: self.cigam_tableView).cigam_style;
    
    if (self.type == CIGAMTableViewHeaderFooterViewTypeHeader) {
        self.titleLabel.font = PreferredValueForTableViewStyle(style, TableViewSectionHeaderFont, TableViewGroupedSectionHeaderFont, TableViewInsetGroupedSectionHeaderFont);
        self.titleLabel.textColor = PreferredValueForTableViewStyle(style, TableViewSectionHeaderTextColor, TableViewGroupedSectionHeaderTextColor, TableViewInsetGroupedSectionHeaderTextColor);
        self.contentEdgeInsets = PreferredValueForTableViewStyle(style, TableViewSectionHeaderContentInset, TableViewGroupedSectionHeaderContentInset, TableViewInsetGroupedSectionHeaderContentInset);
        self.accessoryViewMargins = PreferredValueForTableViewStyle(style, TableViewSectionHeaderAccessoryMargins, TableViewGroupedSectionHeaderAccessoryMargins, TableViewInsetGroupedSectionHeaderAccessoryMargins);
        self.backgroundView.backgroundColor = PreferredValueForTableViewStyle(style, TableViewSectionHeaderBackgroundColor, UIColorClear, UIColorClear);
    } else {
        self.titleLabel.font = PreferredValueForTableViewStyle(style, TableViewSectionFooterFont, TableViewGroupedSectionFooterFont, TableViewInsetGroupedSectionFooterFont);
        self.titleLabel.textColor = PreferredValueForTableViewStyle(style, TableViewSectionFooterTextColor, TableViewGroupedSectionFooterTextColor, TableViewInsetGroupedSectionFooterTextColor);
        self.contentEdgeInsets = PreferredValueForTableViewStyle(style, TableViewSectionFooterContentInset, TableViewGroupedSectionFooterContentInset, TableViewInsetGroupedSectionFooterContentInset);
        self.accessoryViewMargins = PreferredValueForTableViewStyle(style, TableViewSectionFooterAccessoryMargins, TableViewGroupedSectionFooterAccessoryMargins, TableViewInsetGroupedSectionFooterAccessoryMargins);
        self.backgroundView.backgroundColor = PreferredValueForTableViewStyle(style, TableViewSectionFooterBackgroundColor, UIColorClear, UIColorClear);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.accessoryView) {
        [self.accessoryView sizeToFit];
        self.accessoryView.cigam_right = self.contentView.cigam_width - self.contentEdgeInsets.right - self.accessoryViewMargins.right;
        self.accessoryView.cigam_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.cigam_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), self.accessoryView.cigam_height) + self.accessoryViewMargins.top - self.accessoryViewMargins.bottom;
    }
    
    self.titleLabel.cigam_left = self.contentEdgeInsets.left;
    self.titleLabel.cigam_extendToRight = self.accessoryView ? self.accessoryView.cigam_left - self.accessoryViewMargins.left : self.contentView.cigam_width - self.contentEdgeInsets.right;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.cigam_width, CGFLOAT_MAX)];
    self.titleLabel.cigam_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.cigam_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), titleLabelSize.height);
    self.titleLabel.cigam_height = titleLabelSize.height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = size;
    
    CGSize accessoryViewSize = self.accessoryView ? self.accessoryView.frame.size : CGSizeZero;
    if (self.accessoryView) {
        accessoryViewSize.width = accessoryViewSize.width + UIEdgeInsetsGetHorizontalValue(self.accessoryViewMargins);
        accessoryViewSize.height = accessoryViewSize.height + UIEdgeInsetsGetVerticalValue(self.accessoryViewMargins);
    }
    
    CGFloat titleLabelWidth = size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - accessoryViewSize.width;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, CGFLOAT_MAX)];
    
    resultSize.height = fmax(titleLabelSize.height, accessoryViewSize.height) + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
    return resultSize;
}

#pragma mark - getter / setter

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView && _accessoryView != accessoryView) {
        [_accessoryView removeFromSuperview];
    }
    _accessoryView = accessoryView;
    self.isAccessibilityElement = NO;
    self.titleLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
    [self.contentView addSubview:accessoryView];
}

- (void)setParentTableView:(UITableView *)parentTableView {
    _parentTableView = parentTableView;
    [self updateAppearance];
}

- (void)setType:(CIGAMTableViewHeaderFooterViewType)type {
    _type = type;
    [self updateAppearance];
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsLayout];
}

- (void)setAccessoryViewMargins:(UIEdgeInsets)accessoryViewMargins {
    _accessoryViewMargins = accessoryViewMargins;
    [self setNeedsLayout];
}

@end
