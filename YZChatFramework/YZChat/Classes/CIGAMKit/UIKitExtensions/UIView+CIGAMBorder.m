/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+CIGAMBorder.m
//  CIGAMKit
//
//  Created by MoLice on 2020/6/28.
//

#import "UIView+CIGAMBorder.h"
#import "CIGAMCore.h"
#import "CALayer+CIGAM.h"

@interface CAShapeLayer (CIGAMBorder)

@property(nonatomic, weak) UIView *_cigambd_targetBorderView;
@end

@implementation UIView (CIGAMBorder)

CIGAMSynthesizeIdStrongProperty(cigam_borderLayer, setCigam_borderLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            [selfObject _cigambd_setDefaultStyle];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *aDecoder, UIView *originReturnValue) {
            [selfObject _cigambd_setDefaultStyle];
            return originReturnValue;
        });
    });
}

- (void)_cigambd_setDefaultStyle {
    self.cigam_borderWidth = PixelOne;
    self.cigam_borderColor = UIColorSeparator;
}

- (void)_cigambd_createBorderLayerIfNeeded {
    BOOL shouldShowBorder = self.cigam_borderWidth > 0 && self.cigam_borderColor && self.cigam_borderPosition != CIGAMViewBorderPositionNone;
    if (!shouldShowBorder) {
        self.cigam_borderLayer.hidden = YES;
        return;
    }
    
    [CIGAMHelper executeBlock:^{
        OverrideImplementation([UIView class], @selector(layoutSublayersOfLayer:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CALayer *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, CALayer *);
                originSelectorIMP = (void (*)(id, SEL, CALayer *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (!selfObject.cigam_borderLayer || selfObject.cigam_borderLayer.hidden) return;
                selfObject.cigam_borderLayer.frame = selfObject.bounds;
                [selfObject.layer cigam_bringSublayerToFront:selfObject.cigam_borderLayer];
                [selfObject.cigam_borderLayer setNeedsLayout];// 把布局刷新逻辑剥离到 layer 内，方便在子线程里直接刷新 layer，如果放在 UIView 内，子线程里就无法主动请求刷新了
            };
        });
    } oncePerIdentifier:@"UIView (CIGAMBorder) layoutSublayers"];
    
    if (!self.cigam_borderLayer) {
        self.cigam_borderLayer = [CAShapeLayer layer];
        self.cigam_borderLayer._cigambd_targetBorderView = self;
        [self.cigam_borderLayer cigam_removeDefaultAnimations];
        self.cigam_borderLayer.fillColor = UIColorClear.CGColor;
        [self.layer addSublayer:self.cigam_borderLayer];
    }
    self.cigam_borderLayer.lineWidth = self.cigam_borderWidth;
    self.cigam_borderLayer.strokeColor = self.cigam_borderColor.CGColor;
    self.cigam_borderLayer.lineDashPhase = self.cigam_dashPhase;
    self.cigam_borderLayer.lineDashPattern = self.cigam_dashPattern;
    self.cigam_borderLayer.hidden = NO;
}

static char kAssociatedObjectKey_borderLocation;
- (void)setCigam_borderLocation:(CIGAMViewBorderLocation)cigam_borderLocation {
    BOOL shouldUpdateLayout = self.cigam_borderLocation != cigam_borderLocation;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(cigam_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cigambd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CIGAMViewBorderLocation)cigam_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setCigam_borderPosition:(CIGAMViewBorderPosition)cigam_borderPosition {
    BOOL shouldUpdateLayout = self.cigam_borderPosition != cigam_borderPosition;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(cigam_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cigambd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CIGAMViewBorderPosition)cigam_borderPosition {
    return (CIGAMViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setCigam_borderWidth:(CGFloat)cigam_borderWidth {
    BOOL shouldUpdateLayout = self.cigam_borderWidth != cigam_borderWidth;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(cigam_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cigambd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)cigam_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) cigam_CGFloatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setCigam_borderColor:(UIColor *)cigam_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, cigam_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cigambd_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (UIColor *)cigam_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setCigam_dashPhase:(CGFloat)cigam_dashPhase {
    BOOL shouldUpdateLayout = self.cigam_dashPhase != cigam_dashPhase;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(cigam_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cigambd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)cigam_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) cigam_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setCigam_dashPattern:(NSArray<NSNumber *> *)cigam_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, cigam_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _cigambd_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (NSArray *)cigam_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

@end

@implementation CAShapeLayer (CIGAMBorder)
CIGAMSynthesizeIdWeakProperty(_cigambd_targetBorderView, set_cigambd_targetBorderView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([CAShapeLayer class], @selector(layoutSublayers), ^(CAShapeLayer *selfObject) {
            if (!selfObject._cigambd_targetBorderView) return;
            
            UIView *view = selfObject._cigambd_targetBorderView;
            CGFloat borderWidth = selfObject.lineWidth;
            
            UIBezierPath *path = [UIBezierPath bezierPath];;
            
            CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
                return view.cigam_borderLocation == CIGAMViewBorderLocationInside ? inside : (view.cigam_borderLocation == CIGAMViewBorderLocationCenter ? center : outside);
            };
            
            CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
            CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth); // 两条相邻的边框连接的位置
            
            BOOL shouldShowTopBorder = (view.cigam_borderPosition & CIGAMViewBorderPositionTop) == CIGAMViewBorderPositionTop;
            BOOL shouldShowLeftBorder = (view.cigam_borderPosition & CIGAMViewBorderPositionLeft) == CIGAMViewBorderPositionLeft;
            BOOL shouldShowBottomBorder = (view.cigam_borderPosition & CIGAMViewBorderPositionBottom) == CIGAMViewBorderPositionBottom;
            BOOL shouldShowRightBorder = (view.cigam_borderPosition & CIGAMViewBorderPositionRight) == CIGAMViewBorderPositionRight;
            
            UIBezierPath *topPath = [UIBezierPath bezierPath];
            UIBezierPath *leftPath = [UIBezierPath bezierPath];
            UIBezierPath *bottomPath = [UIBezierPath bezierPath];
            UIBezierPath *rightPath = [UIBezierPath bezierPath];
            
            if (view.layer.cigam_originCornerRadius > 0) {
                
                CGFloat cornerRadius = view.layer.cigam_originCornerRadius;
                
                if (view.layer.cigam_maskedCorners) {
                    if ((view.layer.cigam_maskedCorners & CIGAMLayerMinXMinYCorner) == CIGAMLayerMinXMinYCorner) {
                        [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    } else {
                        [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    }
                    if ((view.layer.cigam_maskedCorners & CIGAMLayerMinXMaxYCorner) == CIGAMLayerMinXMaxYCorner) {
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                        [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    } else {
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, y)];
                    }
                    if ((view.layer.cigam_maskedCorners & CIGAMLayerMaxXMaxYCorner) == CIGAMLayerMaxXMaxYCorner) {
                        [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                        [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    } else {
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
                    }
                    if ((view.layer.cigam_maskedCorners & CIGAMLayerMaxXMinYCorner) == CIGAMLayerMaxXMinYCorner) {
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                        [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    } else {
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                    }
                } else {
                    [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                    [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                    [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                    [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                    
                    [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                    [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                    
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                    [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                }
                
            } else {
                [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                
                [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                
                CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                
                CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
            }
            
            if (shouldShowTopBorder && ![topPath isEmpty]) {
                [path appendPath:topPath];
            }
            if (shouldShowLeftBorder && ![leftPath isEmpty]) {
                [path appendPath:leftPath];
            }
            if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
                [path appendPath:bottomPath];
            }
            if (shouldShowRightBorder && ![rightPath isEmpty]) {
                [path appendPath:rightPath];
            }
            
            selfObject.path = path.CGPath;
        });
    });
}
@end
