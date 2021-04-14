/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIVisualEffectView+CIGAM.m
//  CIGAMKit
//
//  Created by MoLice on 2020/7/15.
//

#import "UIVisualEffectView+CIGAM.h"
#import "CIGAMCore.h"
#import "CALayer+CIGAM.h"

@interface UIView (CIGAM_VisualEffectView)

// 为了方便，这个属性声明在 UIView 里，但实际上只有两个私有的 Visual View 会用到
@property(nonatomic, assign) BOOL cigamve_keepHidden;
@end

@interface UIVisualEffectView ()

@property(nonatomic, strong) CALayer *cigamve_foregroundLayer;
@property(nonatomic, assign, readonly) BOOL cigamve_showsForegroundLayer;
@end

@implementation UIVisualEffectView (CIGAM)

CIGAMSynthesizeIdStrongProperty(cigamve_foregroundLayer, setCigamve_foregroundLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIVisualEffectView class], @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIVisualEffectView *selfObject, UIView *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject cigamve_updateSubviews];
            };
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UIVisualEffectView class], @selector(layoutSubviews), ^(UIVisualEffectView *selfObject) {
            if (selfObject.cigamve_showsForegroundLayer) {
                selfObject.cigamve_foregroundLayer.frame = selfObject.bounds;
            }
        });
    });
}

static char kAssociatedObjectKey_foregroundColor;
- (void)setCigam_foregroundColor:(UIColor *)cigam_foregroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_foregroundColor, cigam_foregroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_foregroundColor && !self.cigamve_foregroundLayer) {
        self.cigamve_foregroundLayer = [CALayer layer];
        [self.cigamve_foregroundLayer cigam_removeDefaultAnimations];
        [self.layer addSublayer:self.cigamve_foregroundLayer];
    }
    if (self.cigamve_foregroundLayer) {
        self.cigamve_foregroundLayer.backgroundColor = cigam_foregroundColor.CGColor;
        self.cigamve_foregroundLayer.hidden = !cigam_foregroundColor;
        [self cigamve_updateSubviews];
        [self setNeedsLayout];
    }
}

- (UIColor *)cigam_foregroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_foregroundColor);
}

- (BOOL)cigamve_showsForegroundLayer {
    return self.cigamve_foregroundLayer && !self.cigamve_foregroundLayer.hidden;
}

- (void)cigamve_updateSubviews {
    if (self.cigamve_foregroundLayer) {
        
        // 先放在最背后，然后在遇到磨砂的 backdropLayer 时再放到它前面，因为有些情况下可能不存在 backdropLayer（例如 effect = nil 或者 effect 为 UIVibrancyEffect）
        [self.layer cigam_sendSublayerToBack:self.cigamve_foregroundLayer];
        for (NSInteger i = 0; i < self.layer.sublayers.count; i++) {
            CALayer *sublayer = self.layer.sublayers[i];
            if ([NSStringFromClass(sublayer.class) isEqualToString:@"UICABackdropLayer"]) {
                [self.layer insertSublayer:self.cigamve_foregroundLayer above:sublayer];
                break;
            }
        }
        
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *className = NSStringFromClass(subview.class);
            if ([className isEqualToString:@"_UIVisualEffectSubview"] || [className isEqualToString:@"_UIVisualEffectFilterView"]) {
                subview.cigamve_keepHidden = !self.cigamve_foregroundLayer.hidden;
            }
        }];
    }
}

@end

@implementation UIView (CIGAM_VisualEffectView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id (^block)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) = ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                if (selfObject.cigamve_keepHidden) {
                    firstArgv = YES;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        };
        // iOS 10 这两个 class 都有，iOS 11 开始只用第一个，后面那个不存在了
        OverrideImplementation(NSClassFromString(@"_UIVisualEffectSubview"), @selector(setHidden:), block);
        OverrideImplementation(NSClassFromString(@"_UIVisualEffectFilterView"), @selector(setHidden:), block);
    });
}

static char kAssociatedObjectKey_keepHidden;
- (void)setCigamve_keepHidden:(BOOL)cigamve_keepHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keepHidden, @(cigamve_keepHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 从语义来看，当 keepHidden = NO 时，并不意味着 hidden 就一定要为 NO，但为了方便添加了 foregroundColor 后再去除 foregroundColor 时做一些恢复性质的操作，这里就实现成 keepHidden = NO 时 hidden = NO
    self.hidden = cigamve_keepHidden;
}

- (BOOL)cigamve_keepHidden {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_keepHidden)) boolValue];
}

@end
