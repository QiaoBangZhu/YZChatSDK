/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIBarItem+CIGAMBadge.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/6/2.
//

#import "UIBarItem+CIGAMBadge.h"
#import "CIGAMCore.h"
#import "UIView+CIGAMBadge.h"
#import "UIBarItem+CIGAM.h"

@implementation UIBarItem (CIGAMBadge)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保证配置表里的默认值正确被设置
        ExtendImplementationOfNonVoidMethodWithoutArguments([UIBarItem class], @selector(init), __kindof UIBarItem *, ^__kindof UIBarItem *(UIBarItem *selfObject, __kindof UIBarItem *originReturnValue) {
            [selfObject cigambaritem_didInitialize];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIBarItem class], @selector(initWithCoder:), NSCoder *, __kindof UIBarItem *, ^__kindof UIBarItem *(UIBarItem *selfObject, NSCoder *firstArgv, __kindof UIBarItem *originReturnValue) {
            [selfObject cigambaritem_didInitialize];
            return originReturnValue;
        });
        
        // UITabBarButton 在 layoutSubviews 时每次都重新让 imageView 和 label addSubview:，这会导致我们用 cigam_layoutSubviewsBlock 时产生持续的重复调用（但又不死循环，因为每次都在下一次 runloop 执行，而且奇怪的是如果不放到下一次 runloop，反而不会重复调用），所以这里 hack 地屏蔽 addSubview: 操作
        OverrideImplementation(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UITab", @"BarButton"]), @selector(addSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *firstArgv) {
                
                if (firstArgv.superview == selfObject) {
                    return;
                }
                
                // call super
                IMP originalIMP = originalIMPProvider();
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMP;
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)cigambaritem_didInitialize {
    if (CIGAMCMIActivated) {
        self.cigam_badgeBackgroundColor = BadgeBackgroundColor;
        self.cigam_badgeTextColor = BadgeTextColor;
        self.cigam_badgeFont = BadgeFont;
        self.cigam_badgeContentEdgeInsets = BadgeContentEdgeInsets;
        self.cigam_badgeOffset = BadgeOffset;
        self.cigam_badgeOffsetLandscape = BadgeOffsetLandscape;
        
        self.cigam_updatesIndicatorColor = UpdatesIndicatorColor;
        self.cigam_updatesIndicatorSize = UpdatesIndicatorSize;
        self.cigam_updatesIndicatorOffset = UpdatesIndicatorOffset;
        self.cigam_updatesIndicatorOffsetLandscape = UpdatesIndicatorOffsetLandscape;
        
        BeginIgnoreDeprecatedWarning
        self.cigam_badgeCenterOffset = BadgeCenterOffset;
        self.cigam_badgeCenterOffsetLandscape = BadgeCenterOffsetLandscape;
        self.cigam_updatesIndicatorCenterOffset = UpdatesIndicatorCenterOffset;
        self.cigam_updatesIndicatorCenterOffsetLandscape = UpdatesIndicatorCenterOffsetLandscape;
        EndIgnoreClangWarning
    }
}

#pragma mark - Badge

static char kAssociatedObjectKey_badgeInteger;
- (void)setCigam_badgeInteger:(NSUInteger)cigam_badgeInteger {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeInteger, @(cigam_badgeInteger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeString = cigam_badgeInteger > 0 ? [NSString stringWithFormat:@"%@", @(cigam_badgeInteger)] : nil;
}

- (NSUInteger)cigam_badgeInteger {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeInteger)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_badgeString;
- (void)setCigam_badgeString:(NSString *)cigam_badgeString {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeString, cigam_badgeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (cigam_badgeString.length) {
        [self updateViewDidSetBlockIfNeeded];
    }
    self.cigam_view.cigam_badgeString = cigam_badgeString;
}

- (NSString *)cigam_badgeString {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeString);
}

static char kAssociatedObjectKey_badgeBackgroundColor;
- (void)setCigam_badgeBackgroundColor:(UIColor *)cigam_badgeBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor, cigam_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeBackgroundColor = cigam_badgeBackgroundColor;
}

- (UIColor *)cigam_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setCigam_badgeTextColor:(UIColor *)cigam_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, cigam_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeTextColor = cigam_badgeTextColor;
}

- (UIColor *)cigam_badgeTextColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor);
}

static char kAssociatedObjectKey_badgeFont;
- (void)setCigam_badgeFont:(UIFont *)cigam_badgeFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeFont, cigam_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeFont = cigam_badgeFont;
}

- (UIFont *)cigam_badgeFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeFont);
}

static char kAssociatedObjectKey_badgeContentEdgeInsets;
- (void)setCigam_badgeContentEdgeInsets:(UIEdgeInsets)cigam_badgeContentEdgeInsets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets, [NSValue valueWithUIEdgeInsets:cigam_badgeContentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeContentEdgeInsets = cigam_badgeContentEdgeInsets;
}

- (UIEdgeInsets)cigam_badgeContentEdgeInsets {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_badgeOffset;
- (void)setCigam_badgeOffset:(CGPoint)cigam_badgeOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffset, @(cigam_badgeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeOffset = cigam_badgeOffset;
}

- (CGPoint)cigam_badgeOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeOffsetLandscape;
- (void)setCigam_badgeOffsetLandscape:(CGPoint)cigam_badgeOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape, @(cigam_badgeOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeOffsetLandscape = cigam_badgeOffsetLandscape;
}

- (CGPoint)cigam_badgeOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_badgeCenterOffset;
- (void)setCigam_badgeCenterOffset:(CGPoint)cigam_badgeCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset, [NSValue valueWithCGPoint:cigam_badgeCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeCenterOffset = cigam_badgeCenterOffset;
}

- (CGPoint)cigam_badgeCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeCenterOffsetLandscape;
- (void)setCigam_badgeCenterOffsetLandscape:(CGPoint)cigam_badgeCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape, [NSValue valueWithCGPoint:cigam_badgeCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_badgeCenterOffsetLandscape = cigam_badgeCenterOffsetLandscape;
}

- (CGPoint)cigam_badgeCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

- (CIGAMLabel *)cigam_badgeLabel {
    return self.cigam_view.cigam_badgeLabel;
}

#pragma mark - UpdatesIndicator

static char kAssociatedObjectKey_shouldShowUpdatesIndicator;
- (void)setCigam_shouldShowUpdatesIndicator:(BOOL)cigam_shouldShowUpdatesIndicator {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator, @(cigam_shouldShowUpdatesIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_shouldShowUpdatesIndicator) {
        [self updateViewDidSetBlockIfNeeded];
    }
    self.cigam_view.cigam_shouldShowUpdatesIndicator = cigam_shouldShowUpdatesIndicator;
}

- (BOOL)cigam_shouldShowUpdatesIndicator {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator)) boolValue];
}

static char kAssociatedObjectKey_updatesIndicatorColor;
- (void)setCigam_updatesIndicatorColor:(UIColor *)cigam_updatesIndicatorColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor, cigam_updatesIndicatorColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_updatesIndicatorColor = cigam_updatesIndicatorColor;
}

- (UIColor *)cigam_updatesIndicatorColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor);
}

static char kAssociatedObjectKey_updatesIndicatorSize;
- (void)setCigam_updatesIndicatorSize:(CGSize)cigam_updatesIndicatorSize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize, [NSValue valueWithCGSize:cigam_updatesIndicatorSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_updatesIndicatorSize = cigam_updatesIndicatorSize;
}

- (CGSize)cigam_updatesIndicatorSize {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize)) CGSizeValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffset;
- (void)setCigam_updatesIndicatorOffset:(CGPoint)cigam_updatesIndicatorOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset, @(cigam_updatesIndicatorOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_updatesIndicatorOffset = cigam_updatesIndicatorOffset;
}

- (CGPoint)cigam_updatesIndicatorOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffsetLandscape;
- (void)setCigam_updatesIndicatorOffsetLandscape:(CGPoint)cigam_updatesIndicatorOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape, @(cigam_updatesIndicatorOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_updatesIndicatorOffsetLandscape = cigam_updatesIndicatorOffsetLandscape;
}

- (CGPoint)cigam_updatesIndicatorOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_updatesIndicatorCenterOffset;
- (void)setCigam_updatesIndicatorCenterOffset:(CGPoint)cigam_updatesIndicatorCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset, [NSValue valueWithCGPoint:cigam_updatesIndicatorCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_updatesIndicatorCenterOffset = cigam_updatesIndicatorCenterOffset;
}

- (CGPoint)cigam_updatesIndicatorCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape;
- (void)setCigam_updatesIndicatorCenterOffsetLandscape:(CGPoint)cigam_updatesIndicatorCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape, [NSValue valueWithCGPoint:cigam_updatesIndicatorCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_view.cigam_updatesIndicatorCenterOffsetLandscape = cigam_updatesIndicatorCenterOffsetLandscape;
}

- (CGPoint)cigam_updatesIndicatorCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

- (UIView *)cigam_updatesIndicatorView {
    return self.cigam_view.cigam_updatesIndicatorView;
}

#pragma mark - Common

- (void)updateViewDidSetBlockIfNeeded {
    if (!self.cigam_viewDidSetBlock) {
        self.cigam_viewDidSetBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
            view.cigam_badgeBackgroundColor = item.cigam_badgeBackgroundColor;
            view.cigam_badgeTextColor = item.cigam_badgeTextColor;
            view.cigam_badgeFont = item.cigam_badgeFont;
            view.cigam_badgeContentEdgeInsets = item.cigam_badgeContentEdgeInsets;
            view.cigam_badgeOffset = item.cigam_badgeOffset;
            view.cigam_badgeOffsetLandscape = item.cigam_badgeOffsetLandscape;
            
            view.cigam_updatesIndicatorColor = item.cigam_updatesIndicatorColor;
            view.cigam_updatesIndicatorSize = item.cigam_updatesIndicatorSize;
            view.cigam_updatesIndicatorOffset = item.cigam_updatesIndicatorOffset;
            view.cigam_updatesIndicatorOffsetLandscape = item.cigam_updatesIndicatorOffsetLandscape;
            
            BeginIgnoreDeprecatedWarning
            view.cigam_badgeCenterOffset = item.cigam_badgeCenterOffset;
            view.cigam_badgeCenterOffsetLandscape = item.cigam_badgeCenterOffsetLandscape;
            view.cigam_updatesIndicatorCenterOffset = item.cigam_updatesIndicatorCenterOffset;
            view.cigam_updatesIndicatorCenterOffsetLandscape = item.cigam_updatesIndicatorCenterOffsetLandscape;
            EndIgnoreDeprecatedWarning
            
            view.cigam_badgeString = item.cigam_badgeString;
            view.cigam_shouldShowUpdatesIndicator = item.cigam_shouldShowUpdatesIndicator;
        };
        
        // 为 cigam_viewDidSetBlock 赋值前 item 已经 set 完 view，则手动触发一次
        if (self.cigam_view) {
            self.cigam_viewDidSetBlock(self, self.cigam_view);
        }
    }
}

@end
