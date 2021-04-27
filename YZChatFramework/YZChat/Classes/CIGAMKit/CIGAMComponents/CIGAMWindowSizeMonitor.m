/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CIGAMWindowSizeMonitor.m
//  cigamdemo
//
//  Created by ziezheng on 2019/5/27.
//

#import "CIGAMWindowSizeMonitor.h"
#import "CIGAMCore.h"
#import "NSPointerArray+CIGAM.h"

@interface NSObject (CIGAMWindowSizeMonitor_Private)

@property(nonatomic, readonly) NSMutableArray <CIGAMWindowSizeObserverHandler> *cigam_windowSizeChangeHandlers;

@end

@interface UIResponder (CIGAMWindowSizeMonitor_Private)

@property(nonatomic, weak) UIWindow *cigam_previousWindow;

@end


@interface UIWindow (CIGAMWindowSizeMonitor_Private)

@property(nonatomic, assign) CGSize cigam_previousSize;
@property(nonatomic, readonly) NSPointerArray *cigam_sizeObservers;
@property(nonatomic, readonly) NSPointerArray *cigam_canReceiveWindowDidTransitionToSizeResponders;

- (void)cigam_addSizeObserver:(NSObject *)observer;

@end



@implementation NSObject (CIGAMWindowSizeMonitor)

- (void)cigam_addSizeObserverForMainWindow:(CIGAMWindowSizeObserverHandler)handler {
    [self cigam_addSizeObserverForWindow:UIApplication.sharedApplication.delegate.window handler:handler];
}

- (void)cigam_addSizeObserverForWindow:(UIWindow *)window handler:(CIGAMWindowSizeObserverHandler)handler {
    NSAssert(window != nil, @"window is nil!");
    
    struct Block_literal {
        void *isa;
        int flags;
        int reserved;
        void (*__FuncPtr)(void *, ...);
    };
    
    void * blockFuncPtr = ((__bridge struct Block_literal *)handler)->__FuncPtr;
    for (CIGAMWindowSizeObserverHandler handler in self.cigam_windowSizeChangeHandlers) {
        // 由于利用 block 的 __FuncPtr 指针来判断同一个实现的 block 过滤掉，防止重复添加监听
        if (((__bridge struct Block_literal *)handler)->__FuncPtr == blockFuncPtr) {
            return;
        }
    }
    
    [self.cigam_windowSizeChangeHandlers addObject:handler];
    [window cigam_addSizeObserver:self];
}

- (NSMutableArray<CIGAMWindowSizeObserverHandler> *)cigam_windowSizeChangeHandlers {
    NSMutableArray *_handlers = objc_getAssociatedObject(self, _cmd);
    if (!_handlers) {
        _handlers = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, _handlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _handlers;
}

@end

@implementation UIWindow (CIGAMWindowSizeMonitor)

CIGAMSynthesizeCGSizeProperty(cigam_previousSize, setCigam_previousSize)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        void (^notifyNewSizeBlock)(UIWindow *, CGRect) = ^(UIWindow *selfObject, CGRect firstArgv) {
            CGSize newSize = selfObject.bounds.size;
            if (!CGSizeEqualToSize(newSize, selfObject.cigam_previousSize)) {
                if (!CGSizeEqualToSize(selfObject.cigam_previousSize, CGSizeZero)) {
                    [selfObject cigam_notifyWithNewSize:newSize];
                }
                selfObject.cigam_previousSize = selfObject.bounds.size;
            }
        };
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIWindow class], @selector(setFrame:), CGRect, notifyNewSizeBlock);
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIWindow class], @selector(setBounds:), CGRect, notifyNewSizeBlock);
        
        OverrideImplementation([UIView class], @selector(willMoveToWindow:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UIView *selfObject, UIWindow *newWindow) {
                
                void (*originSelectorIMP)(id, SEL, UIWindow *);
                originSelectorIMP = (void (*)(id, SEL, UIWindow *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, newWindow);
                
                if (newWindow) {
                    if ([selfObject respondsToSelector:@selector(windowDidTransitionToSize:)]) {
                        [newWindow cigam_addDidTransitionToSizeMethodReceiver:selfObject];
                    }
                    UIResponder *nextResponder = [selfObject nextResponder];
                    if ([nextResponder isKindOfClass:[UIViewController class]] && [nextResponder respondsToSelector:@selector(windowDidTransitionToSize:)]) {
                        [newWindow cigam_addDidTransitionToSizeMethodReceiver:nextResponder];
                    }
                }
                
            };
        });
    });
}


- (void)cigam_addSizeObserver:(NSObject *)observer {
    if ([self.cigam_sizeObservers cigam_containsPointer:(__bridge void *)(observer)]) return;
    [self.cigam_sizeObservers addPointer:(__bridge void *)(observer)];
}

- (void)cigam_removeSizeObserver:(NSObject *)observer {
    NSUInteger index = [self.cigam_sizeObservers cigam_indexOfPointer:(__bridge void *)observer];
    if (index != NSNotFound) {
        [self.cigam_sizeObservers removePointerAtIndex:index];
    }
}

- (void)cigam_addDidTransitionToSizeMethodReceiver:(UIResponder *)receiver {
    if ([self.cigam_canReceiveWindowDidTransitionToSizeResponders cigam_containsPointer:(__bridge void *)(receiver)]) return;
    if (receiver.cigam_previousWindow && receiver.cigam_previousWindow != self) {
        [receiver.cigam_previousWindow cigam_removeDidTransitionToSizeMethodReceiver:receiver];
    }
    receiver.cigam_previousWindow = self;
    [self.cigam_canReceiveWindowDidTransitionToSizeResponders addPointer:(__bridge void *)(receiver)];
}

- (void)cigam_removeDidTransitionToSizeMethodReceiver:(UIResponder *)receiver {
    NSUInteger index = [self.cigam_canReceiveWindowDidTransitionToSizeResponders cigam_indexOfPointer:(__bridge void *)(receiver)];
    if (index != NSNotFound) {
        [self.cigam_canReceiveWindowDidTransitionToSizeResponders removePointerAtIndex:index];
    }
}


- (void)cigam_notifyWithNewSize:(CGSize)newSize {
    // notify sizeObservers
    for (NSUInteger i = 0, count = self.cigam_sizeObservers.count; i < count; i++) {
        NSObject *object = [self.cigam_sizeObservers pointerAtIndex:i];
        for (NSUInteger i = 0, count = object.cigam_windowSizeChangeHandlers.count; i < count; i++) {
            CIGAMWindowSizeObserverHandler handler = object.cigam_windowSizeChangeHandlers[i];
            handler(newSize);
        }
    }
    // send ‘windowDidTransitionToSize:’ to responders
    for (NSUInteger i = 0, count = self.cigam_canReceiveWindowDidTransitionToSizeResponders.count; i < count; i++) {
        UIResponder <CIGAMWindowSizeMonitorProtocol>*responder = [self.cigam_canReceiveWindowDidTransitionToSizeResponders pointerAtIndex:i];
        // call superclass automatically
        Method lastMethod = NULL;
        NSMutableArray <NSValue *>*selectorIMPArray = [NSMutableArray array];
        for (Class responderClass = object_getClass(responder); responderClass != [UIResponder class]; responderClass = class_getSuperclass(responderClass)) {
            Method methodOfClass = class_getInstanceMethod(responderClass, @selector(windowDidTransitionToSize:));
            if (methodOfClass == NULL) break;
            if (methodOfClass == lastMethod) continue;
            void (*selectorIMP)(id, SEL, CGSize) = (void (*)(id, SEL, CGSize))method_getImplementation(methodOfClass);
            [selectorIMPArray addObject:[NSValue valueWithPointer:selectorIMP]];
            lastMethod = methodOfClass;
        }
        // call the superclass before calling the subclass
        for (NSInteger i = selectorIMPArray.count - 1; i >= 0; i--) {
            void (*selectorIMP)(id, SEL, CGSize) = selectorIMPArray[i].pointerValue;
            selectorIMP(responder, @selector(windowDidTransitionToSize:), newSize);
        }
    }
}

- (NSPointerArray *)cigam_sizeObservers {
    NSPointerArray *cigam_sizeObservers = objc_getAssociatedObject(self, _cmd);
    if (!cigam_sizeObservers) {
        cigam_sizeObservers = [NSPointerArray weakObjectsPointerArray];
        objc_setAssociatedObject(self, _cmd, cigam_sizeObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cigam_sizeObservers;
}

- (NSPointerArray *)cigam_canReceiveWindowDidTransitionToSizeResponders {
    NSPointerArray *cigam_responders = objc_getAssociatedObject(self, _cmd);
    if (!cigam_responders) {
        cigam_responders = [NSPointerArray weakObjectsPointerArray];
        objc_setAssociatedObject(self, _cmd, cigam_responders, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cigam_responders;
}

@end

@implementation UIResponder (CIGAMWindowSizeMonitor)

CIGAMSynthesizeIdWeakProperty(cigam_previousWindow, setCigam_previousWindow)

@end
