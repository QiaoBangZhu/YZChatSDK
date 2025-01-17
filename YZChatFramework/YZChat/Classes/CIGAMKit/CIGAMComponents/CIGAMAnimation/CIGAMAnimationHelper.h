/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CIGAMAnimationHelper.h
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import <UIKit/UIKit.h>
#import "CIGAMEasings.h"

@interface CIGAMAnimationHelper : NSObject

typedef NS_ENUM(NSInteger, CIGAMAnimationEasings) {
    CIGAMAnimationEasingsLinear,
    CIGAMAnimationEasingsEaseInSine,
    CIGAMAnimationEasingsEaseOutSine,
    CIGAMAnimationEasingsEaseInOutSine,
    CIGAMAnimationEasingsEaseInQuad,
    CIGAMAnimationEasingsEaseOutQuad,
    CIGAMAnimationEasingsEaseInOutQuad,
    CIGAMAnimationEasingsEaseInCubic,
    CIGAMAnimationEasingsEaseOutCubic,
    CIGAMAnimationEasingsEaseInOutCubic,
    CIGAMAnimationEasingsEaseInQuart,
    CIGAMAnimationEasingsEaseOutQuart,
    CIGAMAnimationEasingsEaseInOutQuart,
    CIGAMAnimationEasingsEaseInQuint,
    CIGAMAnimationEasingsEaseOutQuint,
    CIGAMAnimationEasingsEaseInOutQuint,
    CIGAMAnimationEasingsEaseInExpo,
    CIGAMAnimationEasingsEaseOutExpo,
    CIGAMAnimationEasingsEaseInOutExpo,
    CIGAMAnimationEasingsEaseInCirc,
    CIGAMAnimationEasingsEaseOutCirc,
    CIGAMAnimationEasingsEaseInOutCirc,
    CIGAMAnimationEasingsEaseInBack,
    CIGAMAnimationEasingsEaseOutBack,
    CIGAMAnimationEasingsEaseInOutBack,
    CIGAMAnimationEasingsEaseInElastic,
    CIGAMAnimationEasingsEaseOutElastic,
    CIGAMAnimationEasingsEaseInOutElastic,
    CIGAMAnimationEasingsEaseInBounce,
    CIGAMAnimationEasingsEaseOutBounce,
    CIGAMAnimationEasingsEaseInOutBounce,
    CIGAMAnimationEasingsSpring, // 自定义任意弹簧曲线
    CIGAMAnimationEasingsSpringKeyboard // 系统键盘动画曲线
};

/**
 * 动画插值器
 * 根据给定的 easing 曲线，计算出初始值和结束值在当前的时间 time 对应的值。value 目前现在支持 NSNumber、UIColor 以及 NSValue 类型的 CGPoint、CGSize、CGRect、CGAffineTransform、UIEdgeInsets
 * @param fromValue 初始值
 * @param toValue 结束值
 * @param time 当前帧时间
 * @param easing 曲线，见`CIGAMAnimationEasings`
 */
+ (id)interpolateFromValue:(id)fromValue
                   toValue:(id)toValue
                      time:(CGFloat)time
                    easing:(CIGAMAnimationEasings)easing;
/**
 * 动画插值器，支持弹簧参数
 * mass|damping|stiffness|initialVelocity 仅在 CIGAMAnimationEasingsSpring 的时候才生效
 */
+ (id)interpolateSpringFromValue:(id)fromValue
                         toValue:(id)toValue
                            time:(CGFloat)time
                            mass:(CGFloat)mass
                         damping:(CGFloat)damping
                       stiffness:(CGFloat)stiffness
                 initialVelocity:(CGFloat)initialVelocity
                          easing:(CIGAMAnimationEasings)easing;

@end
