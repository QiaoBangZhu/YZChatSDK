/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CIGAMAnimationHelper.m
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import "CIGAMAnimationHelper.h"
#import "CIGAMCore.h"

#define SpringDefaultMass 1.0
#define SpringDefaultDamping 18.0
#define SpringDefaultStiffness 82.0
#define SpringDefaultInitialVelocity 0.0

@implementation CIGAMAnimationHelper

+ (id)interpolateFromValue:(id)fromValue
                   toValue:(id)toValue
                      time:(CGFloat)time
                    easing:(CIGAMAnimationEasings)easing {
    return [self interpolateSpringFromValue:fromValue toValue:toValue time:time mass:SpringDefaultMass damping:SpringDefaultDamping stiffness:SpringDefaultStiffness initialVelocity:SpringDefaultInitialVelocity easing:easing];
}

/*
 * 插值器，遇到新的类型再添加
 */
+ (id)interpolateSpringFromValue:(id)fromValue
                         toValue:(id)toValue
                            time:(CGFloat)time
                            mass:(CGFloat)mass
                         damping:(CGFloat)damping
                       stiffness:(CGFloat)stiffness
                 initialVelocity:(CGFloat)initialVelocity
                          easing:(CIGAMAnimationEasings)easing {
    
    if ([fromValue isKindOfClass:[NSNumber class]]) { // NSNumber
        CGFloat from = [fromValue floatValue];
        CGFloat to = [toValue floatValue];
        CGFloat result = cigam_interpolateSpring(from, to, time, easing, mass, damping, stiffness, initialVelocity);
        return [NSNumber numberWithFloat:result];
    }
    
    else if ([fromValue isKindOfClass:[UIColor class]]) { // UIColor
        UIColor *from = (UIColor *)fromValue;
        UIColor *to = (UIColor *)toValue;
        CGFloat fromRed, toRed, curRed = 0;
        CGFloat fromGreen, toGreen, curGreen = 0;
        CGFloat fromBlue, toBlue, curBlue = 0;
        CGFloat fromAlpha, toAlpha, curAlpha = 0;
        [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
        [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
        curRed = cigam_interpolateSpring(fromRed, toRed, time, easing, mass, damping, stiffness, initialVelocity);
        curGreen = cigam_interpolateSpring(fromGreen, toGreen, time, easing, mass, damping, stiffness, initialVelocity);
        curBlue = cigam_interpolateSpring(fromBlue, toBlue, time, easing, mass, damping, stiffness, initialVelocity);
        curAlpha = cigam_interpolateSpring(fromAlpha, toAlpha, time, easing, mass, damping, stiffness, initialVelocity);
        UIColor *result = [UIColor colorWithRed:curRed green:curGreen blue:curBlue alpha:curAlpha];
        return result;
    }
    
    else if ([fromValue isKindOfClass:[NSValue class]]) { // NSValue
        const char *type = [(NSValue *)fromValue objCType];
        if (strcmp(type, @encode(CGPoint)) == 0) {
            CGPoint from = [fromValue CGPointValue];
            CGPoint to = [toValue CGPointValue];
            CGPoint result = CGPointMake(cigam_interpolateSpring(from.x, to.x, time, easing, mass, damping, stiffness, initialVelocity), cigam_interpolateSpring(from.y, to.y, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGPoint:result];
        }
        else if (strcmp(type, @encode(CGSize)) == 0) {
            CGSize from = [fromValue CGSizeValue];
            CGSize to = [toValue CGSizeValue];
            CGSize result = CGSizeMake(cigam_interpolateSpring(from.width, to.width, time, easing, mass, damping, stiffness, initialVelocity), cigam_interpolateSpring(from.height, to.height, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGSize:result];
        }
        else if (strcmp(type, @encode(CGRect)) == 0) {
            CGRect from = [fromValue CGRectValue];
            CGRect to = [toValue CGRectValue];
            CGRect result = CGRectMake(cigam_interpolateSpring(from.origin.x, to.origin.x, time, easing, mass, damping, stiffness, initialVelocity), cigam_interpolateSpring(from.origin.y, to.origin.y, time, easing, mass, damping, stiffness, initialVelocity), cigam_interpolateSpring(from.size.width, to.size.width, time, easing, mass, damping, stiffness, initialVelocity), cigam_interpolateSpring(from.size.height, to.size.height, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGRect:result];
        }
        else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
            CGAffineTransform from = [fromValue CGAffineTransformValue];
            CGAffineTransform to = [toValue CGAffineTransformValue];
            CGAffineTransform result = CGAffineTransformIdentity;
            result.a = cigam_interpolateSpring(from.a, to.a, time, easing, mass, damping, stiffness, initialVelocity);
            result.b = cigam_interpolateSpring(from.b, to.b, time, easing, mass, damping, stiffness, initialVelocity);
            result.c = cigam_interpolateSpring(from.c, to.c, time, easing, mass, damping, stiffness, initialVelocity);
            result.d = cigam_interpolateSpring(from.d, to.d, time, easing, mass, damping, stiffness, initialVelocity);
            result.tx = cigam_interpolateSpring(from.tx, to.tx, time, easing, mass, damping, stiffness, initialVelocity);
            result.ty = cigam_interpolateSpring(from.ty, to.ty, time, easing, mass, damping, stiffness, initialVelocity);
            return [NSValue valueWithCGAffineTransform:result];
        }
        else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
            UIEdgeInsets from = [fromValue UIEdgeInsetsValue];
            UIEdgeInsets to = [toValue UIEdgeInsetsValue];
            UIEdgeInsets result = UIEdgeInsetsZero;
            result.top = cigam_interpolateSpring(from.top, to.top, time, easing, mass, damping, stiffness, initialVelocity);
            result.left = cigam_interpolateSpring(from.left, to.left, time, easing, mass, damping, stiffness, initialVelocity);
            result.bottom = cigam_interpolateSpring(from.bottom, to.bottom, time, easing, mass, damping, stiffness, initialVelocity);
            result.right = cigam_interpolateSpring(from.right, to.right, time, easing, mass, damping, stiffness, initialVelocity);
            return [NSValue valueWithUIEdgeInsets:result];
        }
    }
    
    return (time < 0.5) ? fromValue: toValue;
}

//CGFloat interpolate(CGFloat from, CGFloat to, CGFloat time, CIGAMAnimationEasings easing) {
//    return interpolateSpring(from, to, time, easing, SpringDefaultMass, SpringDefaultDamping, SpringDefaultStiffness, SpringDefaultInitialVelocity);
//}

CGFloat cigam_interpolateSpring(CGFloat from, CGFloat to, CGFloat time, CIGAMAnimationEasings easing, CGFloat springMass, CGFloat springDamping, CGFloat springStiffness, CGFloat springInitialVelocity) {
    switch (easing) {
        case CIGAMAnimationEasingsLinear:
            time = CIGAM_Linear(time);
            break;
        case CIGAMAnimationEasingsEaseInSine:
            time = CIGAM_EaseInSine(time);
            break;
        case CIGAMAnimationEasingsEaseOutSine:
            time = CIGAM_EaseOutSine(time);
            break;
        case CIGAMAnimationEasingsEaseInOutSine:
            time = CIGAM_EaseInOutSine(time);
            break;
        case CIGAMAnimationEasingsEaseInQuad:
            time = CIGAM_EaseInQuad(time);
            break;
        case CIGAMAnimationEasingsEaseOutQuad:
            time = CIGAM_EaseOutQuad(time);
            break;
        case CIGAMAnimationEasingsEaseInOutQuad:
            time = CIGAM_EaseInOutQuad(time);
            break;
        case CIGAMAnimationEasingsEaseInCubic:
            time = CIGAM_EaseInCubic(time);
            break;
        case CIGAMAnimationEasingsEaseOutCubic:
            time = CIGAM_EaseOutCubic(time);
            break;
        case CIGAMAnimationEasingsEaseInOutCubic:
            time = CIGAM_EaseInOutCubic(time);
            break;
        case CIGAMAnimationEasingsEaseInQuart:
            time = CIGAM_EaseInQuart(time);
            break;
        case CIGAMAnimationEasingsEaseOutQuart:
            time = CIGAM_EaseOutQuart(time);
            break;
        case CIGAMAnimationEasingsEaseInOutQuart:
            time = CIGAM_EaseInOutQuart(time);
            break;
        case CIGAMAnimationEasingsEaseInQuint:
            time = CIGAM_EaseInQuint(time);
            break;
        case CIGAMAnimationEasingsEaseOutQuint:
            time = CIGAM_EaseOutQuint(time);
            break;
        case CIGAMAnimationEasingsEaseInOutQuint:
            time = CIGAM_EaseInOutQuint(time);
            break;
        case CIGAMAnimationEasingsEaseInExpo:
            time = CIGAM_EaseInExpo(time);
            break;
        case CIGAMAnimationEasingsEaseOutExpo:
            time = CIGAM_EaseOutExpo(time);
            break;
        case CIGAMAnimationEasingsEaseInOutExpo:
            time = CIGAM_EaseInOutExpo(time);
            break;
        case CIGAMAnimationEasingsEaseInCirc:
            time = CIGAM_EaseInCirc(time);
            break;
        case CIGAMAnimationEasingsEaseOutCirc:
            time = CIGAM_EaseOutCirc(time);
            break;
        case CIGAMAnimationEasingsEaseInOutCirc:
            time = CIGAM_EaseInOutCirc(time);
            break;
        case CIGAMAnimationEasingsEaseInBack:
            time = CIGAM_EaseInBack(time);
            break;
        case CIGAMAnimationEasingsEaseOutBack:
            time = CIGAM_EaseOutBack(time);
            break;
        case CIGAMAnimationEasingsEaseInOutBack:
            time = CIGAM_EaseInOutBack(time);
            break;
        case CIGAMAnimationEasingsEaseInElastic:
            time = CIGAM_EaseInElastic(time);
            break;
        case CIGAMAnimationEasingsEaseOutElastic:
            time = CIGAM_EaseOutElastic(time);
            break;
        case CIGAMAnimationEasingsEaseInOutElastic:
            time = CIGAM_EaseInOutElastic(time);
            break;
        case CIGAMAnimationEasingsEaseInBounce:
            time = CIGAM_EaseInBounce(time);
            break;
        case CIGAMAnimationEasingsEaseOutBounce:
            time = CIGAM_EaseOutBounce(time);
            break;
        case CIGAMAnimationEasingsEaseInOutBounce:
            time = CIGAM_EaseInOutBounce(time);
            break;
        case CIGAMAnimationEasingsSpring:
            time = CIGAM_EaseSpring(time, springMass, springDamping, springStiffness, springInitialVelocity);
            break;
        case CIGAMAnimationEasingsSpringKeyboard:
            time = CIGAM_EaseSpring(time, SpringDefaultMass, SpringDefaultDamping, SpringDefaultStiffness, SpringDefaultInitialVelocity);
            break;
        default:
            time = CIGAM_Linear(time);
            break;
    }
    return (to - from) * time + from;
}

@end
