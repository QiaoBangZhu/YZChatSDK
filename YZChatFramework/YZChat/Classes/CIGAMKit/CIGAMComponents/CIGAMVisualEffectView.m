/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMVisualEffectView.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/6/19.
//

#import "CIGAMVisualEffectView.h"
#import "CIGAMCore.h"
#import "CALayer+CIGAM.h"
#import "CALayer+CIGAMViewAnimation.h"

@interface CIGAMVisualEffectView ()

@property(nonatomic, strong) CALayer *foregroundLayer;

@end

@implementation CIGAMVisualEffectView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect {
    if (self = [super initWithEffect:effect]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.foregroundLayer = [CALayer layer];
    self.foregroundLayer.cigam_viewAnimationEnabled = YES;
    [self.foregroundLayer cigam_removeDefaultAnimations];
    [self.contentView.layer addSublayer:self.foregroundLayer];
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    self.foregroundLayer.backgroundColor = foregroundColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.foregroundLayer.frame = self.contentView.bounds;
}

@end
