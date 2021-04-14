/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMScrollAnimator.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/S/30.
//

#import "CIGAMScrollAnimator.h"
#import "CIGAMMultipleDelegates.h"
#import "UIScrollView+CIGAM.h"
#import "UIView+CIGAM.h"

@interface CIGAMScrollAnimator ()

@property(nonatomic, assign) BOOL scrollViewMultipleDelegatesEnabledBeforeSet;
@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegateBeforeSet;
@end

@implementation CIGAMScrollAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (void)setScrollView:(__kindof UIScrollView *)scrollView {
    if (scrollView) {
        self.scrollViewMultipleDelegatesEnabledBeforeSet = scrollView.cigam_multipleDelegatesEnabled;
        self.scrollViewDelegateBeforeSet = scrollView.delegate;
        scrollView.cigam_multipleDelegatesEnabled = YES;
        scrollView.delegate = self;
    } else {
        _scrollView.cigam_multipleDelegatesEnabled = self.scrollViewMultipleDelegatesEnabledBeforeSet;
        if (_scrollView.cigam_multipleDelegatesEnabled) {
            [((CIGAMMultipleDelegates *)_scrollView.delegate) removeDelegate:self];
        } else {
            _scrollView.delegate = self.scrollViewDelegateBeforeSet;
        }
    }
    _scrollView = scrollView;
}

- (void)updateScroll {
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.enabled && scrollView == self.scrollView && self.didScrollBlock && scrollView.cigam_visible) {
        self.didScrollBlock(self);
    }
}

@end
