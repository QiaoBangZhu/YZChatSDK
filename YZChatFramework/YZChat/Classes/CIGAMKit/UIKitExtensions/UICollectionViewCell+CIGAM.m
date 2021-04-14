/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UICollectionViewCell+CIGAM.m
//  CIGAMKit
//
//  Created by MoLice on 2021/M/9.
//

#import "UICollectionViewCell+CIGAM.h"
#import "CIGAMCore.h"

@interface UICollectionViewCell ()
@property(nonatomic, strong) UIView *cigamcvc_selectedBackgroundView;
@end

@implementation UICollectionViewCell (CIGAM)

CIGAMSynthesizeIdStrongProperty(cigamcvc_selectedBackgroundView, setCigamcvc_selectedBackgroundView)

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setCigam_selectedBackgroundColor:(UIColor *)cigam_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, cigam_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_selectedBackgroundColor && !self.selectedBackgroundView && !self.cigamcvc_selectedBackgroundView) {
        self.cigamcvc_selectedBackgroundView = UIView.new;
        self.selectedBackgroundView = self.cigamcvc_selectedBackgroundView;
    }
    if (self.cigamcvc_selectedBackgroundView) {
        self.cigamcvc_selectedBackgroundView.backgroundColor = cigam_selectedBackgroundColor;
    }
}

- (UIColor *)cigam_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

@end
