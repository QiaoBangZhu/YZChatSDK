/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMToolbarButton.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CIGAMToolbarButtonType) {
    CIGAMToolbarButtonTypeNormal,            // 普通工具栏按钮
    CIGAMToolbarButtonTypeRed,               // 工具栏红色按钮，用于删除等警告性操作
    CIGAMToolbarButtonTypeImage,             // 图标类型的按钮
};

/**
 *  `CIGAMToolbarButton`是用于底部工具栏的按钮
 */
@interface CIGAMToolbarButton : UIButton

/// 获取当前按钮的type
@property(nonatomic, assign, readonly) CIGAMToolbarButtonType type;

/**
 *  工具栏按钮的初始化函数
 *  @param type  按钮类型
 */
- (instancetype)initWithType:(CIGAMToolbarButtonType)type;

/**
 *  工具栏按钮的初始化函数
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(CIGAMToolbarButtonType)type title:(nullable NSString *)title;

/**
 *  工具栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(UIImage *)image;

/// 在原有的CIGAMToolbarButton上创建一个UIBarButtonItem
+ (nullable UIBarButtonItem *)barButtonItemWithToolbarButton:(CIGAMToolbarButton *)button target:(nullable id)target action:(nullable SEL)selector;

/// 创建一个特定type的UIBarButtonItem
+ (nullable UIBarButtonItem *)barButtonItemWithType:(CIGAMToolbarButtonType)type title:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)selector;

/// 创建一个图标类型的UIBarButtonItem
+ (nullable UIBarButtonItem *)barButtonItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)selector;

@end

NS_ASSUME_NONNULL_END
