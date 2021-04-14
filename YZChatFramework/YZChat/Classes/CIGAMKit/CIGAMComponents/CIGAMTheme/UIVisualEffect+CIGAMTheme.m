/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIVisualEffect+CIGAMTheme.m
//  CIGAMKit
//
//  Created by MoLice on 2019/7/20.
//

#import "UIVisualEffect+CIGAMTheme.h"
#import "CIGAMThemeManager.h"
#import "CIGAMThemeManagerCenter.h"
#import "CIGAMThemePrivate.h"
#import "NSMethodSignature+CIGAM.h"
#import "CIGAMCore.h"

@implementation CIGAMThemeVisualEffect

- (id)copyWithZone:(NSZone *)zone {
    CIGAMThemeVisualEffect *effect = [[self class] allocWithZone:zone];
    effect.managerName = self.managerName;
    effect.themeProvider = self.themeProvider;
    return effect;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    result = [self.cigam_rawEffect methodSignatureForSelector:aSelector];
    if (result && [self.cigam_rawEffect respondsToSelector:aSelector]) {
        return result;
    }
    
    return [NSMethodSignature cigam_avoidExceptionSignature];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    if ([self.cigam_rawEffect respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.cigam_rawEffect];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.cigam_rawEffect respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == CIGAMThemeVisualEffect.class) return YES;
    return [self.cigam_rawEffect isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == CIGAMThemeVisualEffect.class) return YES;
    return [self.cigam_rawEffect isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.cigam_rawEffect conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

#pragma mark - <CIGAMDynamicEffectProtocol>

- (UIVisualEffect *)cigam_rawEffect {
    CIGAMThemeManager *manager = [CIGAMThemeManagerCenter themeManagerWithName:self.managerName];
    return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).cigam_rawEffect;
}

- (BOOL)cigam_isDynamicEffect {
    return YES;
}

@end

@implementation UIVisualEffect (CIGAMTheme)

+ (UIVisualEffect *)cigam_effectWithThemeProvider:(UIVisualEffect * _Nonnull (^)(__kindof CIGAMThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIVisualEffect cigam_effectWithThemeManagerName:CIGAMThemeManagerNameDefault provider:provider];
}

+ (UIVisualEffect *)cigam_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIVisualEffect * _Nonnull (^)(__kindof CIGAMThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    CIGAMThemeVisualEffect *effect = [[CIGAMThemeVisualEffect alloc] init];
    effect.managerName = name;
    effect.themeProvider = provider;
    return (UIVisualEffect *)effect;
}

#pragma mark - <CIGAMDynamicEffectProtocol>

- (UIVisualEffect *)cigam_rawEffect {
    return self;
}

- (BOOL)cigam_isDynamicEffect {
    return NO;
}

@end
