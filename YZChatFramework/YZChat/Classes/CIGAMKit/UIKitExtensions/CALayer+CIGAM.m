/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CALayer+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 16/8/12.
//

#import "CALayer+CIGAM.h"
#import "UIView+CIGAM.h"
#import "CIGAMCore.h"
#import "CIGAMLog.h"
#import "UIColor+CIGAM.h"

@interface CALayer ()

@property(nonatomic, assign) float cigam_speedBeforePause;

@end

@implementation CALayer (CIGAM)

CIGAMSynthesizeFloatProperty(cigam_speedBeforePause, setCigam_speedBeforePause)
CIGAMSynthesizeCGFloatProperty(cigam_originCornerRadius, setCigam_originCornerRadius)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 由于其他方法需要通过调用 cigamlayer_setCornerRadius: 来执行 swizzle 前的实现，所以这里暂时用 ExchangeImplementations
        ExchangeImplementations([CALayer class], @selector(setCornerRadius:), @selector(cigamlayer_setCornerRadius:));
        
        ExtendImplementationOfNonVoidMethodWithoutArguments([CALayer class], @selector(init), CALayer *, ^CALayer *(CALayer *selfObject, CALayer *originReturnValue) {
            selfObject.cigam_speedBeforePause = selfObject.speed;
            selfObject.cigam_maskedCorners = CIGAMLayerAllCorner;
            return originReturnValue;
        });
        
        OverrideImplementation([CALayer class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGRect bounds) {
                
                // 对非法的 bounds，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(bounds)) {
                    CIGAMLogWarn(@"CALayer (CIGAM)", @"%@ setBounds:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(bounds), [NSThread callStackSymbols]);
                    if (CIGAMCMIActivated && !ShouldPrintCIGAMWarnLogToConsole) {
                        NSAssert(NO, @"CALayer setBounds: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        bounds = CGRectSafeValue(bounds);
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
            };
        });
        
        OverrideImplementation([CALayer class], @selector(setPosition:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGPoint position) {
                
                // 对非法的 position，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (isnan(position.x) || isnan(position.y)) {
                    CIGAMLogWarn(@"CALayer (CIGAM)", @"%@ setPosition:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGPoint(position), [NSThread callStackSymbols]);
                    if (CIGAMCMIActivated && !ShouldPrintCIGAMWarnLogToConsole) {
                        NSAssert(NO, @"CALayer setPosition: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        position = CGPointMake(CGFloatSafeValue(position.x), CGFloatSafeValue(position.y));
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, position);
            };
        });
    });
}

- (BOOL)cigam_isRootLayerOfView {
    return [self.delegate isKindOfClass:[UIView class]] && ((UIView *)self.delegate).layer == self;
}

- (void)cigamlayer_setCornerRadius:(CGFloat)cornerRadius {
    BOOL cornerRadiusChanged = flat(self.cigam_originCornerRadius) != flat(cornerRadius);// flat 处理，避免浮点精度问题
    self.cigam_originCornerRadius = cornerRadius;
    if (@available(iOS 11, *)) {
        [self cigamlayer_setCornerRadius:cornerRadius];
    } else {
        if (self.cigam_maskedCorners && ![self hasFourCornerRadius]) {
            [self cigamlayer_setCornerRadius:0];
        } else {
            [self cigamlayer_setCornerRadius:cornerRadius];
        }
        if (cornerRadiusChanged) {
            // 需要刷新mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (cornerRadiusChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.cigam_borderPosition > 0 && view.cigam_borderWidth > 0) {
                [view.cigam_borderLayer setNeedsLayout];// 直接调用 layer 的 setNeedsLayout，没有线程限制，如果通过 view 调用则需要在主线程才行
            }
        }
    }
}

static char kAssociatedObjectKey_pause;
- (void)setCigam_pause:(BOOL)cigam_pause {
    if (cigam_pause == self.cigam_pause) {
        return;
    }
    if (cigam_pause) {
        self.cigam_speedBeforePause = self.speed;
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0;
        self.timeOffset = pausedTime;
    } else {
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = self.cigam_speedBeforePause;
        self.timeOffset = 0;
        self.beginTime = 0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(cigam_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cigam_pause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

static char kAssociatedObjectKey_maskedCorners;
- (void)setCigam_maskedCorners:(CIGAMCornerMask)cigam_maskedCorners {
    BOOL maskedCornersChanged = cigam_maskedCorners != self.cigam_maskedCorners;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maskedCorners, @(cigam_maskedCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11, *)) {
        self.maskedCorners = (CACornerMask)cigam_maskedCorners;
    } else {
        if (cigam_maskedCorners && ![self hasFourCornerRadius]) {
            [self cigamlayer_setCornerRadius:0];
        }
        if (maskedCornersChanged) {
            // 需要刷新mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (maskedCornersChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.cigam_borderPosition > 0 && view.cigam_borderWidth > 0) {
                [view.cigam_borderLayer setNeedsLayout];// 直接调用 layer 的 setNeedsLayout，没有线程限制，如果通过 view 调用则需要在主线程才行
            }
        }
    }
}

- (CIGAMCornerMask)cigam_maskedCorners {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maskedCorners) unsignedIntegerValue];
}

- (void)cigam_sendSublayerToBack:(CALayer *)sublayer {
    [self insertSublayer:sublayer atIndex:0];
}

- (void)cigam_bringSublayerToFront:(CALayer *)sublayer {
    [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
}

- (void)cigam_removeDefaultAnimations {
    NSMutableDictionary<NSString *, id<CAAction>> *actions = @{NSStringFromSelector(@selector(bounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(position)): [NSNull null],
                                                               NSStringFromSelector(@selector(zPosition)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
                                                               NSStringFromSelector(@selector(transform)): [NSNull null],
                                                               BeginIgnoreClangWarning(-Wundeclared-selector)
                                                               NSStringFromSelector(@selector(hidden)): [NSNull null],
                                                               NSStringFromSelector(@selector(doubleSided)): [NSNull null],
                                                               EndIgnoreClangWarning
                                                               NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
                                                               NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(contents)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsRect)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
                                                               NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderWidth)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(opacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
                                                               NSStringFromSelector(@selector(filters)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
                                                               NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
                                                               NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowPath)): [NSNull null]}.mutableCopy;
    
    if (@available(iOS 11.0, *)) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(maskedCorners)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAShapeLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(path)): [NSNull null],
                                            NSStringFromSelector(@selector(fillColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeStart)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
                                            NSStringFromSelector(@selector(lineWidth)): [NSNull null],
                                            NSStringFromSelector(@selector(miterLimit)): [NSNull null],
                                            NSStringFromSelector(@selector(lineDashPhase)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAGradientLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(colors)): [NSNull null],
                                            NSStringFromSelector(@selector(locations)): [NSNull null],
                                            NSStringFromSelector(@selector(startPoint)): [NSNull null],
                                            NSStringFromSelector(@selector(endPoint)): [NSNull null]}];
    }
    
    self.actions = actions;
}

+ (void)cigam_performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation {
    if (!actionsWithoutAnimation) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    actionsWithoutAnimation();
    [CATransaction commit];
}

+ (CAShapeLayer *)cigam_separatorDashLayerWithLineLength:(NSInteger)lineLength
                                            lineSpacing:(NSInteger)lineSpacing
                                              lineWidth:(CGFloat)lineWidth
                                              lineColor:(CGColorRef)lineColor
                                           isHorizontal:(BOOL)isHorizontal {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColorClear.CGColor;
    layer.strokeColor = lineColor;
    layer.lineWidth = lineWidth;
    layer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:lineLength], [NSNumber numberWithInteger:lineSpacing], nil];
    layer.masksToBounds = YES;
    
    CGMutablePathRef path = CGPathCreateMutable();
    if (isHorizontal) {
        CGPathMoveToPoint(path, NULL, 0, lineWidth / 2);
        CGPathAddLineToPoint(path, NULL, SCREEN_WIDTH, lineWidth / 2);
    } else {
        CGPathMoveToPoint(path, NULL, lineWidth / 2, 0);
        CGPathAddLineToPoint(path, NULL, lineWidth / 2, SCREEN_HEIGHT);
    }
    layer.path = path;
    CGPathRelease(path);
    
    return layer;
}

+ (CAShapeLayer *)cigam_separatorDashLayerInHorizontal {
    CAShapeLayer *layer = [CAShapeLayer cigam_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:YES];
    return layer;
}

+ (CAShapeLayer *)cigam_separatorDashLayerInVertical {
    CAShapeLayer *layer = [CAShapeLayer cigam_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:NO];
    return layer;
}

+ (CALayer *)cigam_separatorLayer {
    CALayer *layer = [CALayer layer];
    [layer cigam_removeDefaultAnimations];
    layer.backgroundColor = UIColorSeparator.CGColor;
    layer.frame = CGRectMake(0, 0, 0, PixelOne);
    return layer;
}

+ (CALayer *)cigam_separatorLayerForTableView {
    CALayer *layer = [self cigam_separatorLayer];
    layer.backgroundColor = TableViewSeparatorColor.CGColor;
    return layer;
}

- (BOOL)hasFourCornerRadius {
    return (self.cigam_maskedCorners & CIGAMLayerMinXMinYCorner) == CIGAMLayerMinXMinYCorner &&
           (self.cigam_maskedCorners & CIGAMLayerMaxXMinYCorner) == CIGAMLayerMaxXMinYCorner &&
           (self.cigam_maskedCorners & CIGAMLayerMinXMaxYCorner) == CIGAMLayerMinXMaxYCorner &&
           (self.cigam_maskedCorners & CIGAMLayerMaxXMaxYCorner) == CIGAMLayerMaxXMaxYCorner;
}

@end

@implementation UIView (CIGAM_CornerRadius)

static NSString *kMaskName = @"CIGAM_CornerRadius_Mask";

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([CALayer class], @selector(layoutSublayers), ^(CALayer *selfObject) {
            if (@available(iOS 11, *)) {
            } else {
                if (selfObject.mask && ![selfObject.mask.name isEqualToString:kMaskName]) {
                    return;
                }
                if (selfObject.cigam_maskedCorners) {
                    if (selfObject.cigam_originCornerRadius <= 0 || [selfObject hasFourCornerRadius]) {
                        if (selfObject.mask) {
                            selfObject.mask = nil;
                        }
                    } else {
                        CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
                        cornerMaskLayer.name = kMaskName;
                        UIRectCorner rectCorner = 0;
                        if ((selfObject.cigam_maskedCorners & CIGAMLayerMinXMinYCorner) == CIGAMLayerMinXMinYCorner) {
                            rectCorner |= UIRectCornerTopLeft;
                        }
                        if ((selfObject.cigam_maskedCorners & CIGAMLayerMaxXMinYCorner) == CIGAMLayerMaxXMinYCorner) {
                            rectCorner |= UIRectCornerTopRight;
                        }
                        if ((selfObject.cigam_maskedCorners & CIGAMLayerMinXMaxYCorner) == CIGAMLayerMinXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomLeft;
                        }
                        if ((selfObject.cigam_maskedCorners & CIGAMLayerMaxXMaxYCorner) == CIGAMLayerMaxXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomRight;
                        }
                        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:selfObject.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(selfObject.cigam_originCornerRadius, selfObject.cigam_originCornerRadius)];
                        cornerMaskLayer.frame = CGRectMakeWithSize(selfObject.bounds.size);
                        cornerMaskLayer.path = path.CGPath;
                        selfObject.mask = cornerMaskLayer;
                    }
                }
            }
        });
    });
}
                
- (BOOL)hasFourCornerRadius {
    return (self.layer.cigam_maskedCorners & CIGAMLayerMinXMinYCorner) == CIGAMLayerMinXMinYCorner &&
           (self.layer.cigam_maskedCorners & CIGAMLayerMaxXMinYCorner) == CIGAMLayerMaxXMinYCorner &&
           (self.layer.cigam_maskedCorners & CIGAMLayerMinXMaxYCorner) == CIGAMLayerMinXMaxYCorner &&
           (self.layer.cigam_maskedCorners & CIGAMLayerMaxXMaxYCorner) == CIGAMLayerMaxXMaxYCorner;
}

@end

@interface CAShapeLayer (CIGAM_DynamicColor)

@property(nonatomic, strong) UIColor *qcl_originalFillColor;
@property(nonatomic, strong) UIColor *qcl_originalStrokeColor;

@end

@implementation CAShapeLayer (CIGAM_DynamicColor)

CIGAMSynthesizeIdStrongProperty(qcl_originalFillColor, setQcl_originalFillColor)
CIGAMSynthesizeIdStrongProperty(qcl_originalStrokeColor, setQcl_originalStrokeColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CAShapeLayer class], @selector(setFillColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) cigam_getBoundObjectForKey:CIGAMCGColorOriginalColorBindKey];
                selfObject.qcl_originalFillColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        OverrideImplementation([CAShapeLayer class], @selector(setStrokeColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) cigam_getBoundObjectForKey:CIGAMCGColorOriginalColorBindKey];
                selfObject.qcl_originalStrokeColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
    });
}

- (void)cigam_setNeedsUpdateDynamicStyle {
    [super cigam_setNeedsUpdateDynamicStyle];
    
    if (self.qcl_originalFillColor) {
        self.fillColor = self.qcl_originalFillColor.CGColor;
    }
    
    if (self.qcl_originalStrokeColor) {
        self.strokeColor = self.qcl_originalStrokeColor.CGColor;
    }
}

@end

@interface CAGradientLayer (CIGAM_DynamicColor)

@property(nonatomic, strong) NSArray <UIColor *>* qcl_originalColors;

@end

@implementation CAGradientLayer (CIGAM_DynamicColor)

CIGAMSynthesizeIdStrongProperty(qcl_originalColors, setQcl_originalColors)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CAGradientLayer class], @selector(setColors:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAGradientLayer *selfObject, NSArray *colors) {
                
           
                void (*originSelectorIMP)(id, SEL, NSArray *);
                originSelectorIMP = (void (*)(id, SEL, NSArray *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, colors);
                
                
                __block BOOL hasDynamicColor = NO;
                NSMutableArray *originalColors = [NSMutableArray array];
                [colors enumerateObjectsUsingBlock:^(id color, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIColor *originalColor = [color cigam_getBoundObjectForKey:CIGAMCGColorOriginalColorBindKey];
                    if (originalColor) {
                        hasDynamicColor = YES;
                        [originalColors addObject:originalColor];
                    } else {
                        [originalColors addObject:[UIColor colorWithCGColor:(__bridge CGColorRef _Nonnull)(color)]];
                    }
                }];
                
                if (hasDynamicColor) {
                    selfObject.qcl_originalColors = originalColors;
                } else {
                    selfObject.qcl_originalColors = nil;
                }
                
            };
        });
    });
}

- (void)cigam_setNeedsUpdateDynamicStyle {
    [super cigam_setNeedsUpdateDynamicStyle];
    
    if (self.qcl_originalColors) {
        NSMutableArray *colors = [NSMutableArray array];
        [self.qcl_originalColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull color, NSUInteger idx, BOOL * _Nonnull stop) {
            [colors addObject:(__bridge id _Nonnull)(color.CGColor)];
        }];
        self.colors = colors;
    }
}

@end
