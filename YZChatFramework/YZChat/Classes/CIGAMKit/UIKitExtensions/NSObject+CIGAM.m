/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSObject+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 2016/11/1.
//

#import "NSObject+CIGAM.h"
#import "CIGAMWeakObjectContainer.h"
#import "CIGAMCore.h"
#import "NSString+CIGAM.h"
#import <objc/message.h>


@implementation NSObject (CIGAM)


- (BOOL)cigam_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return [NSObject cigam_hasOverrideMethod:selector forClass:self.class ofSuperclass:superclass];
}

+ (BOOL)cigam_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass {
    if (![aClass isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

- (id)cigam_performSelectorToSuperclass:(SEL)aSelector {
    struct objc_super mySuper;
    mySuper.receiver = self;
    mySuper.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&mySuper, aSelector);
}

- (id)cigam_performSelectorToSuperclass:(SEL)aSelector withObject:(id)object {
    struct objc_super mySuper;
    mySuper.receiver = self;
    mySuper.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL, ...) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&mySuper, aSelector, object);
}

- (id)cigam_performSelector:(SEL)selector withArguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), selector));
    if (isObjectTypeEncoding(typeEncoding)) {
        __unsafe_unretained id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (void)cigam_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue {
    [self cigam_performSelector:selector withPrimitiveReturnValue:returnValue arguments:nil];
}

- (void)cigam_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue arguments:(void *)firstArgument, ... {
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSAssert(methodSignature, @"- [%@ cigam_performSelector:@selector(%@)] 失败，方法不存在。", NSStringFromClass(self.class), NSStringFromSelector(selector));
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    if (returnValue) {
        [invocation getReturnValue:returnValue];
    }
}

- (void)cigam_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block {
    [self cigam_enumrateIvarsIncludingInherited:NO usingBlock:block];
}

- (void)cigam_enumrateIvarsIncludingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block {
    NSMutableArray<NSString *> *ivarDescriptions = [NSMutableArray new];
    NSString *ivarList = [self cigam_ivarList];
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"in %@:(.*?)((?=in \\w+:)|$)", NSStringFromClass(self.class)] options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (!error) {
        NSArray<NSTextCheckingResult *> *result = [reg matchesInString:ivarList options:NSMatchingReportCompletion range:NSMakeRange(0, ivarList.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *ivars = [ivarList substringWithRange:[obj rangeAtIndex:1]];
            [ivars enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
                if (![line hasPrefix:@"\t\t"]) {// 有些 struct 类型的变量，会把 struct 的成员也缩进打出来，所以用这种方式过滤掉
                    line = line.cigam_trim;
                    if (line.length > 2) {// 过滤掉空行或者 struct 结尾的"}"
                        NSRange range = [line rangeOfString:@":"];
                        if (range.location != NSNotFound)// 有些"unknow type"的变量不会显示指针地址（例如 UIView->_viewFlags）
                            line = [line substringToIndex:range.location];// 去掉指针地址
                        NSUInteger typeStart = [line rangeOfString:@" ("].location;
                        line = [NSString stringWithFormat:@"%@ %@", [line substringWithRange:NSMakeRange(typeStart + 2, line.length - 1 - (typeStart + 2))], [line substringToIndex:typeStart]];// 交换变量类型和变量名的位置，变量类型在前，变量名在后，空格隔开
                        [ivarDescriptions addObject:line];
                    }
                }
            }];
        }];
    }
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self.class, &outCount);
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithFormat:@"%s", ivar_getName(ivar)];
        for (NSString *desc in ivarDescriptions) {
            if ([desc hasSuffix:ivarName]) {
                block(ivar, desc);
                break;
            }
        }
    }
    free(ivars);
    
    if (includingInherited) {
        Class superclass = self.superclass;
        if (superclass) {
            [NSObject cigam_enumrateIvarsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

+ (void)cigam_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar, NSString *))block {
    if (!block) return;
    NSObject *obj = nil;
    if ([aClass isSubclassOfClass:[UICollectionView class]]) {
        obj = [[aClass alloc] initWithFrame:CGRectZero collectionViewLayout:UICollectionViewFlowLayout.new];
    } else if ([aClass isSubclassOfClass:[UIApplication class]]) {
        obj = UIApplication.sharedApplication;
    } else {
        obj = [aClass new];
    }
    [obj cigam_enumrateIvarsIncludingInherited:includingInherited usingBlock:block];
}

- (void)cigam_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block {
    [NSObject cigam_enumratePropertiesOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)cigam_enumratePropertiesOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(objc_property_t, NSString *))block {
    if (!block) return;
    
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertiesCount);
    
    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        if (block) block(property, [NSString stringWithFormat:@"%s", property_getName(property)]);
    }
    
    free(properties);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject cigam_enumratePropertiesOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

- (void)cigam_enumrateInstanceMethodsUsingBlock:(void (^)(Method, SEL))block {
    [NSObject cigam_enumrateInstanceMethodsOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)cigam_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method, SEL))block {
    if (!block) return;
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) block(method, selector);
    }
    
    free(methods);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject cigam_enumrateInstanceMethodsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

+ (void)cigam_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL))block {
    if (!block) return;
    
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        struct objc_method_description methodDescription = methods[i];
        if (block) {
            block(methodDescription.name);
        }
    }
    free(methods);
}

@end

@implementation NSObject (CIGAM_KeyValueCoding)

- (id)cigam_valueForKey:(NSString *)key {
    if (@available(iOS 13.0, *)) {
        if ([self isKindOfClass:[UIView class]] && CIGAMCMIActivated && !IgnoreKVCAccessProhibited) {
            BeginIgnoreUIKVCAccessProhibited
            id value = [self valueForKey:key];
            EndIgnoreUIKVCAccessProhibited
            return value;
        }
    }
    return [self valueForKey:key];
}

- (void)cigam_setValue:(id)value forKey:(NSString *)key {
    if (@available(iOS 13.0, *)) {
        if ([self isKindOfClass:[UIView class]] && CIGAMCMIActivated && !IgnoreKVCAccessProhibited) {
            BeginIgnoreUIKVCAccessProhibited
            [self setValue:value forKey:key];
            EndIgnoreUIKVCAccessProhibited
            return;
        }
    }
    
    [self setValue:value forKey:key];
}

- (BOOL)cigam_canGetValueForKey:(NSString *)key {
    NSArray<NSString *> *getters = @[
        [NSString stringWithFormat:@"get%@", key.cigam_capitalizedString],   // get<Key>
        key,
        [NSString stringWithFormat:@"is%@", key.cigam_capitalizedString],    // is<Key>
        [NSString stringWithFormat:@"_%@", key]                             // _<key>
    ];
    for (NSString *selectorString in getters) {
        if ([self respondsToSelector:NSSelectorFromString(selectorString)]) return YES;
    }
    
    if (![self.class accessInstanceVariablesDirectly]) return NO;
    
    return [self _cigam_hasSpecifiedIvarWithKey:key];
}

- (BOOL)cigam_canSetValueForKey:(NSString *)key {
    NSArray<NSString *> *setter = @[
        [NSString stringWithFormat:@"set%@:", key.cigam_capitalizedString],   // set<Key>:
        [NSString stringWithFormat:@"_set%@", key.cigam_capitalizedString]   // _set<Key>
    ];
    for (NSString *selectorString in setter) {
        if ([self respondsToSelector:NSSelectorFromString(selectorString)]) return YES;
    }
    
    if (![self.class accessInstanceVariablesDirectly]) return NO;
    
    return [self _cigam_hasSpecifiedIvarWithKey:key];
}

- (BOOL)_cigam_hasSpecifiedIvarWithKey:(NSString *)key {
    __block BOOL result = NO;
    NSArray<NSString *> *ivars = @[
        [NSString stringWithFormat:@"_%@", key],
        [NSString stringWithFormat:@"_is%@", key.cigam_capitalizedString],
        key,
        [NSString stringWithFormat:@"is%@", key.cigam_capitalizedString]
    ];
    [NSObject cigam_enumrateIvarsOfClass:self.class includingInherited:YES usingBlock:^(Ivar  _Nonnull ivar, NSString * _Nonnull ivarDescription) {
        if (!result) {
            NSString *ivarName = [NSString stringWithFormat:@"%s", ivar_getName(ivar)];
            if ([ivars containsObject:ivarName]) {
                result = YES;
            }
        }
    }];
    return result;
}

@end


@implementation NSObject (CIGAM_DataBind)

static char kAssociatedObjectKey_CIGAMAllBoundObjects;
- (NSMutableDictionary<id, id> *)cigam_allBoundObjects {
    NSMutableDictionary<id, id> *dict = objc_getAssociatedObject(self, &kAssociatedObjectKey_CIGAMAllBoundObjects);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_CIGAMAllBoundObjects, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)cigam_bindObject:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        [[self cigam_allBoundObjects] setObject:object forKey:key];
    } else {
        [[self cigam_allBoundObjects] removeObjectForKey:key];
    }
}

- (void)cigam_bindObjectWeakly:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        CIGAMWeakObjectContainer *container = [[CIGAMWeakObjectContainer alloc] initWithObject:object];
        [self cigam_bindObject:container forKey:key];
    } else {
        [[self cigam_allBoundObjects] removeObjectForKey:key];
    }
}

- (id)cigam_getBoundObjectForKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return nil;
    }
    id storedObj = [[self cigam_allBoundObjects] objectForKey:key];
    if ([storedObj isKindOfClass:[CIGAMWeakObjectContainer class]]) {
        storedObj = [(CIGAMWeakObjectContainer *)storedObj object];
    }
    return storedObj;
}

- (void)cigam_bindDouble:(double)doubleValue forKey:(NSString *)key {
    [self cigam_bindObject:@(doubleValue) forKey:key];
}

- (double)cigam_getBoundDoubleForKey:(NSString *)key {
    id object = [self cigam_getBoundObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        double doubleValue = [(NSNumber *)object doubleValue];
        return doubleValue;
        
    } else {
        return 0.0;
    }
}

- (void)cigam_bindBOOL:(BOOL)boolValue forKey:(NSString *)key {
    [self cigam_bindObject:@(boolValue) forKey:key];
}

- (BOOL)cigam_getBoundBOOLForKey:(NSString *)key {
    id object = [self cigam_getBoundObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        BOOL boolValue = [(NSNumber *)object boolValue];
        return boolValue;
        
    } else {
        return NO;
    }
}

- (void)cigam_bindLong:(long)longValue forKey:(NSString *)key {
    [self cigam_bindObject:@(longValue) forKey:key];
}

- (long)cigam_getBoundLongForKey:(NSString *)key {
    id object = [self cigam_getBoundObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        long longValue = [(NSNumber *)object longValue];
        return longValue;
        
    } else {
        return 0;
    }
}

- (void)cigam_clearBindingForKey:(NSString *)key {
    [self cigam_bindObject:nil forKey:key];
}

- (void)cigam_clearAllBinding {
    [[self cigam_allBoundObjects] removeAllObjects];
}

- (NSArray<NSString *> *)cigam_allBindingKeys {
    NSArray<NSString *> *allKeys = [[self cigam_allBoundObjects] allKeys];
    return allKeys;
}

- (BOOL)cigam_hasBindingKey:(NSString *)key {
    return [[self cigam_allBindingKeys] containsObject:key];
}

@end

@implementation NSObject (CIGAM_Debug)

BeginIgnorePerformSelectorLeaksWarning
- (NSString *)cigam_methodList {
    return [self performSelector:NSSelectorFromString(@"_methodDescription")];
}

- (NSString *)cigam_shortMethodList {
    return [self performSelector:NSSelectorFromString(@"_shortMethodDescription")];
}

- (NSString *)cigam_ivarList {
    return [self performSelector:NSSelectorFromString(@"_ivarDescription")];
}
EndIgnorePerformSelectorLeaksWarning

@end

@implementation NSThread (CIGAM_KVC)

CIGAMSynthesizeBOOLProperty(cigam_shouldIgnoreUIKVCAccessProhibited, setCigam_shouldIgnoreUIKVCAccessProhibited)

@end

@interface NSException (CIGAM_KVC)

@end

@implementation NSException (CIGAM_KVC)

+ (void)load {
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            OverrideImplementation(object_getClass([NSException class]), @selector(raise:format:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(NSObject *selfObject, NSExceptionName raise, NSString *format, ...) {
                    
                    if (raise == NSGenericException && [format isEqualToString:@"Access to %@'s %@ ivar is prohibited. This is an application bug"]) {
                        BOOL shouldIgnoreUIKVCAccessProhibited = ((CIGAMCMIActivated && IgnoreKVCAccessProhibited) || NSThread.currentThread.cigam_shouldIgnoreUIKVCAccessProhibited);
                        if (shouldIgnoreUIKVCAccessProhibited) return;
                        
                        CIGAMLogWarn(@"NSObject (CIGAM)", @"使用 KVC 访问了 UIKit 的私有属性，会触发系统的 NSException，建议尽量避免此类操作，仍需访问可使用 BeginIgnoreUIKVCAccessProhibited 和 EndIgnoreUIKVCAccessProhibited 把相关代码包裹起来，或者直接使用 cigam_valueForKey: 、cigam_setValue:forKey:");
                    }
                    
                    id (*originSelectorIMP)(id, SEL, NSExceptionName name, NSString *, ...);
                    originSelectorIMP = (id (*)(id, SEL, NSExceptionName name, NSString *, ...))originalIMPProvider();
                    va_list args;
                    va_start(args, format);
                    NSString *reason =  [[NSString alloc] initWithFormat:format arguments:args];
                    originSelectorIMP(selfObject, originCMD, raise, reason);
                    va_end(args);
                };
            });
        });
    }
}

@end
