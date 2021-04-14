/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+CIGAMBadge.m
//  CIGAMKit
//
//  Created by MoLice on 2020/5/26.
//

#import "UIView+CIGAMBadge.h"
#import "CIGAMCore.h"
#import "CIGAMLabel.h"
#import "UIView+CIGAM.h"
#import "UITabBarItem+CIGAM.h"

@protocol _CIGAMBadgeViewProtocol <NSObject>

@required

@property(nonatomic, assign) CGPoint offset;
@property(nonatomic, assign) CGPoint offsetLandscape;
@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;

@end

@interface _CIGAMBadgeLabel : CIGAMLabel <_CIGAMBadgeViewProtocol>
@end

@interface _CIGAMUpdatesIndicatorView : UIView <_CIGAMBadgeViewProtocol>
@end

@interface UIView ()

@property(nonatomic, strong, readwrite) _CIGAMBadgeLabel *cigam_badgeLabel;
@property(nonatomic, strong, readwrite) _CIGAMUpdatesIndicatorView *cigam_updatesIndicatorView;
@property(nullable, nonatomic, strong) void (^cigambdg_layoutSubviewsBlock)(__kindof UIView *view);
@end

@implementation UIView (CIGAMBadge)

CIGAMSynthesizeIdStrongProperty(cigambdg_layoutSubviewsBlock, setCigambdg_layoutSubviewsBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保证配置表里的默认值正确被设置
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect firstArgv, UIView *originReturnValue) {
            [selfObject cigambdg_didInitialize];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *firstArgv, UIView *originReturnValue) {
            [selfObject cigambdg_didInitialize];
            return originReturnValue;
        });
        
        OverrideImplementation([UIView class], @selector(setCigam_layoutSubviewsBlock:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, void (^firstArgv)(__kindof UIView *aView)) {
                
                if (firstArgv && selfObject.cigambdg_layoutSubviewsBlock && firstArgv != selfObject.cigambdg_layoutSubviewsBlock) {
                    firstArgv = ^void(__kindof UIView *aaView) {
                        firstArgv(aaView);
                        aaView.cigambdg_layoutSubviewsBlock(aaView);
                    };
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, void (^firstArgv)(__kindof UIView *aView));
                originSelectorIMP = (void (*)(id, SEL, void (^firstArgv)(__kindof UIView *aView)))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)cigambdg_didInitialize {
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
        EndIgnoreDeprecatedWarning
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
        if (!self.cigam_badgeLabel) {
            self.cigam_badgeLabel = [[_CIGAMBadgeLabel alloc] init];
            self.cigam_badgeLabel.clipsToBounds = YES;
            self.cigam_badgeLabel.textAlignment = NSTextAlignmentCenter;
            self.cigam_badgeLabel.backgroundColor = self.cigam_badgeBackgroundColor;
            self.cigam_badgeLabel.textColor = self.cigam_badgeTextColor;
            self.cigam_badgeLabel.font = self.cigam_badgeFont;
            self.cigam_badgeLabel.contentEdgeInsets = self.cigam_badgeContentEdgeInsets;
            self.cigam_badgeLabel.offset = self.cigam_badgeOffset;
            self.cigam_badgeLabel.offsetLandscape = self.cigam_badgeOffsetLandscape;
            BeginIgnoreDeprecatedWarning
            self.cigam_badgeLabel.centerOffset = self.cigam_badgeCenterOffset;
            self.cigam_badgeLabel.centerOffsetLandscape = self.cigam_badgeCenterOffsetLandscape;
            EndIgnoreDeprecatedWarning
            [self addSubview:self.cigam_badgeLabel];
            
            [self updateLayoutSubviewsBlockIfNeeded];
        }
        self.cigam_badgeLabel.text = cigam_badgeString;
        self.cigam_badgeLabel.hidden = NO;
        [self setNeedsUpdateBadgeLabelLayout];
        self.clipsToBounds = NO;
    } else {
        self.cigam_badgeLabel.hidden = YES;
    }
}

- (NSString *)cigam_badgeString {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeString);
}

static char kAssociatedObjectKey_badgeBackgroundColor;
- (void)setCigam_badgeBackgroundColor:(UIColor *)cigam_badgeBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor, cigam_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeLabel.backgroundColor = cigam_badgeBackgroundColor;
}

- (UIColor *)cigam_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setCigam_badgeTextColor:(UIColor *)cigam_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, cigam_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeLabel.textColor = cigam_badgeTextColor;
}

- (UIColor *)cigam_badgeTextColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor);
}

static char kAssociatedObjectKey_badgeFont;
- (void)setCigam_badgeFont:(UIFont *)cigam_badgeFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeFont, cigam_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_badgeLabel) {
        self.cigam_badgeLabel.font = cigam_badgeFont;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIFont *)cigam_badgeFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeFont);
}

static char kAssociatedObjectKey_badgeContentEdgeInsets;
- (void)setCigam_badgeContentEdgeInsets:(UIEdgeInsets)cigam_badgeContentEdgeInsets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets, [NSValue valueWithUIEdgeInsets:cigam_badgeContentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_badgeLabel) {
        self.cigam_badgeLabel.contentEdgeInsets = cigam_badgeContentEdgeInsets;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIEdgeInsets)cigam_badgeContentEdgeInsets {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_badgeOffset;
- (void)setCigam_badgeOffset:(CGPoint)cigam_badgeOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffset, @(cigam_badgeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeLabel.offset = cigam_badgeOffset;
}

- (CGPoint)cigam_badgeOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeOffsetLandscape;
- (void)setCigam_badgeOffsetLandscape:(CGPoint)cigam_badgeOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape, @(cigam_badgeOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeLabel.offsetLandscape = cigam_badgeOffsetLandscape;
}

- (CGPoint)cigam_badgeOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_badgeCenterOffset;
- (void)setCigam_badgeCenterOffset:(CGPoint)cigam_badgeCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset, [NSValue valueWithCGPoint:cigam_badgeCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeLabel.centerOffset = cigam_badgeCenterOffset;
}

- (CGPoint)cigam_badgeCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeCenterOffsetLandscape;
- (void)setCigam_badgeCenterOffsetLandscape:(CGPoint)cigam_badgeCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape, [NSValue valueWithCGPoint:cigam_badgeCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_badgeLabel.centerOffsetLandscape = cigam_badgeCenterOffsetLandscape;
}

- (CGPoint)cigam_badgeCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

static char kAssociatedObjectKey_badgeLabel;
- (void)setCigam_badgeLabel:(UILabel *)cigam_badgeLabel {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeLabel, cigam_badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_CIGAMBadgeLabel *)cigam_badgeLabel {
    return (_CIGAMBadgeLabel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeLabel);
}

- (void)setNeedsUpdateBadgeLabelLayout {
    if (self.cigam_badgeString.length) {
        [self setNeedsLayout];
    }
}

#pragma mark - UpdatesIndicator

static char kAssociatedObjectKey_shouldShowUpdatesIndicator;
- (void)setCigam_shouldShowUpdatesIndicator:(BOOL)cigam_shouldShowUpdatesIndicator {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator, @(cigam_shouldShowUpdatesIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_shouldShowUpdatesIndicator) {
        if (!self.cigam_updatesIndicatorView) {
            self.cigam_updatesIndicatorView = [[_CIGAMUpdatesIndicatorView alloc] cigam_initWithSize:self.cigam_updatesIndicatorSize];
            self.cigam_updatesIndicatorView.layer.cornerRadius = CGRectGetHeight(self.cigam_updatesIndicatorView.bounds) / 2;
            self.cigam_updatesIndicatorView.backgroundColor = self.cigam_updatesIndicatorColor;
            self.cigam_updatesIndicatorView.offset = self.cigam_updatesIndicatorOffset;
            self.cigam_updatesIndicatorView.offsetLandscape = self.cigam_updatesIndicatorOffsetLandscape;
            BeginIgnoreDeprecatedWarning
            self.cigam_updatesIndicatorView.centerOffset = self.cigam_updatesIndicatorCenterOffset;
            self.cigam_updatesIndicatorView.centerOffsetLandscape = self.cigam_updatesIndicatorCenterOffsetLandscape;
            EndIgnoreDeprecatedWarning
            [self addSubview:self.cigam_updatesIndicatorView];
            [self updateLayoutSubviewsBlockIfNeeded];
        }
        [self setNeedsUpdateIndicatorLayout];
        self.clipsToBounds = NO;
        self.cigam_updatesIndicatorView.hidden = NO;
    } else {
        self.cigam_updatesIndicatorView.hidden = YES;
    }
}

- (BOOL)cigam_shouldShowUpdatesIndicator {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator)) boolValue];
}

static char kAssociatedObjectKey_updatesIndicatorColor;
- (void)setCigam_updatesIndicatorColor:(UIColor *)cigam_updatesIndicatorColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor, cigam_updatesIndicatorColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_updatesIndicatorView.backgroundColor = cigam_updatesIndicatorColor;
}

- (UIColor *)cigam_updatesIndicatorColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor);
}

static char kAssociatedObjectKey_updatesIndicatorSize;
- (void)setCigam_updatesIndicatorSize:(CGSize)cigam_updatesIndicatorSize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize, [NSValue valueWithCGSize:cigam_updatesIndicatorSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_updatesIndicatorView) {
        self.cigam_updatesIndicatorView.frame = CGRectSetSize(self.cigam_updatesIndicatorView.frame, cigam_updatesIndicatorSize);
        self.cigam_updatesIndicatorView.layer.cornerRadius = cigam_updatesIndicatorSize.height / 2;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGSize)cigam_updatesIndicatorSize {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize)) CGSizeValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffset;
- (void)setCigam_updatesIndicatorOffset:(CGPoint)cigam_updatesIndicatorOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset, @(cigam_updatesIndicatorOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_updatesIndicatorView) {
        self.cigam_updatesIndicatorView.offset = cigam_updatesIndicatorOffset;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)cigam_updatesIndicatorOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffsetLandscape;
- (void)setCigam_updatesIndicatorOffsetLandscape:(CGPoint)cigam_updatesIndicatorOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape, @(cigam_updatesIndicatorOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_updatesIndicatorView) {
        self.cigam_updatesIndicatorView.offsetLandscape = cigam_updatesIndicatorOffsetLandscape;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)cigam_updatesIndicatorOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_updatesIndicatorCenterOffset;
- (void)setCigam_updatesIndicatorCenterOffset:(CGPoint)cigam_updatesIndicatorCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset, [NSValue valueWithCGPoint:cigam_updatesIndicatorCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_updatesIndicatorView) {
        self.cigam_updatesIndicatorView.centerOffset = cigam_updatesIndicatorCenterOffset;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)cigam_updatesIndicatorCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape;
- (void)setCigam_updatesIndicatorCenterOffsetLandscape:(CGPoint)cigam_updatesIndicatorCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape, [NSValue valueWithCGPoint:cigam_updatesIndicatorCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.cigam_updatesIndicatorView) {
        self.cigam_updatesIndicatorView.centerOffsetLandscape = cigam_updatesIndicatorCenterOffsetLandscape;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)cigam_updatesIndicatorCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

static char kAssociatedObjectKey_updatesIndicatorView;
- (void)setCigam_updatesIndicatorView:(UIView *)cigam_updatesIndicatorView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView, cigam_updatesIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_CIGAMUpdatesIndicatorView *)cigam_updatesIndicatorView {
    return (_CIGAMUpdatesIndicatorView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView);
}

- (void)setNeedsUpdateIndicatorLayout {
    if (self.cigam_shouldShowUpdatesIndicator) {
        [self setNeedsLayout];
    }
}

#pragma mark - Common

- (void)updateLayoutSubviewsBlockIfNeeded {
    if (!self.cigambdg_layoutSubviewsBlock) {
        self.cigambdg_layoutSubviewsBlock = ^(UIView *view) {
            [view cigambdg_layoutSubviews];
        };
    }
    if (!self.cigam_layoutSubviewsBlock) {
        self.cigam_layoutSubviewsBlock = self.cigambdg_layoutSubviewsBlock;
    } else if (self.cigam_layoutSubviewsBlock != self.cigambdg_layoutSubviewsBlock) {
        void (^originalLayoutSubviewsBlock)(__kindof UIView *) = self.cigam_layoutSubviewsBlock;
        self.cigambdg_layoutSubviewsBlock = ^(__kindof UIView *view) {
            originalLayoutSubviewsBlock(view);
            [view cigambdg_layoutSubviews];
        };
        self.cigam_layoutSubviewsBlock = self.cigambdg_layoutSubviewsBlock;
    }
}

- (UIView *)findBarButtonImageViewIfOffsetByTopRight:(BOOL)offsetByTopRight {
    NSString *classString = NSStringFromClass(self.class);
    if ([classString isEqualToString:@"UITabBarButton"]) {
        // 特别的，对于 UITabBarItem，将 imageView 作为参考 view
        UIView *imageView = [UITabBarItem cigam_imageViewInTabBarButton:self];
        return imageView;
    }
    
    // 如果使用 centerOffset 则不特殊处理 UIBarButtonItem，以保持与旧版的逻辑一致
    // TODO: molice 等废弃 cigam_badgeCenterOffset 系列接口后再删除
    if (!offsetByTopRight) return nil;
    
    if (@available(iOS 11.0, *)) {
        if ([classString isEqualToString:@"_UIButtonBarButton"]) {
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:UIButton.class]) {
                    UIView *imageView = ((UIButton *)subview).imageView;
                    if (imageView && !imageView.hidden) {
                        return imageView;
                    }
                }
            }
        }
    } else {
        if ([classString isEqualToString:@"UINavigationButton"]) {
            UIView *imageView = ((UIButton *)self).imageView;
            if (imageView && !imageView.hidden) {
                return imageView;
            }
        }
        if ([classString isEqualToString:@"UIToolbarButton"]) {
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:UIButton.class]) {
                    UIView *imageView = ((UIButton *)subview).imageView;
                    if (imageView && !imageView.hidden) {
                        return imageView;
                    }
                }
            }
        }
    }
    
    return nil;
}

- (void)cigambdg_layoutSubviews {
    
    void (^layoutBlock)(UIView *view, UIView<_CIGAMBadgeViewProtocol> *badgeView) = ^void(UIView *view, UIView<_CIGAMBadgeViewProtocol> *badgeView) {
        BOOL offsetByTopRight = !CGPointEqualToPoint(badgeView.offset, CIGAMBadgeInvalidateOffset) || !CGPointEqualToPoint(badgeView.offsetLandscape, CIGAMBadgeInvalidateOffset);
        CGPoint offset = IS_LANDSCAPE ? (offsetByTopRight ? badgeView.offsetLandscape : badgeView.centerOffsetLandscape) : (offsetByTopRight ? badgeView.offset : badgeView.centerOffset);
        
        UIView *imageView = [view findBarButtonImageViewIfOffsetByTopRight:offsetByTopRight];
        if (imageView) {
            CGRect imageViewFrame = [view convertRect:imageView.frame fromView:imageView.superview];
            if (offsetByTopRight) {
                badgeView.frame = CGRectSetXY(badgeView.frame, CGRectGetMaxX(imageViewFrame) + offset.x, CGRectGetMinY(imageViewFrame) - CGRectGetHeight(badgeView.frame) + offset.y);
            } else {
                badgeView.center = CGPointMake(CGRectGetMidX(imageViewFrame) + offset.x, CGRectGetMidY(imageViewFrame) + offset.y);
            }
        } else {
            if (offsetByTopRight) {
                badgeView.frame = CGRectSetXY(badgeView.frame, CGRectGetWidth(view.bounds) + offset.x, - CGRectGetHeight(badgeView.frame) + offset.y);
            } else {
                badgeView.center = CGPointMake(CGRectGetMidX(view.bounds) + offset.x, CGRectGetMidY(view.bounds) + offset.y);
            }
        }
        [view bringSubviewToFront:badgeView];
    };
    
    if (self.cigam_updatesIndicatorView && !self.cigam_updatesIndicatorView.hidden) {
        layoutBlock(self, self.cigam_updatesIndicatorView);
    }
    if (self.cigam_badgeLabel && !self.cigam_badgeLabel.hidden) {
        [self.cigam_badgeLabel sizeToFit];
        self.cigam_badgeLabel.layer.cornerRadius = MIN(self.cigam_badgeLabel.cigam_height / 2, self.cigam_badgeLabel.cigam_width / 2);
        layoutBlock(self, self.cigam_badgeLabel);
    }
}

@end

@implementation _CIGAMUpdatesIndicatorView

@synthesize offset = _offset, offsetLandscape = _offsetLandscape, centerOffset = _centerOffset, centerOffsetLandscape = _centerOffsetLandscape;

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setOffsetLandscape:(CGPoint)offsetLandscape {
    _offsetLandscape = offsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

@end

@implementation _CIGAMBadgeLabel

@synthesize offset = _offset, offsetLandscape = _offsetLandscape, centerOffset = _centerOffset, centerOffsetLandscape = _centerOffsetLandscape;

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setOffsetLandscape:(CGPoint)offsetLandscape {
    _offsetLandscape = offsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result = CGSizeMake(MAX(result.width, result.height), result.height);
    return result;
}

@end
