/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMLab.h
//  CIGAMKit
//
//  Created by MoLice on 2019/J/8.
//

#ifndef CIGAMLab_h
#define CIGAMLab_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "CIGAMCommonDefines.h"
#import "NSNumber+CIGAM.h"
#import "CIGAMWeakObjectContainer.h"

/**
 以下系列宏用于在 Category 里添加 property 时，可以在 @implementation 里一句代码完成 getter/setter 的声明。暂不支持在 getter/setter 里添加自定义的逻辑，需要自定义的情况请继续使用 Code Snippet 生成的代码。
 使用方式：
 @code
 @interface NSObject (CategoryName)
 @property(nonatomic, strong) type *strongObj;
 @property(nonatomic, weak) type *weakObj;
 @property(nonatomic, assign) CGRect rectValue;
 @end
 
 @implementation NSObject (CategoryName)
 
 // 注意 setter 不需要带冒号
 CIGAMSynthesizeIdStrongProperty(strongObj, setStrongObj)
 CIGAMSynthesizeIdWeakProperty(weakObj, setWeakObj)
 CIGAMSynthesizeCGRectProperty(rectValue, setRectValue)
 
 @end
 @endcode
 */

#pragma mark - Meta Marcos

#define _CIGAMSynthesizeId(_getterName, _setterName, _policy) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
}\
\
- (id)_getterName {\
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
}\
_Pragma("clang diagnostic pop")

#define _CIGAMSynthesizeWeakId(_getterName, _setterName) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [[CIGAMWeakObjectContainer alloc] initWithObject:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (id)_getterName {\
    return ((CIGAMWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)).object;\
}\
_Pragma("clang diagnostic pop")

#define _CIGAMSynthesizeNonObject(_getterName, _setterName, _type, valueInitializer, valueGetter) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [NSNumber valueInitializer:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (_type)_getterName {\
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)) valueGetter];\
}\
_Pragma("clang diagnostic pop")




#pragma mark - Object Marcos

/// @property(nonatomic, strong) id xxx
#define CIGAMSynthesizeIdStrongProperty(_getterName, _setterName) _CIGAMSynthesizeId(_getterName, _setterName, RETAIN)

/// @property(nonatomic, weak) id xxx
#define CIGAMSynthesizeIdWeakProperty(_getterName, _setterName) _CIGAMSynthesizeWeakId(_getterName, _setterName)

/// @property(nonatomic, copy) id xxx
#define CIGAMSynthesizeIdCopyProperty(_getterName, _setterName) _CIGAMSynthesizeId(_getterName, _setterName, COPY)



#pragma mark - NonObject Marcos

/// @property(nonatomic, assign) Int xxx
#define CIGAMSynthesizeIntProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, int, numberWithInt, intValue)

/// @property(nonatomic, assign) unsigned int xxx
#define CIGAMSynthesizeUnsignedIntProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, unsigned int, numberWithUnsignedInt, unsignedIntValue)

/// @property(nonatomic, assign) float xxx
#define CIGAMSynthesizeFloatProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, float, numberWithFloat, floatValue)

/// @property(nonatomic, assign) double xxx
#define CIGAMSynthesizeDoubleProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, double, numberWithDouble, doubleValue)

/// @property(nonatomic, assign) BOOL xxx
#define CIGAMSynthesizeBOOLProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, BOOL, numberWithBool, boolValue)

/// @property(nonatomic, assign) NSInteger xxx
#define CIGAMSynthesizeNSIntegerProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, NSInteger, numberWithInteger, integerValue)

/// @property(nonatomic, assign) NSUInteger xxx
#define CIGAMSynthesizeNSUIntegerProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, NSUInteger, numberWithUnsignedInteger, unsignedIntegerValue)

/// @property(nonatomic, assign) CGFloat xxx
#define CIGAMSynthesizeCGFloatProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, CGFloat, numberWithDouble, cigam_CGFloatValue)

/// @property(nonatomic, assign) CGPoint xxx
#define CIGAMSynthesizeCGPointProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, CGPoint, valueWithCGPoint, CGPointValue)

/// @property(nonatomic, assign) CGSize xxx
#define CIGAMSynthesizeCGSizeProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, CGSize, valueWithCGSize, CGSizeValue)

/// @property(nonatomic, assign) CGRect xxx
#define CIGAMSynthesizeCGRectProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, CGRect, valueWithCGRect, CGRectValue)

/// @property(nonatomic, assign) UIEdgeInsets xxx
#define CIGAMSynthesizeUIEdgeInsetsProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, UIEdgeInsets, valueWithUIEdgeInsets, UIEdgeInsetsValue)

/// @property(nonatomic, assign) CGVector xxx
#define CIGAMSynthesizeCGVectorProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, CGVector, valueWithCGVector, CGVectorValue)

/// @property(nonatomic, assign) CGAffineTransform xxx
#define CIGAMSynthesizeCGAffineTransformProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, CGAffineTransform, valueWithCGAffineTransform, CGAffineTransformValue)

/// @property(nonatomic, assign) NSDirectionalEdgeInsets xxx
#define CIGAMSynthesizeNSDirectionalEdgeInsetsProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, NSDirectionalEdgeInsets, valueWithDirectionalEdgeInsets, NSDirectionalEdgeInsetsValue)

/// @property(nonatomic, assign) UIOffset xxx
#define CIGAMSynthesizeUIOffsetProperty(_getterName, _setterName) _CIGAMSynthesizeNonObject(_getterName, _setterName, UIOffset, valueWithUIOffset, UIOffsetValue)

#endif /* CIGAMLab_h */
