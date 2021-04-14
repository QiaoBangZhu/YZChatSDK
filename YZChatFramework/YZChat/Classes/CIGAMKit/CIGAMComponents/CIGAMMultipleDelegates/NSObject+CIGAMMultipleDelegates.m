/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSObject+MultipleDelegates.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/3/27.
//

#import "NSObject+CIGAMMultipleDelegates.h"
#import "CIGAMMultipleDelegates.h"
#import "CIGAMCore.h"
#import "NSPointerArray+CIGAM.h"
#import "NSString+CIGAM.h"

@interface NSObject ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, CIGAMMultipleDelegates *> *cigammd_delegates;
@end

@implementation NSObject (CIGAMMultipleDelegates)

CIGAMSynthesizeIdStrongProperty(cigammd_delegates, setCigammd_delegates)

static char kAssociatedObjectKey_cigamMultipleDelegatesEnabled;
- (void)setCigam_multipleDelegatesEnabled:(BOOL)cigam_multipleDelegatesEnabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cigamMultipleDelegatesEnabled, @(cigam_multipleDelegatesEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_multipleDelegatesEnabled) {
        if (!self.cigammd_delegates) {
            self.cigammd_delegates = [NSMutableDictionary dictionary];
        }
        [self cigam_registerDelegateSelector:@selector(delegate)];
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
            [self cigam_registerDelegateSelector:@selector(dataSource)];
        }
    }
}

- (BOOL)cigam_multipleDelegatesEnabled {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamMultipleDelegatesEnabled)) boolValue];
}

- (void)cigam_registerDelegateSelector:(SEL)getter {
    if (!self.cigam_multipleDelegatesEnabled) {
        return;
    }
    
    Class targetClass = [self class];
    SEL originDelegateSetter = setterWithGetter(getter);
    SEL newDelegateSetter = [self newSetterWithGetter:getter];
    Method originMethod = class_getInstanceMethod(targetClass, originDelegateSetter);
    if (!originMethod) {
        return;
    }
    
    // 为这个 selector 创建一个 CIGAMMultipleDelegates 容器
    NSString *delegateGetterKey = NSStringFromSelector(getter);
    if (!self.cigammd_delegates[delegateGetterKey]) {
        objc_property_t prop = class_getProperty(self.class, delegateGetterKey.UTF8String);
        CIGAMPropertyDescriptor *property = [CIGAMPropertyDescriptor descriptorWithProperty:prop];
        if (property.isStrong) {
            // strong property
            CIGAMMultipleDelegates *strongDelegates = [CIGAMMultipleDelegates strongDelegates];
            strongDelegates.parentObject = self;
            self.cigammd_delegates[delegateGetterKey] = strongDelegates;
        } else {
            // weak property
            CIGAMMultipleDelegates *weakDelegates = [CIGAMMultipleDelegates weakDelegates];
            weakDelegates.parentObject = self;
            self.cigammd_delegates[delegateGetterKey] = weakDelegates;
        }
    }
    
    [CIGAMHelper executeBlock:^{
        IMP originIMP = method_getImplementation(originMethod);
        void (*originSelectorIMP)(id, SEL, id);
        originSelectorIMP = (void (*)(id, SEL, id))originIMP;
        
        BOOL isAddedMethod = class_addMethod(targetClass, newDelegateSetter, imp_implementationWithBlock(^(NSObject *selfObject, id aDelegate){
            
            // 这一段保护的原因请查看 https://github.com/Tencent/CIGAM_iOS/issues/292
            if (!selfObject.cigam_multipleDelegatesEnabled || selfObject.class != targetClass) {
                originSelectorIMP(selfObject, originDelegateSetter, aDelegate);
                return;
            }
            
            CIGAMMultipleDelegates *delegates = selfObject.cigammd_delegates[delegateGetterKey];
            
            if (!aDelegate) {
                // 对应 setDelegate:nil，表示清理所有的 delegate
                [delegates removeAllDelegates];
                // 只要 cigam_multipleDelegatesEnabled 开启，就会保证 delegate 一直是 delegates，所以不去调用系统默认的 set nil
                // originSelectorIMP(selfObject, originDelegateSetter, nil);
                return;
            }
            
            if (aDelegate != delegates) {// 过滤掉容器自身，避免把 delegates 传进去 delegates 里，导致死循环
                [delegates addDelegate:aDelegate];
            }
            
            originSelectorIMP(selfObject, originDelegateSetter, nil);// 先置为 nil 再设置 delegates，从而避免这个问题 https://github.com/Tencent/CIGAM_iOS/issues/305
            originSelectorIMP(selfObject, originDelegateSetter, delegates);// 不管外面将什么 object 传给 setDelegate:，最终实际上传进去的都是 CIGAMMultipleDelegates 容器
            
        }), method_getTypeEncoding(originMethod));
        if (isAddedMethod) {
            Method newMethod = class_getInstanceMethod(targetClass, newDelegateSetter);
            method_exchangeImplementations(originMethod, newMethod);
        }
    } oncePerIdentifier:[NSString stringWithFormat:@"MultipleDelegates %@-%@", NSStringFromClass(targetClass), NSStringFromSelector(getter)]];
    
    // 如果原来已经有 delegate，则将其加到新建的容器里
    // @see https://github.com/Tencent/CIGAM_iOS/issues/378
    BeginIgnorePerformSelectorLeaksWarning
    id originDelegate = [self performSelector:getter];
    if (originDelegate && originDelegate != self.cigammd_delegates[delegateGetterKey]) {
        [self performSelector:originDelegateSetter withObject:originDelegate];
    }
    EndIgnorePerformSelectorLeaksWarning
}

- (void)cigam_removeDelegate:(id)delegate {
    if (!self.cigam_multipleDelegatesEnabled) {
        return;
    }
    NSMutableArray<NSString *> *delegateGetters = [[NSMutableArray alloc] init];
    [self.cigammd_delegates enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CIGAMMultipleDelegates * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL removeSucceed = [obj removeDelegate:delegate];
        if (removeSucceed) {
            [delegateGetters addObject:key];
        }
    }];
    if (delegateGetters.count > 0) {
        for (NSString *getterString in delegateGetters) {
            [self refreshDelegateWithGetter:NSSelectorFromString(getterString)];
        }
    }
}

- (void)refreshDelegateWithGetter:(SEL)getter {
    SEL originSetterSEL = [self newSetterWithGetter:getter];
    BeginIgnorePerformSelectorLeaksWarning
    id originDelegate = [self performSelector:getter];
    [self performSelector:originSetterSEL withObject:nil];// 先置为 nil 再设置 delegates，从而避免这个问题 https://github.com/Tencent/CIGAM_iOS/issues/305
    [self performSelector:originSetterSEL withObject:originDelegate];
    EndIgnorePerformSelectorLeaksWarning
}

// 根据 delegate property 的 getter，得到 CIGAMMultipleDelegates 为它的 setter 创建的新 setter 方法，最终交换原方法，因此利用这个方法返回的 SEL，可以调用到原来的 delegate property setter 的实现
- (SEL)newSetterWithGetter:(SEL)getter {
    return NSSelectorFromString([NSString stringWithFormat:@"cigammd_%@", NSStringFromSelector(setterWithGetter(getter))]);
}

@end
