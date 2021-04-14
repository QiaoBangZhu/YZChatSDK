/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UISearchBar+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 16/5/26.
//

#import "UISearchBar+CIGAM.h"
#import "CIGAMCore.h"
#import "UIImage+CIGAM.h"
#import "UIView+CIGAM.h"

@interface UISearchBar ()

@property(nonatomic, assign) CGFloat cigamsb_centerPlaceholderCachedWidth1;
@property(nonatomic, assign) CGFloat cigamsb_centerPlaceholderCachedWidth2;
@property(nonatomic, assign) UIEdgeInsets cigamsb_customTextFieldMargins;
@end

@implementation UISearchBar (CIGAM)

CIGAMSynthesizeBOOLProperty(cigam_usedAsTableHeaderView, setCigam_usedAsTableHeaderView)
CIGAMSynthesizeBOOLProperty(cigam_alwaysEnableCancelButton, setCigam_alwaysEnableCancelButton)
CIGAMSynthesizeBOOLProperty(cigam_fixMaskViewLayoutBugAutomatically, setCigam_fixMaskViewLayoutBugAutomatically)
CIGAMSynthesizeUIEdgeInsetsProperty(cigamsb_customTextFieldMargins, setCigamsb_customTextFieldMargins)
CIGAMSynthesizeCGFloatProperty(cigamsb_centerPlaceholderCachedWidth1, setCigamsb_centerPlaceholderCachedWidth1)
CIGAMSynthesizeCGFloatProperty(cigamsb_centerPlaceholderCachedWidth2, setCigamsb_centerPlaceholderCachedWidth2)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        void (^setupCancelButtonBlock)(UISearchBar *, UIButton *) = ^void(UISearchBar *searchBar, UIButton *cancelButton) {
            if (searchBar.cigam_alwaysEnableCancelButton && !searchBar.cigam_searchController) {
                cancelButton.enabled = YES;
            }
            
            if (cancelButton && searchBar.cigam_cancelButtonFont) {
                cancelButton.titleLabel.font = searchBar.cigam_cancelButtonFont;
            }
            
            if (searchBar.cigam_cancelButtonMarginsBlock && cancelButton && !cancelButton.cigam_frameWillChangeBlock) {
                __weak __typeof(searchBar)weakSearchBar = searchBar;
                cancelButton.cigam_frameWillChangeBlock = ^CGRect(UIButton *aCancelButton, CGRect followingFrame) {
                    return [weakSearchBar cigamsb_adjustCancelButtonFrame:followingFrame];
                };
            } else if (!searchBar.cigam_cancelButtonMarginsBlock) {
                cancelButton.cigam_frameWillChangeBlock = nil;
            }
        };
        
        if (@available(iOS 13.0, *)) {
            // iOS 13 开始 UISearchBar 内部的输入框、取消按钮等 subviews 都由这个 class 创建、管理
            ExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString(@"_UISearchBarVisualProviderIOS"), NSSelectorFromString(@"setUpCancelButton"), ^(NSObject *selfObject) {
                UIButton *cancelButton = [selfObject cigam_valueForKey:@"cancelButton"];
                UISearchBar *searchBar = (UISearchBar *)cancelButton.superview.superview.superview;
                NSAssert([searchBar isKindOfClass:UISearchBar.class], @"Can not find UISearchBar from cancelButton");
                setupCancelButtonBlock(searchBar, cancelButton);
            });
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], NSSelectorFromString(@"_setupCancelButton"), ^(UISearchBar *selfObject) {
                setupCancelButtonBlock(selfObject, selfObject.cigam_cancelButton);
            });
        }
        
        OverrideImplementation(NSClassFromString(@"UINavigationButton"), @selector(setEnabled:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIButton *selfObject, BOOL firstArgv) {
                
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)selfObject.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)selfObject.superview.superview;
                }
                NSAssert(!searchBar || [searchBar isKindOfClass:UISearchBar.class], @"Can not find UISearchBar from cancelButton");
                if (searchBar.cigam_alwaysEnableCancelButton && !searchBar.cigam_searchController) {
                    firstArgv = YES;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UISearchBar class], @selector(setPlaceholder:), NSString *, (^(UISearchBar *selfObject, NSString *placeholder) {
            if (selfObject.cigam_placeholderColor || selfObject.cigam_font) {
                NSMutableAttributedString *string = selfObject.cigam_textField.attributedPlaceholder.mutableCopy;
                if (selfObject.cigam_placeholderColor) {
                    [string addAttribute:NSForegroundColorAttributeName value:selfObject.cigam_placeholderColor range:NSMakeRange(0, string.length)];
                }
                if (selfObject.cigam_font) {
                    [string addAttribute:NSFontAttributeName value:selfObject.cigam_font range:NSMakeRange(0, string.length)];
                }
                // 默认移除文字阴影
                [string removeAttribute:NSShadowAttributeName range:NSMakeRange(0, string.length)];
                selfObject.cigam_textField.attributedPlaceholder = string.copy;
            }
        }));
        
        // iOS 13 下，UISearchBar 内的 UITextField 的 _placeholderLabel 会在 didMoveToWindow 时被重新设置 textColor，导致我们在 searchBar 添加到界面之前设置的 placeholderColor 失效，所以在这里重新设置一遍
        // https://github.com/Tencent/CIGAM_iOS/issues/830
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(didMoveToWindow), ^(UISearchBar *selfObject) {
                if (selfObject.cigam_placeholderColor) {
                    selfObject.placeholder = selfObject.placeholder;
                }
            });
        }

        if (@available(iOS 13.0, *)) {
            // -[_UISearchBarLayout applyLayout] 是 iOS 13 系统新增的方法，该方法可能会在 -[UISearchBar layoutSubviews] 后调用，作进一步的布局调整。
            Class _UISearchBarLayoutClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBar", @"Layout"]);
            OverrideImplementation(_UISearchBarLayoutClass, NSSelectorFromString(@"applyLayout"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD);
                    };

                    UISearchBar *searchBar = (UISearchBar *)((UIView *)[selfObject cigam_valueForKey:[NSString stringWithFormat:@"_%@",@"searchBarBackground"]]).superview.superview;
                    
                    NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");

                    if (searchBar && searchBar.cigam_searchController.isBeingDismissed && searchBar.cigam_usedAsTableHeaderView) {
                        CGRect previousRect = searchBar.cigam_backgroundView.frame;
                        callSuperBlock();
                        // applyLayout 方法中会修改 _searchBarBackground  的 frame ，从而覆盖掉 cigam_usedAsTableHeaderView 做出的调整，所以这里还原本次修改。
                        searchBar.cigam_backgroundView.frame = previousRect;
                    } else {
                        callSuperBlock();
                    }
                };
                
            });
            
            if (@available(iOS 14.0, *)) {
                // iOS 14 beta 1 修改了 searchTextField 的 font 属性会导致 TextField 高度异常，从而导致 searchBarContainerView 的高度异常，临时修复一下
                Class _UISearchBarContainerViewClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBar", @"ContainerView"]);
                OverrideImplementation(_UISearchBarContainerViewClass, @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIView *selfObject, CGRect frame) {
                        UISearchBar *searchBar = selfObject.subviews.firstObject;
                        if ([searchBar isKindOfClass:[UISearchBar class]]) {
                            if (searchBar.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView && searchBar.cigam_isActive) {
                                // 刘海屏即使隐藏了 statusBar 也不会影响 containerView 的高度，要把 statusBar 计算在内
                                CGFloat currentStatusBarHeight = IS_NOTCHED_SCREEN ? StatusBarHeightConstant : StatusBarHeight;
                                if (frame.origin.y < currentStatusBarHeight + NavigationBarHeight) {
                                    // 非刘海屏在隐藏了 statusBar 后，如果只计算激活时的高度则为 50，这种情况下应该取 56
                                    frame.size.height = MAX(UISearchBar.cigamsb_seachBarDefaultActiveHeight + currentStatusBarHeight, 56);
                                    frame.origin.y = 0;
                                }
                            }
                        }
                        void (*originSelectorIMP)(id, SEL, CGRect);
                        originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, frame);
                    };
                });
            }
        }
        
        OverrideImplementation(NSClassFromString([NSString stringWithFormat:@"%@%@",@"UISearchBarText", @"Field"]), @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITextField *textField, CGRect frame) {
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)textField.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)textField.superview.superview;
                }
                
                NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                
                if (searchBar) {
                    frame = [searchBar cigamsb_adjustedSearchTextFieldFrameByOriginalFrame:frame];
                }
                
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(textField, originCMD, frame);
                
                [searchBar cigamsb_searchTextFieldFrameDidChange];
            };
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(layoutSubviews), ^(UISearchBar *selfObject) {
            
            // 修复 iOS 13 backgroundView 没有撑开到顶部的问题
            if (IOS_VERSION >= 13.0 && selfObject.cigam_usedAsTableHeaderView && selfObject.cigam_isActive) {
                selfObject.cigam_backgroundView.cigam_height = StatusBarHeightConstant + selfObject.cigam_height;
                selfObject.cigam_backgroundView.cigam_top = -StatusBarHeightConstant;
            }
            [selfObject cigamsb_fixDismissingAnimationIfNeeded];
            [selfObject cigamsb_fixSearchResultsScrollViewContentInsetIfNeeded];
            
        });
        
        OverrideImplementation([UISearchBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, CGRect frame) {
                
                frame = [selfObject cigamsb_adjustedSearchBarFrameByOriginalFrame:frame];
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
            };
        });
        
        // [UIKit Bug] 当 UISearchController.searchBar 作为 tableHeaderView 使用时，顶部可能出现 1px 的间隙导致露出背景色
        // https://github.com/Tencent/CIGAM_iOS/issues/950
        OverrideImplementation([UISearchBar class], NSSelectorFromString(@"_setMaskBounds:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, CGRect firstArgv) {
                
                BOOL shouldFixBug = selfObject.cigam_fixMaskViewLayoutBugAutomatically
                && selfObject.cigam_searchController
                && [selfObject.superview isKindOfClass:UITableView.class]
                && ((UITableView *)selfObject.superview).tableHeaderView == selfObject;
                if (shouldFixBug) {
                    firstArgv = CGRectMake(CGRectGetMinX(firstArgv), CGRectGetMinY(firstArgv) - PixelOne, CGRectGetWidth(firstArgv), CGRectGetHeight(firstArgv) + PixelOne);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        // [UIKit Bug] 将 UISearchBar 作为 UITableView.tableHeaderView 使用时，如果列表内容不满一屏，可能出现搜索框不可视的问题
        // https://github.com/Tencent/CIGAM_iOS/issues/1207
        if (@available(iOS 11.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(didMoveToSuperview), ^(UISearchBar *selfObject) {
                if (selfObject.superview && CGRectGetHeight(selfObject.subviews.firstObject.frame) != CGRectGetHeight(selfObject.bounds)) {
                    BeginIgnorePerformSelectorLeaksWarning
                    [selfObject.cigam_searchController performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@MaskIfNecessary", @"_update", @"SearchBar"])];
                    EndIgnorePerformSelectorLeaksWarning
                }
            });
        }
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISearchBar class], @selector(initWithFrame:), CGRect, UISearchBar *, ^UISearchBar *(UISearchBar *selfObject, CGRect firstArgv, UISearchBar *originReturnValue) {
            [originReturnValue cigamsb_didInitialize];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISearchBar class], @selector(initWithCoder:), NSCoder *, UISearchBar *, ^UISearchBar *(UISearchBar *selfObject, NSCoder *firstArgv, UISearchBar *originReturnValue) {
            [originReturnValue cigamsb_didInitialize];
            return originReturnValue;
        });
    });
}

- (void)cigamsb_didInitialize {
    self.cigam_alwaysEnableCancelButton = YES;
    self.cigam_showsLeftAccessoryView = YES;
    self.cigam_showsRightAccessoryView = YES;
    
    if (CIGAMCMIActivated && ShouldFixSearchBarMaskViewLayoutBug) {
        self.cigam_fixMaskViewLayoutBugAutomatically = YES;
    }
}

static char kAssociatedObjectKey_centerPlaceholder;
- (void)setCigam_centerPlaceholder:(BOOL)cigam_centerPlaceholder {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_centerPlaceholder, @(cigam_centerPlaceholder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    __weak __typeof(self)weakSelf = self;
    if (cigam_centerPlaceholder) {
        self.cigam_textField.cigam_layoutSubviewsBlock = ^(UITextField * _Nonnull textField) {
            
            // 某些中间状态 textField 的宽度会出现负值，但由于 CGRectGetWidth() 一定是返回正值的，所以这里必须用 bounds.size.width 的方式取值，而不是用 CGRectGetWidth()
            if (textField.bounds.size.width <= 0) return;
            
            if (textField.isEditing || textField.text.length > 0) {
                weakSelf.cigamsb_centerPlaceholderCachedWidth1 = 0;
                weakSelf.cigamsb_centerPlaceholderCachedWidth2 = 0;
                if (!UIOffsetEqualToOffset(UIOffsetZero, [weakSelf positionAdjustmentForSearchBarIcon:UISearchBarIconSearch])) {
                    [weakSelf setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
                    [textField layoutIfNeeded];// 在切换搜索状态时要让 positionAdjustment 立即生效，才能看到动画效果
                }
            } else {
                UIView *leftView = [textField cigam_valueForKey:@"leftView"];
                UILabel *label = [textField cigam_valueForKey:@"placeholderLabel"];
                CGFloat width = CGRectGetMaxX(label.frame) - CGRectGetMinX(leftView.frame);
                if (fabs(CGRectGetWidth(textField.bounds) - weakSelf.cigamsb_centerPlaceholderCachedWidth1) > 1 || fabs(width - weakSelf.cigamsb_centerPlaceholderCachedWidth2) > 1) {
                    weakSelf.cigamsb_centerPlaceholderCachedWidth1 = CGRectGetWidth(textField.bounds);
                    weakSelf.cigamsb_centerPlaceholderCachedWidth2 = width;
                    CGFloat searchIconDefaultMarginLeft = 6; // 系统的放大镜 icon 默认距离 textField 左边就是这个值，计算居中时要考虑进去，因为 positionAdjustment 是基于系统默认布局的基础上做偏移的
                    CGFloat horizontal = (weakSelf.cigamsb_centerPlaceholderCachedWidth1 - weakSelf.cigamsb_centerPlaceholderCachedWidth2) / 2.0 - searchIconDefaultMarginLeft;// 这里没有用 CGFloatGetCenter 是为了避免 iOS 12 及以下 iPhone 8 Plus tableView 显示右边的索引条时，每次算出来都差1，第一次49第二次50第三次49...陷入死循环，干脆不要操作精度取整
                    [weakSelf setPositionAdjustment:UIOffsetMake(horizontal, 0) forSearchBarIcon:UISearchBarIconSearch];
                    [textField layoutIfNeeded];// 在切换搜索状态时要让 positionAdjustment 立即生效，才能看到动画效果
                }
            }
        };
        [self.cigam_textField setNeedsLayout];
    } else {
        self.cigam_textField.cigam_layoutSubviewsBlock = nil;
        self.cigamsb_centerPlaceholderCachedWidth1 = 0;
        self.cigamsb_centerPlaceholderCachedWidth2 = 0;
        [self setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
}

- (BOOL)cigam_centerPlaceholder {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_centerPlaceholder)) boolValue];
}

static char kAssociatedObjectKey_PlaceholderColor;
- (void)setCigam_placeholderColor:(UIColor *)cigam_placeholderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor, cigam_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
        self.placeholder = self.placeholder;
    }
}

- (UIColor *)cigam_placeholderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor);
}

static char kAssociatedObjectKey_TextColor;
- (void)setCigam_textColor:(UIColor *)cigam_textColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_TextColor, cigam_textColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_textField.textColor = cigam_textColor;
}

- (UIColor *)cigam_textColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_TextColor);
}

static char kAssociatedObjectKey_font;
- (void)setCigam_font:(UIFont *)cigam_font {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_font, cigam_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
        self.placeholder = self.placeholder;
    }
    
    // 更新输入框的文字样式
    self.cigam_textField.font = cigam_font;
}

- (UIFont *)cigam_font {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_font);
}

- (UITextField *)cigam_textField {
    if (@available(iOS 13.0, *)) {
        return self.searchTextField;
    }
    UITextField *textField = [self cigam_valueForKey:@"searchField"];
    return textField;
}

- (UIButton *)cigam_cancelButton {
    UIButton *cancelButton = [self cigam_valueForKey:@"cancelButton"];
    return cancelButton;
}

static char kAssociatedObjectKey_cancelButtonFont;
- (void)setCigam_cancelButtonFont:(UIFont *)cigam_cancelButtonFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont, cigam_cancelButtonFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cigam_cancelButton.titleLabel.font = cigam_cancelButtonFont;
}

- (UIFont *)cigam_cancelButtonFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont);
}

static char kAssociatedObjectKey_cancelButtonMarginsBlock;
- (void)setCigam_cancelButtonMarginsBlock:(UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))cigam_cancelButtonMarginsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cancelButtonMarginsBlock, cigam_cancelButtonMarginsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.cigam_cancelButton.superview setNeedsLayout];
}

- (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))cigam_cancelButtonMarginsBlock {
    return (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_cancelButtonMarginsBlock);
}

static char kAssociatedObjectKey_textFieldMargins;
- (void)setCigam_textFieldMargins:(UIEdgeInsets)cigam_textFieldMargins {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textFieldMargins, @(cigam_textFieldMargins), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cigamsb_setNeedsLayoutTextField];
}

- (UIEdgeInsets)cigam_textFieldMargins {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textFieldMargins)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_textFieldMarginsBlock;
- (void)setCigam_textFieldMarginsBlock:(UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))cigam_textFieldMarginsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textFieldMarginsBlock, cigam_textFieldMarginsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self cigamsb_setNeedsLayoutTextField];
}

- (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))cigam_textFieldMarginsBlock {
    return (UIEdgeInsets (^)(__kindof UISearchBar * _Nonnull, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_textFieldMarginsBlock);
}

- (UISegmentedControl *)cigam_segmentedControl {
    UISegmentedControl *segmentedControl = [self cigam_valueForKey:@"scopeBar"];
    return segmentedControl;
}

- (BOOL)cigam_isActive {
    return (self.cigam_searchController.isBeingPresented || self.cigam_searchController.isActive);
}

- (UISearchController *)cigam_searchController {
    return [self cigam_valueForKey:@"_searchController"];
}

- (UIView *)cigam_backgroundView {
    BeginIgnorePerformSelectorLeaksWarning
    UIView *backgroundView = [self performSelector:NSSelectorFromString(@"_backgroundView")];
    EndIgnorePerformSelectorLeaksWarning
    return backgroundView;
}

- (void)cigam_styledAsCIGAMSearchBar {
    if (!CIGAMCMIActivated) {
        return;
    }
    
    // 搜索框的字号及 placeholder 的字号
    self.cigam_font = SearchBarFont;

    // 搜索框的文字颜色
    self.cigam_textColor = SearchBarTextColor;

    // placeholder 的文字颜色
    self.cigam_placeholderColor = SearchBarPlaceholderColor;

    self.placeholder = @"搜索";
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;

    // 设置搜索icon
    UIImage *searchIconImage = SearchBarSearchIconImage;
    if (searchIconImage) {
        if (!CGSizeEqualToSize(searchIconImage.size, CGSizeMake(14, 14))) {
            NSLog(@"搜索框放大镜图片（SearchBarSearchIconImage）的大小最好为 (14, 14)，否则会失真，目前的大小为 %@", NSStringFromCGSize(searchIconImage.size));
        }
        [self setImage:searchIconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }

    // 设置搜索右边的清除按钮的icon
    UIImage *clearIconImage = SearchBarClearIconImage;
    if (clearIconImage) {
        [self setImage:clearIconImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    }

    // 设置SearchBar上的按钮颜色
    self.tintColor = SearchBarTintColor;

    // 输入框背景图
    UIImage *searchFieldBackgroundImage = SearchBarTextFieldBackgroundImage;
    if (searchFieldBackgroundImage) {
        [self setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    }
    
    // 输入框边框
    UIColor *textFieldBorderColor = SearchBarTextFieldBorderColor;
    if (textFieldBorderColor) {
        self.cigam_textField.layer.borderWidth = PixelOne;
        self.cigam_textField.layer.borderColor = textFieldBorderColor.CGColor;
    }
    
    // 整条bar的背景
    // 为了让 searchBar 底部的边框颜色支持修改，背景色不使用 barTintColor 的方式去改，而是用 backgroundImage
    UIImage *backgroundImage = SearchBarBackgroundImage;
    if (backgroundImage) {
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefaultPrompt];
    }
}

+ (UIImage *)cigam_generateTextFieldBackgroundImageWithColor:(UIColor *)color {
    // 背景图片的高度会决定输入框的高度，在 iOS 11 及以上，系统默认高度是 36，iOS 10 及以下的高度是 28 的搜索输入框的高度计算:CIGAMKit/UIKitExtensions/UISearchBar+CIGAM.m
    // 至于圆角，输入框会在 UIView 层面控制，背景图里无需处理
    return [[UIImage cigam_imageWithColor:color size:self.cigamsb_textFieldDefaultSize cornerRadius:0] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

+ (UIImage *)cigam_generateBackgroundImageWithColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor {
    UIImage *backgroundImage = nil;
    if (backgroundColor || borderColor) {
        backgroundImage = [UIImage cigam_imageWithColor:backgroundColor ?: UIColorWhite size:CGSizeMake(10, 10) cornerRadius:0];
        if (borderColor) {
            backgroundImage = [backgroundImage cigam_imageWithBorderColor:borderColor borderWidth:PixelOne borderPosition:CIGAMImageBorderPositionBottom];
        }
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    }
    return backgroundImage;
}

#pragma mark - Left Accessory View

static char kAssociatedObjectKey_showsLeftAccessoryView;
- (void)cigam_setShowsLeftAccessoryView:(BOOL)showsLeftAccessoryView animated:(BOOL)animated {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_showsLeftAccessoryView, @(showsLeftAccessoryView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (animated) {
        if (showsLeftAccessoryView) {
            self.cigam_leftAccessoryView.hidden = NO;
            self.cigam_leftAccessoryView.cigam_frameApplyTransform = CGRectSetXY(self.cigam_leftAccessoryView.frame, -CGRectGetWidth(self.cigam_leftAccessoryView.frame), CGRectGetMinYVerticallyCenter(self.cigam_textField.frame, self.cigam_leftAccessoryView.frame));
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self cigamsb_updateCustomTextFieldMargins];
            } completion:nil];
        } else {
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.cigam_leftAccessoryView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(self.cigam_leftAccessoryView.frame), 0);
                [self cigamsb_updateCustomTextFieldMargins];
            } completion:^(BOOL finished) {
                self.cigam_leftAccessoryView.hidden = YES;
                self.cigam_leftAccessoryView.transform = CGAffineTransformIdentity;
            }];
        }
    } else {
        self.cigam_leftAccessoryView.hidden = !showsLeftAccessoryView;
        [self cigamsb_updateCustomTextFieldMargins];
    }
}

- (void)setCigam_showsLeftAccessoryView:(BOOL)cigam_showsLeftAccessoryView {
    [self cigam_setShowsLeftAccessoryView:cigam_showsLeftAccessoryView animated:NO];
}

- (BOOL)cigam_showsLeftAccessoryView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_showsLeftAccessoryView)) boolValue];
}

static char kAssociatedObjectKey_leftAccessoryView;
- (void)setCigam_leftAccessoryView:(UIView *)cigam_leftAccessoryView {
    if (self.cigam_leftAccessoryView != cigam_leftAccessoryView) {
        [self.cigam_leftAccessoryView removeFromSuperview];
        [self.cigam_textField.superview addSubview:cigam_leftAccessoryView];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryView, cigam_leftAccessoryView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    cigam_leftAccessoryView.hidden = !self.cigam_showsLeftAccessoryView;
    [cigam_leftAccessoryView sizeToFit];
    
    [self cigamsb_updateCustomTextFieldMargins];
}

- (UIView *)cigam_leftAccessoryView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryView);
}

static char kAssociatedObjectKey_leftAccessoryViewMargins;
- (void)setCigam_leftAccessoryViewMargins:(UIEdgeInsets)cigam_leftAccessoryViewMargins {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryViewMargins, @(cigam_leftAccessoryViewMargins), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cigamsb_updateCustomTextFieldMargins];
}

- (UIEdgeInsets)cigam_leftAccessoryViewMargins {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_leftAccessoryViewMargins)) UIEdgeInsetsValue];
}

// 这个方法会在 textField 调整完布局后才调用，所以可以直接基于 textField 当前的布局去计算布局
- (void)cigamsb_adjustLeftAccessoryViewFrameAfterTextFieldLayout {
    if (self.cigam_leftAccessoryView && !self.cigam_leftAccessoryView.hidden) {
        self.cigam_leftAccessoryView.cigam_frameApplyTransform = CGRectSetXY(self.cigam_leftAccessoryView.frame, CGRectGetMinX(self.cigam_textField.frame) - [UISearchBar cigamsb_textFieldDefaultMargins].left - self.cigam_leftAccessoryViewMargins.right - CGRectGetWidth(self.cigam_leftAccessoryView.frame), CGRectGetMinYVerticallyCenter(self.cigam_textField.frame, self.cigam_leftAccessoryView.frame));
    }
}

#pragma mark - Right Accessory View

static char kAssociatedObjectKey_showsRightAccessoryView;
- (void)cigam_setShowsRightAccessoryView:(BOOL)showsRightAccessoryView animated:(BOOL)animated {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_showsRightAccessoryView, @(showsRightAccessoryView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (animated) {
        BOOL shouldAnimateAlpha = self.showsCancelButton;// 由于 rightAccessoryView 会从 cancelButton 那边飞过来，会有一点重叠，所以加一个 alpha 过渡
        if (showsRightAccessoryView) {
            self.cigam_rightAccessoryView.hidden = NO;
            self.cigam_rightAccessoryView.cigam_frameApplyTransform = CGRectSetXY(self.cigam_rightAccessoryView.frame, CGRectGetWidth(self.cigam_rightAccessoryView.superview.bounds), CGRectGetMinYVerticallyCenter(self.cigam_textField.frame, self.cigam_rightAccessoryView.frame));
            if (shouldAnimateAlpha) {
                self.cigam_rightAccessoryView.alpha = 0;
            }
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self cigamsb_updateCustomTextFieldMargins];
                if (shouldAnimateAlpha) {
                    self.cigam_rightAccessoryView.alpha = 1;
                }
            } completion:nil];
        } else {
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.cigam_rightAccessoryView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.cigam_rightAccessoryView.superview.bounds) - CGRectGetMinX(self.cigam_rightAccessoryView.frame), 0);
                [self cigamsb_updateCustomTextFieldMargins];
            } completion:^(BOOL finished) {
                self.cigam_rightAccessoryView.hidden = YES;
                self.cigam_rightAccessoryView.transform = CGAffineTransformIdentity;
                self.cigam_rightAccessoryView.alpha = 1;
            }];
            if (shouldAnimateAlpha) {
                [UIView animateWithDuration:.18 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.cigam_rightAccessoryView.alpha = 0;
                } completion:nil];
            }
        }
    } else {
        self.cigam_rightAccessoryView.hidden = !showsRightAccessoryView;
        [self cigamsb_updateCustomTextFieldMargins];
    }
}

- (void)setCigam_showsRightAccessoryView:(BOOL)cigam_showsRightAccessoryView {
    [self cigam_setShowsRightAccessoryView:cigam_showsRightAccessoryView animated:NO];
}

- (BOOL)cigam_showsRightAccessoryView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_showsRightAccessoryView)) boolValue];
}

static char kAssociatedObjectKey_rightAccessoryView;
- (void)setCigam_rightAccessoryView:(UIView *)cigam_rightAccessoryView {
    if (self.cigam_rightAccessoryView != cigam_rightAccessoryView) {
        [self.cigam_rightAccessoryView removeFromSuperview];
        [self.cigam_textField.superview addSubview:cigam_rightAccessoryView];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryView, cigam_rightAccessoryView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    cigam_rightAccessoryView.hidden = !self.cigam_showsRightAccessoryView;
    [cigam_rightAccessoryView sizeToFit];
    
    [self cigamsb_updateCustomTextFieldMargins];
}

- (UIView *)cigam_rightAccessoryView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryView);
}

static char kAssociatedObjectKey_rightAccessoryViewMargins;
- (void)setCigam_rightAccessoryViewMargins:(UIEdgeInsets)cigam_rightAccessoryViewMargins {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryViewMargins, @(cigam_rightAccessoryViewMargins), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cigamsb_updateCustomTextFieldMargins];
}

- (UIEdgeInsets)cigam_rightAccessoryViewMargins {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_rightAccessoryViewMargins)) UIEdgeInsetsValue];
}

- (void)cigamsb_updateCustomTextFieldMargins {
    // 用 cigam_showsLeftAccessoryView 而不是用 !cigam_leftAccessoryView.hidden 是因为做动画时可能 hidden 值还没更新，所以用标志位来区分
    BOOL shouldShowLeftAccessoryView = self.cigam_showsLeftAccessoryView && self.cigam_leftAccessoryView;
    BOOL shouldShowRightAccessoryView = self.cigam_showsRightAccessoryView && self.cigam_rightAccessoryView;
    CGFloat leftMargin = shouldShowLeftAccessoryView ? CGRectGetWidth(self.cigam_leftAccessoryView.frame) + UIEdgeInsetsGetHorizontalValue(self.cigam_leftAccessoryViewMargins) : 0;
    CGFloat rightMargin = shouldShowRightAccessoryView ? CGRectGetWidth(self.cigam_rightAccessoryView.frame) + UIEdgeInsetsGetHorizontalValue(self.cigam_rightAccessoryViewMargins) : 0;
    
    if (self.cigamsb_customTextFieldMargins.left != leftMargin || self.cigamsb_customTextFieldMargins.right != rightMargin) {
        self.cigamsb_customTextFieldMargins = UIEdgeInsetsMake(self.cigamsb_customTextFieldMargins.top, leftMargin, self.cigamsb_customTextFieldMargins.bottom, rightMargin);
        [self cigamsb_setNeedsLayoutTextField];
    }
}

// 这个方法会在 textField 调整完布局后才调用，所以可以直接基于 textField 当前的布局去计算布局
- (void)cigamsb_adjustRightAccessoryViewFrameAfterTextFieldLayout {
    if (self.cigam_rightAccessoryView && !self.cigam_rightAccessoryView.hidden) {
        self.cigam_rightAccessoryView.cigam_frameApplyTransform = CGRectSetXY(self.cigam_rightAccessoryView.frame, CGRectGetMaxX(self.cigam_textField.frame) + [UISearchBar cigamsb_textFieldDefaultMargins].right + self.cigam_textFieldMargins.right + self.cigam_rightAccessoryViewMargins.left, CGRectGetMinYVerticallyCenter(self.cigam_textField.frame, self.cigam_rightAccessoryView.frame));
    }
}

#pragma mark - Layout

- (void)cigamsb_setNeedsLayoutTextField {
    if (self.cigam_textField && !CGRectIsEmpty(self.cigam_textField.frame)) {
        if (@available(iOS 13.0, *)) {
            [self.cigam_textField.superview setNeedsLayout];
            [self.cigam_textField.superview layoutIfNeeded];
        } else {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }
}

- (BOOL)cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView {
    if (@available(iOS 11, *)) {
        return self.cigam_usedAsTableHeaderView && self.cigam_searchController.hidesNavigationBarDuringPresentation;
    }
    return NO;
}

- (CGRect)cigamsb_adjustCancelButtonFrame:(CGRect)followingFrame {
    if (self.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView) {
        CGRect textFieldFrame = self.cigam_textField.frame;
        
        BOOL shouldFixCancelButton = NO;
        if (@available(iOS 13.0, *)) {
            shouldFixCancelButton = YES;// iOS 13 当 searchBar 作为 tableHeaderView 使用时，并且非搜索状态下 searchBar.showsCancelButton = YES，则进入搜搜状态后再退出，可看到 cancelButton 下降过程中会有抖动
        } else {
            shouldFixCancelButton = self.cigam_isActive;
        }
        if (shouldFixCancelButton) {
            followingFrame = CGRectSetY(followingFrame, CGRectGetMinYVerticallyCenter(textFieldFrame, followingFrame));
        }
    }
    
    if (self.cigam_cancelButtonMarginsBlock) {
        UIEdgeInsets insets = self.cigam_cancelButtonMarginsBlock(self, self.cigam_isActive);
        followingFrame = CGRectInsetEdges(followingFrame, insets);
    }
    return followingFrame;
}

- (void)cigamsb_adjustSegmentedControlFrameIfNeeded {
    if (!self.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if (self.cigam_isActive) {
        CGRect textFieldFrame = self.cigam_textField.frame;
        if (self.cigam_segmentedControl.superview.cigam_top < self.cigam_textField.cigam_bottom) {
            // scopeBar 显示在搜索框右边
            self.cigam_segmentedControl.superview.cigam_top = CGRectGetMinYVerticallyCenter(textFieldFrame, self.cigam_segmentedControl.superview.frame);
        }
    }
}

- (CGRect)cigamsb_adjustedSearchBarFrameByOriginalFrame:(CGRect)frame {
    if (!self.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView) return frame;
    
    // 重写 setFrame: 是为了这个 issue：https://github.com/Tencent/CIGAM_iOS/issues/233
    // iOS 11 下用 tableHeaderView 的方式使用 searchBar 的话，进入搜索状态时 y 偏上了，导致间距错乱
    // iOS 13 iPad 在退出动画时 y 值可能为负，需要修正
    
    if (self.cigam_searchController.isBeingDismissed && CGRectGetMinY(frame) < 0) {
        frame = CGRectSetY(frame, 0);
    }
    
    if (!self.cigam_isActive) {
        return frame;
    }
    
    if (IS_NOTCHED_SCREEN) {
        // 竖屏
        if (CGRectGetMinY(frame) == 38) {
            // searching
            frame = CGRectSetY(frame, 44);
        }
        
        // 全面屏 iPad
        if (CGRectGetMinY(frame) == 18) {
            // searching
            frame = CGRectSetY(frame, 24);
        }
        
        // 横屏
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    } else {
        
        // 竖屏
        if (CGRectGetMinY(frame) == 14) {
            frame = CGRectSetY(frame, 20);
        }
        
        // 横屏
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    }
    // 强制在激活状态下 高度也为 56，方便后续做平滑过渡动画 (iOS 11 默认下，非刘海屏的机器激活后为 50，刘海屏激活后为 55)
    if (frame.size.height != 56) {
        frame.size.height = 56;
    }
    return frame;
}

- (CGRect)cigamsb_adjustedSearchTextFieldFrameByOriginalFrame:(CGRect)frame {
    if (self.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView) {
        if (@available(iOS 14.0, *)) {
            // iOS 14 beta 1 修改了 searchTextField 的 font 属性会导致 TextField 高度异常，临时修复一下
            CGFloat fixedHeight = UISearchBar.cigamsb_textFieldDefaultSize.height;
            CGFloat offset = fixedHeight - frame.size.height;
            frame.origin.y -= offset / 2.0;
            frame.size.height = fixedHeight;
        }
        if (self.cigam_isActive) {
            BOOL statusBarHidden = NO;
            if (@available(iOS 13.0, *)) {
                statusBarHidden = self.window.windowScene.statusBarManager.statusBarHidden;
            } else {
                statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
            }
            CGFloat visibleHeight = statusBarHidden ? 56 : 50;
            frame.origin.y = (visibleHeight - self.cigam_textField.cigam_height) / 2;
        } else if (self.cigam_searchController.isBeingDismissed) {
            frame.origin.y = (56 - self.cigam_textField.cigam_height) / 2;
        }
    }
    
    // apply cigam_textFieldMargins
    UIEdgeInsets textFieldMargins = UIEdgeInsetsZero;
    if (self.cigam_textFieldMarginsBlock) {
        textFieldMargins = self.cigam_textFieldMarginsBlock(self, self.cigam_isActive);
    } else {
        textFieldMargins = self.cigam_textFieldMargins;
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(textFieldMargins, UIEdgeInsetsZero)) {
        frame = CGRectInsetEdges(frame, textFieldMargins);
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.cigamsb_customTextFieldMargins, UIEdgeInsetsZero)) {
        frame = CGRectInsetEdges(frame, self.cigamsb_customTextFieldMargins);
    }
    
    return frame;
}

- (void)cigamsb_searchTextFieldFrameDidChange {
    // apply SearchBarTextFieldCornerRadius
    CGFloat textFieldCornerRadius = SearchBarTextFieldCornerRadius;
    if (textFieldCornerRadius != 0) {
        textFieldCornerRadius = textFieldCornerRadius > 0 ? textFieldCornerRadius : CGRectGetHeight(self.cigam_textField.frame) / 2.0;
    }
    self.cigam_textField.layer.cornerRadius = textFieldCornerRadius;
    self.cigam_textField.clipsToBounds = textFieldCornerRadius != 0;
    
    [self cigamsb_adjustLeftAccessoryViewFrameAfterTextFieldLayout];
    [self cigamsb_adjustRightAccessoryViewFrameAfterTextFieldLayout];
    [self cigamsb_adjustSegmentedControlFrameIfNeeded];
}

- (void)cigamsb_fixDismissingAnimationIfNeeded {
    if (!self.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    
    if (self.cigam_searchController.isBeingDismissed) {
        
        if (IS_NOTCHED_SCREEN && self.frame.origin.y == 43) { // 修复刘海屏下，系统计算少了一个 pt
            self.frame = CGRectSetY(self.frame, StatusBarHeightConstant);
        }
        
        UIView *searchBarContainerView = self.superview;
        // 每次激活搜索框，searchBarContainerView 都会重新创建一个
        if (searchBarContainerView.layer.masksToBounds == YES) {
            searchBarContainerView.layer.masksToBounds = NO;
            // backgroundView 被 searchBarContainerView masksToBounds 裁减掉的底部。
            CGFloat backgroundViewBottomClipped = CGRectGetMaxY([searchBarContainerView convertRect:self.cigam_backgroundView.frame fromView:self.cigam_backgroundView.superview]) - CGRectGetHeight(searchBarContainerView.bounds);
            // UISeachbar 取消激活时，如果 BackgroundView 底部超出了 searchBarContainerView，需要以动画的形式来过渡：
            if (backgroundViewBottomClipped > 0) {
                CGFloat previousHeight = self.cigam_backgroundView.cigam_height;
                [UIView performWithoutAnimation:^{
                    // 先减去 backgroundViewBottomClipped 使得 backgroundView 和 searchBarContainerView 底部对齐，由于这个时机是包裹在 animationBlock 里的，所以要包裹在 performWithoutAnimation 中来设置
                    self.cigam_backgroundView.cigam_height -= backgroundViewBottomClipped;
                }];
                // 再还原高度，这里在 animationBlock 中，所以会以动画来过渡这个效果
                self.cigam_backgroundView.cigam_height = previousHeight;
                
                // 以下代码为了保持原有的顶部的 mask，否则在 NavigationBar 为透明或者磨砂时，会看到 backgroundView
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddRect(path, NULL, CGRectMake(0, 0, searchBarContainerView.cigam_width, previousHeight));
                maskLayer.path = path;
                searchBarContainerView.layer.mask = maskLayer;
            }
        }
    }
}

- (void)cigamsb_fixSearchResultsScrollViewContentInsetIfNeeded {
    if (!self.cigamsb_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if (self.cigam_isActive) {
        UIViewController *searchResultsController = self.cigam_searchController.searchResultsController;
        if (searchResultsController && [searchResultsController isViewLoaded]) {
            UIView *view = searchResultsController.view;
            UIScrollView *scrollView =
            [view isKindOfClass:UIScrollView.class] ? view :
            [view.subviews.firstObject isKindOfClass:UIScrollView.class] ? view.subviews.firstObject : nil;
            UIView *searchBarContainerView = self.superview;
            if (scrollView && searchBarContainerView) {
                scrollView.contentInset = UIEdgeInsetsMake(searchBarContainerView.cigam_height, 0, 0, 0);
            }
        }
    }
}

static CGSize textFieldDefaultSize;
+ (CGSize)cigamsb_textFieldDefaultSize {
    if (CGSizeIsEmpty(textFieldDefaultSize)) {
        textFieldDefaultSize = CGSizeMake(60, 28);
        // 在 iOS 11 及以上，搜索输入框系统默认高度是 36，iOS 10 及以下的高度是 28
        if (@available(iOS 11.0, *)) {
            textFieldDefaultSize.height = 36;
        }
    }
    return textFieldDefaultSize;
}

// 系统 textField 默认就带有左右间距，也即当 cigam_textFieldMargins 为 0 时输入框与左右的间距，实际计算时要自己叠加上 safeAreaInsets 的值
static UIEdgeInsets textFieldDefaultMargins;
+ (UIEdgeInsets)cigamsb_textFieldDefaultMargins {
    if (UIEdgeInsetsEqualToEdgeInsets(textFieldDefaultMargins, UIEdgeInsetsZero)) {
        textFieldDefaultMargins = UIEdgeInsetsMake(10, 8, 10, 8);
    }
    return textFieldDefaultMargins;
}

static CGFloat seachBarDefaultActiveHeight;
+ (CGFloat)cigamsb_seachBarDefaultActiveHeight {
    if (!seachBarDefaultActiveHeight) {
        seachBarDefaultActiveHeight = IS_NOTCHED_SCREEN ? 55 : 50;
    }
    return seachBarDefaultActiveHeight;
}

@end
