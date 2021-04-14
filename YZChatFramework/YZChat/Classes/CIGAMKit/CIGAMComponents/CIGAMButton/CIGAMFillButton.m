/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMFillButton.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import "CIGAMFillButton.h"
#import "CIGAMCore.h"

@implementation CIGAMFillButton

- (instancetype)init {
    return [self initWithFillType:CIGAMFillButtonColorBlue];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFillType:CIGAMFillButtonColorBlue frame:frame];
}

- (instancetype)initWithFillType:(CIGAMFillButtonColor)fillType {
    return [self initWithFillType:fillType frame:CGRectZero];
}

- (instancetype)initWithFillType:(CIGAMFillButtonColor)fillType frame:(CGRect)frame {
    UIColor *fillColor = nil;
    UIColor *textColor = UIColorWhite;
    switch (fillType) {
        case CIGAMFillButtonColorBlue:
            fillColor = FillButtonColorBlue;
            break;
        case CIGAMFillButtonColorRed:
            fillColor = FillButtonColorRed;
            break;
        case CIGAMFillButtonColorGreen:
            fillColor = FillButtonColorGreen;
            break;
        case CIGAMFillButtonColorGray:
            fillColor = FillButtonColorGray;
            break;
        case CIGAMFillButtonColorWhite:
            fillColor = FillButtonColorWhite;
            textColor = UIColorBlue;
        default:
            break;
    }
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:frame];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor {
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:CGRectZero];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fillColor = fillColor;
        self.titleTextColor = textColor;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.fillColor = FillButtonColorBlue;
        self.titleTextColor = UIColorWhite;
    }
    return self;
}

- (void)setAdjustsImageWithTitleTextColor:(BOOL)adjustsImageWithTitleTextColor {
    _adjustsImageWithTitleTextColor = adjustsImageWithTitleTextColor;
    if (adjustsImageWithTitleTextColor) {
        [self updateImageColor];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.backgroundColor = fillColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    [self setTitleColor:titleTextColor forState:UIControlStateNormal];
    if (self.adjustsImageWithTitleTextColor) {
        [self updateImageColor];
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageWithTitleTextColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

- (void)updateImageColor {
    self.imageView.tintColor = self.adjustsImageWithTitleTextColor ? self.titleTextColor : nil;
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            if (self.adjustsImageWithTitleTextColor) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

@end

@implementation CIGAMFillButton (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    CIGAMFillButton *appearance = [CIGAMFillButton appearance];
    appearance.cornerRadius = CIGAMButtonCornerRadiusAdjustsBounds;
    appearance.adjustsImageWithTitleTextColor = NO;
}

@end
