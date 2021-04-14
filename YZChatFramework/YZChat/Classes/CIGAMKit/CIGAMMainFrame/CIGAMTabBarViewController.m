/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMTabBarViewController.m
//  cigam
//
//  Created by CIGAM Team on 15/3/29.
//

#import "CIGAMTabBarViewController.h"
#import "CIGAMCore.h"
#import "UIViewController+CIGAM.h"

@implementation CIGAMTabBarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    // subclass hooking
}

#pragma mark - StatusBar

// 如果 childViewController 有声明自己的状态栏样式，则用 childViewController 的，否则用 -[CIGAMTabBarViewController preferredStatusBarStyle] 里的
- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *childViewController = [super childViewControllerForStatusBarStyle];
    if (CIGAMCMIActivated) {
        BOOL hasOverride = childViewController.cigam_preferredStatusBarStyleBlock || [childViewController cigam_hasOverrideUIKitMethod:@selector(preferredStatusBarStyle)];
        if (hasOverride) {
            return childViewController;
        }
        return nil;
    }
    return childViewController;
}

// 只有 childViewController 没声明自己的状态栏样式时才会走到这里
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (CIGAMCMIActivated) {
        return StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
    return [super preferredStatusBarStyle];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return self.presentedViewController ? [self.presentedViewController shouldAutorotate] : ([self.selectedViewController cigam_hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController shouldAutorotate] : YES);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    // fix UIAlertController:supportedInterfaceOrientations was invoked recursively!
    // crash in iOS 9 and show log in iOS 10 and later
    // https://github.com/Tencent/CIGAM_iOS/issues/502
    // https://github.com/Tencent/CIGAM_iOS/issues/632
    UIViewController *visibleViewController = self.presentedViewController;
    if (!visibleViewController || visibleViewController.isBeingDismissed || [visibleViewController isKindOfClass:UIAlertController.class]) {
        visibleViewController = self.selectedViewController;
    }
    
    if ([visibleViewController isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%@%@", @"AV", @"FullScreenViewController"])]) {
        return visibleViewController.supportedInterfaceOrientations;
    }
    
    return [visibleViewController cigam_hasOverrideUIKitMethod:_cmd] ? [visibleViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

#pragma mark - HomeIndicator

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

@end
