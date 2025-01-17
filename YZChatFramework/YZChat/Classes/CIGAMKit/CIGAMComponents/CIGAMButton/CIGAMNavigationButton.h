/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMNavigationButton.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CIGAMNavigationButtonType) {
    CIGAMNavigationButtonTypeNormal,         // 普通导航栏文字按钮
    CIGAMNavigationButtonTypeBold,           // 导航栏加粗按钮
    CIGAMNavigationButtonTypeImage,          // 图标按钮
    CIGAMNavigationButtonTypeBack            // 自定义返回按钮(可以同时带有title)
};

/**
 *  CIGAMNavigationButton 有两部分组成：
 *  一部分是 UIBarButtonItem (CIGAMNavigationButton)，提供比系统更便捷的类方法来快速初始化一个 UIBarButtonItem，推荐首选这种方式（原则是能用系统的尽量用系统的，不满足才用自定义的）。
 *  另一部分就是 CIGAMNavigationButton，会提供一个按钮，作为 customView 给 UIBarButtonItem 使用，这种常用于自定义的返回按钮。
 *  对于第二种按钮，会尽量保证样式、布局看起来都和系统的 UIBarButtonItem 一致，所以内部做了许多 iOS 版本兼容的微调。
 */
@interface CIGAMNavigationButton : UIButton

/**
 *  获取当前按钮的`CIGAMNavigationButtonType`
 */
@property(nonatomic, assign, readonly) CIGAMNavigationButtonType type;

/**
 * UIBarButtonItem 默认都是跟随 tintColor 的，所以这里声明是否让图片也是用 AlwaysTemplate 模式
 * 默认为 YES
 */
@property(nonatomic, assign) BOOL adjustsImageTintColorAutomatically;

/**
 *  导航栏按钮的初始化函数，指定的初始化方法
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(CIGAMNavigationButtonType)type title:(nullable NSString *)title;

/**
 *  导航栏按钮的初始化函数
 *  @param type 按钮类型
 */
- (instancetype)initWithType:(CIGAMNavigationButtonType)type;

/**
 *  导航栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(nullable UIImage *)image;

@end

@interface UIBarButtonItem (CIGAMNavigationButton)

+ (instancetype)cigam_itemWithButton:(CIGAMNavigationButton *)button target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)cigam_itemWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)cigam_itemWithTitle:(NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)cigam_itemWithBoldTitle:(NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)cigam_backItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;

/// 返回一个返回按钮，该返回按钮的文字由配置表 NeedsBackBarButtonItemTitle 和 target 的值决定，如果 NeedsBackBarButtonItemTitle 为 NO，则返回按钮不显示文字，若为 YES，则默认文字为“返回”，但如果 target 为 UIViewController 则会自动获取上一个界面的 title 作为当前返回按钮的文字。
+ (instancetype)cigam_backItemWithTarget:(nullable id)target action:(nullable SEL)action;

/// 返回一个以“×”为图片的关闭按钮，“x”的图片使用配置表 NavBarCloseButtonImage 设置
+ (instancetype)cigam_closeItemWithTarget:(nullable id)target action:(nullable SEL)action;

+ (instancetype)cigam_fixedSpaceItemWithWidth:(CGFloat)width;
+ (instancetype)cigam_flexibleSpaceItem;
@end

NS_ASSUME_NONNULL_END
