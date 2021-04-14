/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMToolbarButton.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import "CIGAMToolbarButton.h"
#import "CIGAMCore.h"
#import "UIImage+CIGAM.h"

@implementation CIGAMToolbarButton

- (instancetype)init {
    return [self initWithType:CIGAMToolbarButtonTypeNormal];
}

- (instancetype)initWithType:(CIGAMToolbarButtonType)type {
    return [self initWithType:type title:nil];
}

- (instancetype)initWithType:(CIGAMToolbarButtonType)type title:(NSString *)title {
    if (self = [super init]) {
        _type = type;
        [self setTitle:title forState:UIControlStateNormal];
        [self renderButtonStyle];
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithType:CIGAMToolbarButtonTypeImage]) {
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:[image cigam_imageWithAlpha:ToolBarHighlightedAlpha] forState:UIControlStateHighlighted];
        [self setImage:[image cigam_imageWithAlpha:ToolBarDisabledAlpha] forState:UIControlStateDisabled];
        [self sizeToFit];
    }
    return self;
}

- (void)renderButtonStyle {
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.tintColor = nil; // 重置默认值，nil表示跟随父元素
    self.titleLabel.font = ToolBarButtonFont;
    switch (self.type) {
        case CIGAMToolbarButtonTypeNormal:
            [self setTitleColor:ToolBarTintColor forState:UIControlStateNormal];
            [self setTitleColor:ToolBarTintColorHighlighted forState:UIControlStateHighlighted];
            [self setTitleColor:ToolBarTintColorDisabled forState:UIControlStateDisabled];
            break;
        case CIGAMToolbarButtonTypeRed:
            [self setTitleColor:UIColorRed forState:UIControlStateNormal];
            [self setTitleColor:[UIColorRed colorWithAlphaComponent:ToolBarHighlightedAlpha] forState:UIControlStateHighlighted];
            [self setTitleColor:[UIColorRed colorWithAlphaComponent:ToolBarDisabledAlpha] forState:UIControlStateDisabled];
            self.imageView.tintColor = UIColorRed; // 修改为红色
            break;
        case CIGAMToolbarButtonTypeImage:
            break;
        default:
            break;
    }
}

+ (UIBarButtonItem *)barButtonItemWithToolbarButton:(CIGAMToolbarButton *)button target:(id)target action:(SEL)selector {
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemWithType:(CIGAMToolbarButtonType)type title:(NSString *)title target:(id)target action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
    if (type == CIGAMToolbarButtonTypeRed) {
        // 默认继承toolBar的tintColor，红色需要重置
        buttonItem.tintColor = UIColorRed;
    }
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    return buttonItem;
}

@end
