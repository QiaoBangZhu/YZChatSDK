/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationItem+CIGAM.h
//  cigam
//
//  Created by CIGAM Team on 2020/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationItem (CIGAM)

@property(nonatomic, weak, readonly, nullable) UINavigationBar *cigam_navigationBar;
@property(nonatomic, weak, readonly, nullable) UINavigationController *cigam_navigationController;
@property(nonatomic, weak, readonly, nullable) UIViewController *cigam_viewController;
@property(nonatomic, weak, readonly, nullable) UINavigationItem *cigam_previousItem;
@property(nonatomic, weak, readonly, nullable) UINavigationItem *cigam_nextItem;
@end

NS_ASSUME_NONNULL_END
