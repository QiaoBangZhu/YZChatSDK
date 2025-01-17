/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationItem+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 2020/10/28.
//

#import "UINavigationItem+CIGAM.h"
#import "UIView+CIGAM.h"

@implementation UINavigationItem (CIGAM)

- (UINavigationBar *)cigam_navigationBar {
    // UINavigationItem 内部有个方法可以获取 navigationBar
    if ([self respondsToSelector:@selector(navigationBar)]) {
        return [self performSelector:@selector(navigationBar)];
    }
    return nil;
}

- (UINavigationController *)cigam_navigationController {
    UINavigationBar *navigationBar = self.cigam_navigationBar;
    UINavigationController *navigationController = (UINavigationController *)navigationBar.superview.cigam_viewController;
    if ([navigationController isKindOfClass:UINavigationController.class]) {
        return navigationController;
    }
    return nil;
}

- (UIViewController *)cigam_viewController {
    UINavigationBar *navigationBar = self.cigam_navigationBar;
    UINavigationController *navigationController = self.cigam_navigationController;
    
    if (!navigationBar || !navigationController) return nil;
    
    NSInteger index = [navigationBar.items indexOfObject:self];
    if (index != NSNotFound && index < navigationController.viewControllers.count) {
        UIViewController *viewController = navigationController.viewControllers[index];
        return viewController;
    }
    return nil;
}

- (UINavigationItem *)cigam_previousItem {
    NSArray<UINavigationItem *> *items = self.cigam_navigationBar.items;
    if (!items.count) return nil;
    NSInteger index = [items indexOfObject:self];
    if (index != NSNotFound && index > 0) return items[index - 1];
    return nil;
}

- (UINavigationItem *)cigam_nextItem {
    NSArray<UINavigationItem *> *items = self.cigam_navigationBar.items;
    if (!items.count) return nil;
    NSInteger index = [items indexOfObject:self];
    if (index != NSNotFound && index < items.count - 1) return items[index + 1];
    return nil;
}

@end
