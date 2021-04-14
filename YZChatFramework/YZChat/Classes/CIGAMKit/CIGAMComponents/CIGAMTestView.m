/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMTestView.m
//  cigam
//
//  Created by CIGAM Team on 16/1/28.
//

#import "CIGAMTestView.h"
#import "CIGAMLog.h"

@implementation CIGAMTestView

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    NSLog(@"CIGAMTestView setTintColor");
}

//- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:backgroundColor];
//}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    CIGAMLog(NSStringFromClass(self.class), @"%@, dealloc", self);
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    BOOL isFrameChanged = CGRectEqualToRect(oldFrame, frame);
    if (!isFrameChanged) {
        CIGAMLog(NSStringFromClass(self.class), @"frame 发生变化, 旧的是 %@, 新的是 %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(frame));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CIGAMLog(NSStringFromClass(self.class), @"frame = %@", NSStringFromCGRect(self.frame));
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    CIGAMLog(NSStringFromClass(self.class), @"superview is %@, newSuperview is %@, window is %@", self.superview, newSuperview, self.window);
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    CIGAMLog(NSStringFromClass(self.class), @"superview is %@, window is %@", self.superview, self.window);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    CIGAMLog(NSStringFromClass(self.class), @"self.window is %@, newWindow is %@", self.window, newWindow);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    CIGAMLog(NSStringFromClass(self.class), @"self.window is %@", self.window);
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    CIGAMLog(NSStringFromClass(self.class), @"subview is %@, subviews.count before addSubview is %@", view, @(self.subviews.count));
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    CIGAMLog(NSStringFromClass(self.class), @"hidden is %@", @(hidden));
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return view;
}

@end

@implementation CIGAMTestWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    CIGAMLog(NSStringFromClass(self.class), @"dealloc, %@", self);
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
}

- (void)makeKeyAndVisible {
    [super makeKeyAndVisible];
}

- (void)makeKeyWindow {
    [super makeKeyWindow];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    CIGAMLog(NSStringFromClass(self.class), @"CIGAMTestWindow, subviews = %@, view = %@", self.subviews, view);
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    BOOL isFrameChanged = CGRectEqualToRect(oldFrame, frame);
    if (isFrameChanged) {
        CIGAMLog(NSStringFromClass(self.class), @"CIGAMTestWindow, frame发生变化, old is %@, new is %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(frame));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CIGAMLog(NSStringFromClass(self.class), @"CIGAMTestWindow, layoutSubviews");
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
}

@end
