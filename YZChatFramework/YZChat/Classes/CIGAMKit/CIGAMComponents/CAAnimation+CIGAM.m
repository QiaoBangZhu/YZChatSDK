/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CAAnimation+CIGAM.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/7/31.
//

#import "CAAnimation+CIGAM.h"
#import "CIGAMCore.h"
#import "CIGAMMultipleDelegates.h"

@interface _CIGAMCAAnimationDelegator : NSObject<CAAnimationDelegate>

@end

@implementation CAAnimation (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([CAAnimation class], @selector(copyWithZone:), NSZone *, id, ^id(CAAnimation *selfObject, NSZone *firstArgv, id originReturnValue) {
            CAAnimation *animation = (CAAnimation *)originReturnValue;
            animation.cigam_multipleDelegatesEnabled = selfObject.cigam_multipleDelegatesEnabled;
            animation.cigam_animationDidStartBlock = selfObject.cigam_animationDidStartBlock;
            animation.cigam_animationDidStopBlock = selfObject.cigam_animationDidStopBlock;
            return animation;
        });
    });
}

- (void)enabledDelegateBlocks {
    self.cigam_multipleDelegatesEnabled = YES;
    BOOL shouldSetDelegator = !self.delegate;
    if (!shouldSetDelegator && [self.delegate isKindOfClass:[CIGAMMultipleDelegates class]]) {
        CIGAMMultipleDelegates *delegates = (CIGAMMultipleDelegates *)self.delegate;
        NSPointerArray *array = delegates.delegates;
        for (NSUInteger i = 0; i < array.count; i++) {
            if ([((NSObject *)[array pointerAtIndex:i]) isKindOfClass:[_CIGAMCAAnimationDelegator class]]) {
                shouldSetDelegator = NO;
                break;
            }
        }
    }
    if (shouldSetDelegator) {
        self.delegate = [[_CIGAMCAAnimationDelegator alloc] init];// delegate is a strong property, it can retain _CIGAMCAAnimationDelegator
    }
}

static char kAssociatedObjectKey_animationDidStartBlock;
- (void)setCigam_animationDidStartBlock:(void (^)(__kindof CAAnimation *))cigam_animationDidStartBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animationDidStartBlock, cigam_animationDidStartBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (cigam_animationDidStartBlock) {
        [self enabledDelegateBlocks];
    }
}

- (void (^)(__kindof CAAnimation *))cigam_animationDidStartBlock {
    return (void (^)(__kindof CAAnimation *))objc_getAssociatedObject(self, &kAssociatedObjectKey_animationDidStartBlock);
}

static char kAssociatedObjectKey_animationDidStopBlock;
- (void)setCigam_animationDidStopBlock:(void (^)(__kindof CAAnimation *, BOOL))cigam_animationDidStopBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animationDidStopBlock, cigam_animationDidStopBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (cigam_animationDidStopBlock) {
        [self enabledDelegateBlocks];
    }
}

- (void (^)(__kindof CAAnimation *, BOOL))cigam_animationDidStopBlock {
    return (void (^)(__kindof CAAnimation *, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_animationDidStopBlock);
}

@end

@implementation _CIGAMCAAnimationDelegator

- (void)animationDidStart:(CAAnimation *)anim {
    if (anim.cigam_animationDidStartBlock) {
        anim.cigam_animationDidStartBlock(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim.cigam_animationDidStopBlock) {
        anim.cigam_animationDidStopBlock(anim, flag);
    }
}

@end
