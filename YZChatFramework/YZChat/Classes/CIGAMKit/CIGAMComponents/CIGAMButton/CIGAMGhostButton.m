/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMGhostButton.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import "CIGAMGhostButton.h"
#import "CIGAMCore.h"

@implementation CIGAMGhostButton

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithGhostType:CIGAMGhostButtonColorBlue frame:frame];
}

- (instancetype)initWithGhostType:(CIGAMGhostButtonColor)ghostType {
    return [self initWithGhostType:ghostType frame:CGRectZero];
}

- (instancetype)initWithGhostType:(CIGAMGhostButtonColor)ghostType frame:(CGRect)frame {
    UIColor *ghostColor = nil;
    switch (ghostType) {
        case CIGAMGhostButtonColorBlue:
            ghostColor = GhostButtonColorBlue;
            break;
        case CIGAMGhostButtonColorRed:
            ghostColor = GhostButtonColorRed;
            break;
        case CIGAMGhostButtonColorGreen:
            ghostColor = GhostButtonColorGreen;
            break;
        case CIGAMGhostButtonColorGray:
            ghostColor = GhostButtonColorGray;
            break;
        case CIGAMGhostButtonColorWhite:
            ghostColor = GhostButtonColorWhite;
            break;
        default:
            break;
    }
    return [self initWithGhostColor:ghostColor frame:frame];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor {
    return [self initWithGhostColor:ghostColor frame:CGRectZero];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithGhostColor:ghostColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeWithGhostColor:GhostButtonColorBlue];
    }
    return self;
}

- (void)initializeWithGhostColor:(UIColor *)ghostColor {
    self.ghostColor = ghostColor;
}

- (void)setGhostColor:(UIColor *)ghostColor {
    _ghostColor = ghostColor;
    [self setTitleColor:_ghostColor forState:UIControlStateNormal];
    self.layer.borderColor = _ghostColor.CGColor;
    if (self.adjustsImageWithGhostColor) {
        [self updateImageColor];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setAdjustsImageWithGhostColor:(BOOL)adjustsImageWithGhostColor {
    _adjustsImageWithGhostColor = adjustsImageWithGhostColor;
    [self updateImageColor];
}

- (void)updateImageColor {
    self.imageView.tintColor = self.adjustsImageWithGhostColor ? self.ghostColor : nil;
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            if (self.adjustsImageWithGhostColor) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageWithGhostColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

@end

@implementation CIGAMGhostButton (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    CIGAMGhostButton *appearance = [CIGAMGhostButton appearance];
    appearance.borderWidth = 1;
    appearance.cornerRadius = CIGAMButtonCornerRadiusAdjustsBounds;
    appearance.adjustsImageWithGhostColor = NO;
}

@end
