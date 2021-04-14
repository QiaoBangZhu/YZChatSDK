/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMTips.h
//  cigam
//
//  Created by CIGAM Team on 15/12/25.
//

#import <UIKit/UIKit.h>
#import "CIGAMToastView.h"

// 自动计算秒数的标志符，在 delay 里面赋值 CIGAMTipsAutomaticallyHideToastSeconds 即可通过自动计算 tips 消失的秒数
extern const NSInteger CIGAMTipsAutomaticallyHideToastSeconds;

/// 默认的 parentView
#define DefaultTipsParentView (UIApplication.sharedApplication.delegate.window)

/**
 * 简单封装了 CIGAMToastView，支持弹出纯文本、loading、succeed、error、info 等五种 tips。如果这些接口还满足不了业务的需求，可以通过 CIGAMTips 的分类自行添加接口。
 * 注意用类方法显示 tips 的话，会导致父类的 willShowBlock 无法正常工作，具体请查看 willShowBlock 的注释。
 * @warning 使用类方法，除了 showLoading 系列方法不会自动隐藏外，其他方法如果没有 delay 参数，则会自动隐藏
 * @see [CIGAMToastView willShowBlock]
 */
@interface CIGAMTips : CIGAMToastView

NS_ASSUME_NONNULL_BEGIN

/// 实例方法：需要自己addSubview，hide之后不会自动removeFromSuperView

- (void)showLoading;
- (void)showLoading:(nullable NSString *)text;
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showWithText:(nullable NSString *)text;
- (void)showWithText:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showSucceed:(nullable NSString *)text;
- (void)showSucceed:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showError:(nullable NSString *)text;
- (void)showError:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showInfo:(nullable NSString *)text;
- (void)showInfo:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

/// 类方法：主要用在局部一次性使用的场景，hide之后会自动removeFromSuperView

+ (CIGAMTips *)createTipsToView:(UIView *)view;

+ (CIGAMTips *)showLoadingInView:(UIView *)view;
+ (CIGAMTips *)showLoading:(nullable NSString *)text inView:(UIView *)view;
+ (CIGAMTips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (CIGAMTips *)showLoading:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (CIGAMTips *)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (CIGAMTips *)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (CIGAMTips *)showWithText:(nullable NSString *)text;
+ (CIGAMTips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (CIGAMTips *)showWithText:(nullable NSString *)text inView:(UIView *)view;
+ (CIGAMTips *)showWithText:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (CIGAMTips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (CIGAMTips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (CIGAMTips *)showSucceed:(nullable NSString *)text;
+ (CIGAMTips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (CIGAMTips *)showSucceed:(nullable NSString *)text inView:(UIView *)view;
+ (CIGAMTips *)showSucceed:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (CIGAMTips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (CIGAMTips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (CIGAMTips *)showError:(nullable NSString *)text;
+ (CIGAMTips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (CIGAMTips *)showError:(nullable NSString *)text inView:(UIView *)view;
+ (CIGAMTips *)showError:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (CIGAMTips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (CIGAMTips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (CIGAMTips *)showInfo:(nullable NSString *)text;
+ (CIGAMTips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText;
+ (CIGAMTips *)showInfo:(nullable NSString *)text inView:(UIView *)view;
+ (CIGAMTips *)showInfo:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (CIGAMTips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (CIGAMTips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

/// 隐藏 tips
+ (void)hideAllTipsInView:(UIView *)view;
+ (void)hideAllTips;

/// 自动隐藏 toast 可以使用这个方法自动计算秒数
+ (NSTimeInterval)smartDelaySecondsForTipsText:(NSString *)text;

NS_ASSUME_NONNULL_END

@end
