/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableViewCell+CIGAM.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/7/5.
//

#import "UITableViewCell+CIGAM.h"
#import "CIGAMCore.h"
#import "UIView+CIGAM.h"
#import "UITableView+CIGAM.h"
#import "CALayer+CIGAM.h"

const UIEdgeInsets CIGAMTableViewCellSeparatorInsetsNone = {INFINITY, INFINITY, INFINITY, INFINITY};

@interface UITableViewCell ()

@property(nonatomic, copy) NSString *cigamTbc_cachedAddToTableViewBlockKey;
@property(nonatomic, strong) CALayer *cigamTbc_separatorLayer;
@property(nonatomic, strong) CALayer *cigamTbc_topSeparatorLayer;
@end

@implementation UITableViewCell (CIGAM)

CIGAMSynthesizeNSIntegerProperty(cigam_style, setCigam_style)
CIGAMSynthesizeIdCopyProperty(cigamTbc_cachedAddToTableViewBlockKey, setCigamTbc_cachedAddToTableViewBlockKey)
CIGAMSynthesizeIdCopyProperty(cigam_configureStyleBlock, setCigam_configureStyleBlock)
CIGAMSynthesizeIdStrongProperty(cigamTbc_separatorLayer, setCigamTbc_separatorLayer)
CIGAMSynthesizeIdStrongProperty(cigamTbc_topSeparatorLayer, setCigamTbc_topSeparatorLayer)
CIGAMSynthesizeIdCopyProperty(cigam_separatorInsetsBlock, setCigam_separatorInsetsBlock)
CIGAMSynthesizeIdCopyProperty(cigam_topSeparatorInsetsBlock, setCigam_topSeparatorInsetsBlock)
CIGAMSynthesizeIdCopyProperty(cigam_setHighlightedBlock, setCigam_setHighlightedBlock)
CIGAMSynthesizeIdCopyProperty(cigam_setSelectedBlock, setCigam_setSelectedBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UITableViewCell class], @selector(initWithStyle:reuseIdentifier:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UITableViewCell *(UITableViewCell *selfObject, UITableViewCellStyle firstArgv, NSString *secondArgv) {
                // call super
                UITableViewCell *(*originSelectorIMP)(id, SEL, UITableViewCellStyle, NSString *);
                originSelectorIMP = (UITableViewCell *(*)(id, SEL, UITableViewCellStyle, NSString *))originalIMPProvider();
                UITableViewCell *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                // 系统虽然有私有 API - (UITableViewCellStyle)style; 可以用，但该方法在 init 内得到的永远是 0，只有 init 执行完成后才可以得到正确的值，所以这里只能自己记录
                result.cigam_style = firstArgv;
                
                if (@available(iOS 13.0, *)) {
                    [selfObject cigamTbc_callAddToTableViewBlockIfCan];
                }
                
                return result;
            };
        });
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setHighlighted:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL highlighted, BOOL animated) {
            if (selfObject.cigam_setHighlightedBlock) {
                selfObject.cigam_setHighlightedBlock(highlighted, animated);
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setSelected:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL selected, BOOL animated) {
            if (selfObject.cigam_setSelectedBlock) {
                selfObject.cigam_setSelectedBlock(selected, animated);
            }
        });
        
        // 修复 iOS 13.0 UIButton 作为 cell.accessoryView 时布局错误的问题
        // https://github.com/Tencent/CIGAM_iOS/issues/693
        if (@available(iOS 13.0, *)) {
            if (@available(iOS 13.1, *)) {
            } else {
                ExtendImplementationOfVoidMethodWithoutArguments([UITableViewCell class], @selector(layoutSubviews), ^(UITableViewCell *selfObject) {
                    if ([selfObject.accessoryView isKindOfClass:[UIButton class]]) {
                        CGFloat defaultRightMargin = 15 + SafeAreaInsetsConstantForDeviceWithNotch.right;
                        selfObject.accessoryView.cigam_left = selfObject.cigam_width - defaultRightMargin - selfObject.accessoryView.cigam_width;
                        selfObject.accessoryView.cigam_top = CGRectGetMinYVerticallyCenterInParentRect(selfObject.frame, selfObject.accessoryView.frame);;
                        selfObject.contentView.cigam_right = selfObject.accessoryView.cigam_left;
                    }
                });
            }
        }
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_setTableView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableViewCell *selfObject, UITableView *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UITableView *);
                originSelectorIMP = (void (*)(id, SEL, UITableView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject cigamTbc_callAddToTableViewBlockIfCan];
            };
        });
    });
}

static char kAssociatedObjectKey_cellPosition;
- (void)setCigam_cellPosition:(CIGAMTableViewCellPosition)cigam_cellPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cellPosition, @(cigam_cellPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    BOOL shouldShowSeparatorInTableView = self.cigam_tableView && self.cigam_tableView.separatorStyle != UITableViewCellSeparatorStyleNone;
    if (shouldShowSeparatorInTableView) {
        [self cigamTbc_createSeparatorLayerIfNeeded];
        [self cigamTbc_createTopSeparatorLayerIfNeeded];
    }
}

- (CIGAMTableViewCellPosition)cigam_cellPosition {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cellPosition)) integerValue];
}

static char kAssociatedObjectKey_didAddToTableViewBlock;
- (void)setCigam_didAddToTableViewBlock:(void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull))cigam_didAddToTableViewBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_didAddToTableViewBlock, cigam_didAddToTableViewBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self cigamTbc_callAddToTableViewBlockIfCan];
}

- (void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull))cigam_didAddToTableViewBlock {
    return (void (^)(__kindof UITableView * _Nonnull, __kindof UITableViewCell * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_didAddToTableViewBlock);
}

- (void)cigamTbc_callAddToTableViewBlockIfCan {
    if (!self.cigam_tableView || !self.cigam_didAddToTableViewBlock) return;
    NSString *key = [NSString stringWithFormat:@"%p%p", self.cigam_tableView, self.cigam_didAddToTableViewBlock];
    if ([key isEqualToString:self.cigamTbc_cachedAddToTableViewBlockKey]) return;
    self.cigam_didAddToTableViewBlock(self.cigam_tableView, self);
    self.cigamTbc_cachedAddToTableViewBlockKey = key;
}

- (void)cigamTbc_swizzleLayoutSubviews {
    [CIGAMHelper executeBlock:^{
        ExtendImplementationOfVoidMethodWithoutArguments(self.class, @selector(layoutSubviews), ^(UITableViewCell *cell) {
            if (cell.cigamTbc_separatorLayer && !cell.cigamTbc_separatorLayer.hidden) {
                UIEdgeInsets insets = cell.cigam_separatorInsetsBlock(cell.cigam_tableView, cell);
                CGRect frame = CGRectZero;
                if (!UIEdgeInsetsEqualToEdgeInsets(insets, CIGAMTableViewCellSeparatorInsetsNone)) {
                    CGFloat height = PixelOne;
                    frame = CGRectMake(insets.left, CGRectGetHeight(cell.bounds) - height + insets.top - insets.bottom, MAX(0, CGRectGetWidth(cell.bounds) - UIEdgeInsetsGetHorizontalValue(insets)), height);
                }
                cell.cigamTbc_separatorLayer.frame = frame;
            }
            
            if (cell.cigamTbc_topSeparatorLayer && !cell.cigamTbc_topSeparatorLayer.hidden) {
                UIEdgeInsets insets = cell.cigam_topSeparatorInsetsBlock(cell.cigam_tableView, cell);
                CGRect frame = CGRectZero;
                if (!UIEdgeInsetsEqualToEdgeInsets(insets, CIGAMTableViewCellSeparatorInsetsNone)) {
                    CGFloat height = PixelOne;
                    frame = CGRectMake(insets.left, insets.top - insets.bottom, MAX(0, CGRectGetWidth(cell.bounds) - UIEdgeInsetsGetHorizontalValue(insets)), height);
                }
                cell.cigamTbc_topSeparatorLayer.frame = frame;
            }
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UITableViewCell %@-%@", NSStringFromClass(self.class), NSStringFromSelector(@selector(layoutSubviews))]];
}

- (BOOL)cigamTbc_customizedSeparator {
    return !!self.cigam_separatorInsetsBlock;
}

- (BOOL)cigamTbc_customizedTopSeparator {
    return !!self.cigam_topSeparatorInsetsBlock;
}

- (void)cigamTbc_createSeparatorLayerIfNeeded {
    if (![self cigamTbc_customizedSeparator]) {
        self.cigamTbc_separatorLayer.hidden = YES;
        return;
    }
    
    BOOL shouldShowSeparator = !UIEdgeInsetsEqualToEdgeInsets(self.cigam_separatorInsetsBlock(self.cigam_tableView, self), CIGAMTableViewCellSeparatorInsetsNone);
    if (shouldShowSeparator) {
        if (!self.cigamTbc_separatorLayer) {
            [self cigamTbc_swizzleLayoutSubviews];
            self.cigamTbc_separatorLayer = [CALayer layer];
            [self.cigamTbc_separatorLayer cigam_removeDefaultAnimations];
            [self.layer addSublayer:self.cigamTbc_separatorLayer];
        }
        self.cigamTbc_separatorLayer.backgroundColor = self.cigam_tableView.separatorColor.CGColor;
        self.cigamTbc_separatorLayer.hidden = NO;
    } else {
        if (self.cigamTbc_separatorLayer) {
            self.cigamTbc_separatorLayer.hidden = YES;
        }
    }
}

- (void)cigamTbc_createTopSeparatorLayerIfNeeded {
    if (![self cigamTbc_customizedTopSeparator]) {
        self.cigamTbc_topSeparatorLayer.hidden = YES;
        return;
    }
    
    BOOL shouldShowSeparator = !UIEdgeInsetsEqualToEdgeInsets(self.cigam_topSeparatorInsetsBlock(self.cigam_tableView, self), CIGAMTableViewCellSeparatorInsetsNone);
    if (shouldShowSeparator) {
        if (!self.cigamTbc_topSeparatorLayer) {
            [self cigamTbc_swizzleLayoutSubviews];
            self.cigamTbc_topSeparatorLayer = [CALayer layer];
            [self.cigamTbc_topSeparatorLayer cigam_removeDefaultAnimations];
            [self.layer addSublayer:self.cigamTbc_topSeparatorLayer];
        }
        self.cigamTbc_topSeparatorLayer.backgroundColor = self.cigam_tableView.separatorColor.CGColor;
        self.cigamTbc_topSeparatorLayer.hidden = NO;
    } else {
        if (self.cigamTbc_topSeparatorLayer) {
            self.cigamTbc_topSeparatorLayer.hidden = YES;
        }
    }
}

- (UITableView *)cigam_tableView {
    return [self valueForKey:@"_tableView"];
}

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setCigam_selectedBackgroundColor:(UIColor *)cigam_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, cigam_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_selectedBackgroundColor) {
        // 系统默认的 selectedBackgroundView 是 UITableViewCellSelectedBackground，无法修改自定义背景色，所以改为用普通的 UIView
        if ([NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
            self.selectedBackgroundView = [[UIView alloc] init];
        }
        self.selectedBackgroundView.backgroundColor = cigam_selectedBackgroundColor;
    }
}

- (UIColor *)cigam_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

- (UIView *)cigam_accessoryView {
    if (self.editing) {
        if (self.editingAccessoryView) {
            return self.editingAccessoryView;
        }
        return [self cigam_valueForKey:@"_editingAccessoryView"];
    }
    if (self.accessoryView) {
        return self.accessoryView;
    }
    
    // UITableViewCellAccessoryDetailDisclosureButton 在 iOS 13 及以上是分开的两个 accessoryView，以 NSSet 的形式存在这个私有接口里。而 iOS 12 及以下是以一个 UITableViewCellDetailDisclosureView 的 UIControl 存在。
    if (@available(iOS 13.0, *)) {
        NSSet<UIView *> *accessoryViews = [self cigam_valueForKey:@"_existingSystemAccessoryViews"];
        if ([accessoryViews isKindOfClass:NSSet.class] && accessoryViews.count) {
            UIView *leftView = nil;
            for (UIView *accessoryView in accessoryViews) {
                if (!leftView) {
                    leftView = accessoryView;
                    continue;
                }
                if (CGRectGetMinX(accessoryView.frame) < CGRectGetMinX(leftView.frame)) {
                    leftView = accessoryView;
                }
            }
            return leftView;
        }
        return nil;
    }
    return [self cigam_valueForKey:@"_accessoryView"];
}

@end

@implementation UITableViewCell (CIGAM_Styled)

- (void)cigam_styledAsCIGAMTableViewCell {
    if (!CIGAMCMIActivated) return;
    
    self.textLabel.font = UIFontMake(16);
    self.textLabel.backgroundColor = UIColorClear;
    UIColor *textLabelColor = self.cigam_styledTextLabelColor;
    if (textLabelColor) {
        self.textLabel.textColor = textLabelColor;
    }
    
    self.detailTextLabel.font = UIFontMake(15);
    self.detailTextLabel.backgroundColor = UIColorClear;
    UIColor *detailLabelColor = self.cigam_styledDetailTextLabelColor;
    if (detailLabelColor) {
        self.detailTextLabel.textColor = detailLabelColor;
    }
    
    UIColor *backgroundColor = self.cigam_styledBackgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    
    UIColor *selectedBackgroundColor = self.cigam_styledSelectedBackgroundColor;
    if (selectedBackgroundColor) {
        self.cigam_selectedBackgroundColor = selectedBackgroundColor;
    }
}

- (UIColor *)cigam_styledTextLabelColor {
    return PreferredValueForTableViewStyle(self.cigam_tableView.cigam_style, TableViewCellTitleLabelColor, TableViewGroupedCellTitleLabelColor, TableViewInsetGroupedCellTitleLabelColor);
}

- (UIColor *)cigam_styledDetailTextLabelColor {
    return PreferredValueForTableViewStyle(self.cigam_tableView.cigam_style, TableViewCellDetailLabelColor, TableViewGroupedCellDetailLabelColor, TableViewInsetGroupedCellDetailLabelColor);
}

- (UIColor *)cigam_styledBackgroundColor {
    return PreferredValueForTableViewStyle(self.cigam_tableView.cigam_style, TableViewCellBackgroundColor, TableViewGroupedCellBackgroundColor, TableViewInsetGroupedCellBackgroundColor);
}

- (UIColor *)cigam_styledSelectedBackgroundColor {
    return PreferredValueForTableViewStyle(self.cigam_tableView.cigam_style, TableViewCellSelectedBackgroundColor, TableViewGroupedCellSelectedBackgroundColor, TableViewInsetGroupedCellSelectedBackgroundColor);
}

- (UIColor *)cigam_styledWarningBackgroundColor {
    return PreferredValueForTableViewStyle(self.cigam_tableView.cigam_style, TableViewCellWarningBackgroundColor, TableViewGroupedCellWarningBackgroundColor, TableViewInsetGroupedCellWarningBackgroundColor);
}

@end

@implementation UITableViewCell (CIGAM_InsetGrouped)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_separatorFrame"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UITableViewCell *selfObject) {
                
                if ([selfObject cigamTbc_customizedSeparator]) {
                    return CGRectZero;
                }
                
                // iOS 13 自己会控制好 InsetGrouped 时不同 cellPosition 的分隔线显隐，iOS 12 及以下要全部手动处理
                if (@available(iOS 13.0, *)) {
                } else {
                    if (selfObject.cigam_tableView && selfObject.cigam_tableView.cigam_style == CIGAMTableViewStyleInsetGrouped && (selfObject.cigam_cellPosition & CIGAMTableViewCellPositionLastInSection) == CIGAMTableViewCellPositionLastInSection) {
                        return CGRectZero;
                    }
                }
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_topSeparatorFrame"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UITableViewCell *selfObject) {
                
                if ([selfObject cigamTbc_customizedTopSeparator]) {
                    return CGRectZero;
                }
                
                if (@available(iOS 13.0, *)) {
                } else {
                    // iOS 13 系统在 InsetGrouped 时默认就会隐藏顶部分隔线，所以这里只对 iOS 12 及以下处理
                    if (selfObject.cigam_tableView && selfObject.cigam_tableView.cigam_style == CIGAMTableViewStyleInsetGrouped) {
                        return CGRectZero;
                    }
                }
                
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        // 下方的功能，iOS 13 都交给系统的 InsetGrouped 处理
        if (@available(iOS 13.0, *)) return;
        
        OverrideImplementation([UITableViewCell class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableViewCell *selfObject, CGRect firstArgv) {
                
                UITableView *tableView = selfObject.cigam_tableView;
                if (tableView && tableView.cigam_style == CIGAMTableViewStyleInsetGrouped) {
                    // 以下的宽度不基于 firstArgv 来改，而是直接获取 tableView 的内容宽度，是因为 iOS 12 及以下的系统，在 cell 拖拽排序时，frame 会基于上一个 frame 计算，导致宽度不断减小，所以这里每次都用 tableView 的内容宽度来算
                    // https://github.com/Tencent/CIGAM_iOS/issues/1216
                    firstArgv = CGRectMake(tableView.cigam_safeAreaInsets.left + tableView.cigam_insetGroupedHorizontalInset, CGRectGetMinY(firstArgv), tableView.cigam_validContentWidth, CGRectGetHeight(firstArgv));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        // 将缩进后的宽度传给 cell 的 sizeThatFits:，注意 sizeThatFits: 只有在 tableView 开启 self-sizing 的情况下才会被调用（也即高度被指定为 UITableViewAutomaticDimension）
        // TODO: molice 系统的 UITableViewCell 第一次布局总是得到错误的高度，不知道为什么
        OverrideImplementation([UITableViewCell class], @selector(systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UITableViewCell *selfObject, CGSize targetSize, UILayoutPriority horizontalFittingPriority, UILayoutPriority verticalFittingPriority) {
                
                UITableView *tableView = selfObject.cigam_tableView;
                if (tableView && tableView.cigam_style == CIGAMTableViewStyleInsetGrouped) {
                    [CIGAMHelper executeBlock:^{
                        OverrideImplementation(selfObject.class, @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL cellOriginCMD, IMP (^cellOriginalIMPProvider)(void)) {
                            return ^CGSize(UITableViewCell *cell, CGSize firstArgv) {
                                
                                UITableView *tableView = cell.cigam_tableView;
                                if (tableView && tableView.cigam_style == CIGAMTableViewStyleInsetGrouped) {
                                    firstArgv.width = firstArgv.width - UIEdgeInsetsGetHorizontalValue(tableView.cigam_safeAreaInsets) - tableView.cigam_insetGroupedHorizontalInset * 2;
                                }
                                
                                // call super
                                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))cellOriginalIMPProvider();
                                CGSize result = originSelectorIMP(cell, cellOriginCMD, firstArgv);
                                return result;
                            };
                        });
                    } oncePerIdentifier:[NSString stringWithFormat:@"InsetGroupedCell %@-%@", NSStringFromClass(selfObject.class), NSStringFromSelector(@selector(sizeThatFits:))]];
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize, UILayoutPriority, UILayoutPriority);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize, UILayoutPriority, UILayoutPriority))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, targetSize, horizontalFittingPriority, verticalFittingPriority);
                return result;
            };
        });
    });
}

@end
