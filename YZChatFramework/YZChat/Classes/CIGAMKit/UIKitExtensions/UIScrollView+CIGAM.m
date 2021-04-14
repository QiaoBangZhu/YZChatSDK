/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIScrollView+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 15/7/20.
//

#import "UIScrollView+CIGAM.h"
#import "CIGAMCore.h"
#import "NSNumber+CIGAM.h"
#import "UIView+CIGAM.h"
#import "UIViewController+CIGAM.h"

@interface UIScrollView ()

@property(nonatomic, assign) CGFloat cigamscroll_lastInsetTopWhenScrollToTop;
@property(nonatomic, assign) BOOL cigamscroll_hasSetInitialContentInset;
@end

@implementation UIScrollView (CIGAM)

CIGAMSynthesizeCGFloatProperty(cigamscroll_lastInsetTopWhenScrollToTop, setCigamscroll_lastInsetTopWhenScrollToTop)
CIGAMSynthesizeBOOLProperty(cigamscroll_hasSetInitialContentInset, setCigamscroll_hasSetInitialContentInset)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIScrollView class], @selector(description), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSString *(UIScrollView *selfObject) {
                // call super
                NSString *(*originSelectorIMP)(id, SEL);
                originSelectorIMP = (NSString *(*)(id, SEL))originalIMPProvider();
                NSString *result = originSelectorIMP(selfObject, originCMD);
                
                if (NSThread.isMainThread) {
                    result = ([NSString stringWithFormat:@"%@, contentInset = %@", result, NSStringFromUIEdgeInsets(selfObject.contentInset)]);
                    if (@available(iOS 13.0, *)) {
                        result = result.mutableCopy;
                    }
                }
                return result;
            };
        });
        
        if (@available(iOS 13.0, *)) {
            if (CIGAMCMIActivated && AdjustScrollIndicatorInsetsByContentInsetAdjustment) {
                OverrideImplementation([UIScrollView class], @selector(setContentInsetAdjustmentBehavior:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIScrollView *selfObject, UIScrollViewContentInsetAdjustmentBehavior firstArgv) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior);
                        originSelectorIMP = (void (*)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                        
                        if (firstArgv == UIScrollViewContentInsetAdjustmentNever) {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = NO;
                        } else {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = YES;
                        }
                    };
                });
            }
        }
    });
}

- (BOOL)cigam_alreadyAtTop {
    if (((NSInteger)self.contentOffset.y) == -((NSInteger)self.cigam_contentInset.top)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)cigam_alreadyAtBottom {
    if (!self.cigam_canScroll) {
        return YES;
    }
    
    if (((NSInteger)self.contentOffset.y) == ((NSInteger)self.contentSize.height + self.cigam_contentInset.bottom - CGRectGetHeight(self.bounds))) {
        return YES;
    }
    
    return NO;
}

- (UIEdgeInsets)cigam_contentInset {
    if (@available(iOS 11, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

static char kAssociatedObjectKey_initialContentInset;
- (void)setCigam_initialContentInset:(UIEdgeInsets)cigam_initialContentInset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_initialContentInset, [NSValue valueWithUIEdgeInsets:cigam_initialContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.contentInset = cigam_initialContentInset;
    self.scrollIndicatorInsets = cigam_initialContentInset;
    if (!self.cigamscroll_hasSetInitialContentInset || !self.cigam_viewController || self.cigam_viewController.cigam_visibleState < CIGAMViewControllerDidAppear) {
        [self cigam_scrollToTopUponContentInsetTopChange];
    }
    self.cigamscroll_hasSetInitialContentInset = YES;
}

- (UIEdgeInsets)cigam_initialContentInset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_initialContentInset)) UIEdgeInsetsValue];
}

- (BOOL)cigam_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.cigam_contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.cigam_contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)cigam_scrollToTopForce:(BOOL)force animated:(BOOL)animated {
    if (force || (!force && [self cigam_canScroll])) {
        [self setContentOffset:CGPointMake(-self.cigam_contentInset.left, -self.cigam_contentInset.top) animated:animated];
    }
}

- (void)cigam_scrollToTopAnimated:(BOOL)animated {
    [self cigam_scrollToTopForce:NO animated:animated];
}

- (void)cigam_scrollToTop {
    [self cigam_scrollToTopAnimated:NO];
}

- (void)cigam_scrollToTopUponContentInsetTopChange {
    if (self.cigamscroll_lastInsetTopWhenScrollToTop != self.contentInset.top) {
        [self cigam_scrollToTop];
        self.cigamscroll_lastInsetTopWhenScrollToTop = self.contentInset.top;
    }
}

- (void)cigam_scrollToBottomAnimated:(BOOL)animated {
    if ([self cigam_canScroll]) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.cigam_contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
    }
}

- (void)cigam_scrollToBottom {
    [self cigam_scrollToBottomAnimated:NO];
}

- (void)cigam_stopDeceleratingIfNeeded {
    if (self.decelerating) {
        [self setContentOffset:self.contentOffset animated:NO];
    }
}

- (void)cigam_setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    [UIView cigam_animateWithAnimated:animated duration:.25 delay:0 options:CIGAMViewAnimationOptionsCurveOut animations:^{
        self.contentInset = contentInset;
    } completion:nil];
}

@end
