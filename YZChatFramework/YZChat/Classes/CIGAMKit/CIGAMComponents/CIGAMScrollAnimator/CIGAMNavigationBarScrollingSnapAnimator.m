/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMNavigationBarScrollingSnapAnimator.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/S/30.
//

#import "CIGAMNavigationBarScrollingSnapAnimator.h"
#import "UIViewController+CIGAM.h"
#import "UIScrollView+CIGAM.h"

@interface CIGAMNavigationBarScrollingSnapAnimator ()

@property(nonatomic, assign) BOOL alreadyCalledScrollDownAnimation;
@property(nonatomic, assign) BOOL alreadyCalledScrollUpAnimation;
@end

@implementation CIGAMNavigationBarScrollingSnapAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.adjustsOffsetYWithInsetTopAutomatically = YES;
        
        self.didScrollBlock = ^(CIGAMNavigationBarScrollingSnapAnimator * _Nonnull animator) {
            if (!animator.navigationBar) {
                UINavigationBar *navigationBar = [CIGAMHelper visibleViewController].navigationController.navigationBar;
                if (navigationBar) {
                    animator.navigationBar = navigationBar;
                }
            }
            if (!animator.navigationBar) {
                NSLog(@"无法自动找到 UINavigationBar，请通过 %@.%@ 手动设置一个", NSStringFromClass(animator.class), NSStringFromSelector(@selector(navigationBar)));
                return;
            }
            
            if (animator.animationBlock) {
                if (animator.offsetYReached) {
                    if (animator.continuous || !animator.alreadyCalledScrollDownAnimation) {
                        animator.animationBlock(animator, YES);
                        animator.alreadyCalledScrollDownAnimation = YES;
                        animator.alreadyCalledScrollUpAnimation = NO;
                    }
                } else {
                    if (animator.continuous || !animator.alreadyCalledScrollUpAnimation) {
                        animator.animationBlock(animator, NO);
                        animator.alreadyCalledScrollUpAnimation = YES;
                        animator.alreadyCalledScrollDownAnimation = NO;
                    }
                }
            }
        };
    }
    return self;
}

- (BOOL)offsetYReached {
    UIScrollView *scrollView = self.scrollView;
    CGFloat contentOffsetY = flat(scrollView.contentOffset.y);
    CGFloat offsetYToStartAnimation = flat(self.offsetYToStartAnimation + (self.adjustsOffsetYWithInsetTopAutomatically ? -scrollView.cigam_contentInset.top : 0));
    return contentOffsetY > offsetYToStartAnimation;
}

- (void)setOffsetYToStartAnimation:(CGFloat)offsetYToStartAnimation {
    BOOL valueChanged = _offsetYToStartAnimation != offsetYToStartAnimation;
    _offsetYToStartAnimation = offsetYToStartAnimation;
    if (valueChanged) {
        [self resetState];
    }
}

- (void)setScrollView:(__kindof UIScrollView *)scrollView {
    BOOL scrollViewChanged = self.scrollView != scrollView;
    [super setScrollView:scrollView];
    if (scrollViewChanged) {
        [self resetState];
    }
}

- (void)resetState {
    self.alreadyCalledScrollUpAnimation = NO;
    self.alreadyCalledScrollDownAnimation = NO;
    [self updateScroll];
}

@end
