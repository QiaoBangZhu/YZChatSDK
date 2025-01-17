/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UISwitch+CIGAM.m
//  CIGAMKit
//
//  Created by MoLice on 2019/7/12.
//

#import "UISwitch+CIGAM.h"
#import "CIGAMCore.h"

@implementation UISwitch (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISwitch class], @selector(initWithFrame:), CGRect, UISwitch *, ^UISwitch *(UISwitch *selfObject, CGRect firstArgv, UISwitch *originReturnValue) {
            if (CIGAMCMIActivated) {
                if (SwitchTintColor) {
                    selfObject.tintColor = SwitchTintColor;
                }
                if (SwitchOffTintColor) {
                    selfObject.cigam_offTintColor = SwitchOffTintColor;
                }
            }
            return originReturnValue;
        });
        
        // 设置 cigam_offTintColor 的原理是找到 UISwitch 内部的 switchWellView 并改变它的 backgroundColor，而 switchWellView 在某些时机会重新创建 ，因此需要在这些时机之后对 switchWellView 重新设置一次背景颜色：
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(traitCollectionDidChange:), UITraitCollection *, ^(UISwitch *selfObject, UITraitCollection *previousTraitCollection) {
                BOOL interfaceStyleChanged = [previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:selfObject.traitCollection];
                if (interfaceStyleChanged) {
                    // 在 iOS 13 切换 Dark/Light Mode 之后，会在重新创建 switchWellView，之所以延迟一个 runloop 是因为这个时机是在晚于 traitCollectionDidChange 的 _traitCollectionDidChangeInternal中进行
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [selfObject cigam_applyOffTintColorIfNeeded];
                    });
                }
            });
        } else {
            // iOS 9 - 12 上调用 setOnTintColor: 或 setTintColor: 之后，会在重新创建 switchWellView
            ExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(setTintColor:), UIColor *, ^(UISwitch *selfObject, UIColor *firstArgv) {
                [selfObject cigam_applyOffTintColorIfNeeded];
            });
            ExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(setOnTintColor:), UIColor *, ^(UISwitch *selfObject, UIColor *firstArgv) {
                [selfObject cigam_applyOffTintColorIfNeeded];
            });

        }
        
    });
}


static char kAssociatedObjectKey_offTintColor;
static NSString * const kDefaultOffTintColorKey = @"defaultOffTintColorKey";

- (void)setCigam_offTintColor:(UIColor *)cigam_offTintColor {
    UIView *switchWellView = [self valueForKeyPath:@"_visualElement._switchWellView"];
    UIColor *defaultOffTintColor = [switchWellView cigam_getBoundObjectForKey:kDefaultOffTintColorKey];
    if (!defaultOffTintColor) {
        defaultOffTintColor = switchWellView.backgroundColor;
        [switchWellView cigam_bindObject:defaultOffTintColor forKey:kDefaultOffTintColorKey];
    }
    // 当 offTintColor 为 nil 时，恢复默认颜色（和 setOnTintColor 行为保持一致）
    switchWellView.backgroundColor = cigam_offTintColor ? : defaultOffTintColor;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_offTintColor, cigam_offTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)cigam_offTintColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_offTintColor);
}

- (void)cigam_applyOffTintColorIfNeeded {
    if (self.cigam_offTintColor) {
        self.cigam_offTintColor = self.cigam_offTintColor;
    }
}



@end
