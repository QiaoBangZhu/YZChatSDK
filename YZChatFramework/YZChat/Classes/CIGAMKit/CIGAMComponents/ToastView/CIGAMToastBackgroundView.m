/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMToastBackgroundView.m
//  cigam
//
//  Created by CIGAM Team on 2016/12/11.
//

#import "CIGAMToastBackgroundView.h"
#import "CIGAMCore.h"
#import "CIGAMVisualEffectView.h"

@interface CIGAMToastBackgroundView ()

@end

@implementation CIGAMToastBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.allowsGroupOpacity = NO;
        self.backgroundColor = self.styleColor;
        self.layer.cornerRadius = self.cornerRadius;
        
    }
    return self;
}

- (void)setShouldBlurBackgroundView:(BOOL)shouldBlurBackgroundView {
    _shouldBlurBackgroundView = shouldBlurBackgroundView;
    if (shouldBlurBackgroundView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[CIGAMVisualEffectView alloc] initWithEffect:effect];
        self.effectView.layer.cornerRadius = self.cornerRadius;
        self.effectView.layer.masksToBounds = YES;
        self.effectView.foregroundColor = nil;
        [self addSubview:self.effectView];
    } else {
        if (self.effectView) {
            [self.effectView removeFromSuperview];
            _effectView = nil;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.effectView) {
        self.effectView.frame = self.bounds;
    }
}

#pragma mark - UIAppearance

- (void)setStyleColor:(UIColor *)styleColor {
    _styleColor = styleColor;
    self.backgroundColor = styleColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    if (self.effectView) {
        self.effectView.layer.cornerRadius = cornerRadius;
    }
}

@end


@interface CIGAMToastBackgroundView (UIAppearance)

@end

@implementation CIGAMToastBackgroundView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    CIGAMToastBackgroundView *appearance = [CIGAMToastBackgroundView appearance];
    appearance.styleColor = UIColorMakeWithRGBA(0, 0, 0, 0.8);
    appearance.cornerRadius = 10.0;
}

@end
