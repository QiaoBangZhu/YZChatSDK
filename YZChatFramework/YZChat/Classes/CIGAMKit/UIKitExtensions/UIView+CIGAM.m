/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 15/7/20.
//

#import "UIView+CIGAM.h"
#import "CIGAMCore.h"
#import "UIColor+CIGAM.h"
#import "NSObject+CIGAM.h"
#import "UIImage+CIGAM.h"
#import "NSNumber+CIGAM.h"
#import "UIViewController+CIGAM.h"
#import "CIGAMLog.h"
#import "CIGAMWeakObjectContainer.h"

@interface UIView ()

/// CIGAM_Debug
@property(nonatomic, assign, readwrite) BOOL cigam_hasDebugColor;
@end


@implementation UIView (CIGAM)

CIGAMSynthesizeBOOLProperty(cigam_tintColorCustomized, setCigam_tintColorCustomized)
CIGAMSynthesizeIdCopyProperty(cigam_frameWillChangeBlock, setCigam_frameWillChangeBlock)
CIGAMSynthesizeIdCopyProperty(cigam_frameDidChangeBlock, setCigam_frameDidChangeBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setTintColor:), UIColor *, ^(UIView *selfObject, UIColor *tintColor) {
            selfObject.cigam_tintColorCustomized = !!tintColor;
        });
        
        // 这个私有方法在 view 被调用 becomeFirstResponder 并且处于 window 上时，才会被调用，所以比 becomeFirstResponder 更适合用来检测
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], NSSelectorFromString(@"_didChangeToFirstResponder:"), id, ^(UIView *selfObject, id firstArgv) {
            if (selfObject == firstArgv && [selfObject conformsToProtocol:@protocol(UITextInput)]) {
                // 像 CIGAMModalPresentationViewController 那种以 window 的形式展示浮层，浮层里的输入框 becomeFirstResponder 的场景，[window makeKeyAndVisible] 被调用后，就会立即走到这里，但此时该 window 尚不是 keyWindow，所以这里延迟到下一个 runloop 里再去判断
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (IS_DEBUG && ![selfObject isKindOfClass:[UIWindow class]] && selfObject.window && !selfObject.window.keyWindow) {
                        [selfObject CIGAMSymbolicUIViewBecomeFirstResponderWithoutKeyWindow];
                    }
                });
            }
        });
    });
}

- (instancetype)cigam_initWithSize:(CGSize)size {
    return [self initWithFrame:CGRectMakeWithSize(size)];
}

- (void)setCigam_frameApplyTransform:(CGRect)cigam_frameApplyTransform {
    self.frame = CGRectApplyAffineTransformWithAnchorPoint(cigam_frameApplyTransform, self.transform, self.layer.anchorPoint);
}

- (CGRect)cigam_frameApplyTransform {
    return self.frame;
}

- (UIEdgeInsets)cigam_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)cigam_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

static char kAssociatedObjectKey_outsideEdge;
- (void)setCigam_outsideEdge:(UIEdgeInsets)cigam_outsideEdge {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_outsideEdge, @(cigam_outsideEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!UIEdgeInsetsEqualToEdgeInsets(cigam_outsideEdge, UIEdgeInsetsZero)) {
        [CIGAMHelper executeBlock:^{
            OverrideImplementation([UIView class], @selector(pointInside:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UIControl *selfObject, CGPoint point, UIEvent *event) {
                    
                    if (!UIEdgeInsetsEqualToEdgeInsets(selfObject.cigam_outsideEdge, UIEdgeInsetsZero)) {
                        CGRect rect = UIEdgeInsetsInsetRect(selfObject.bounds, selfObject.cigam_outsideEdge);
                        BOOL result = CGRectContainsPoint(rect, point);
                        return result;
                    }
                    
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint, UIEvent *);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint, UIEvent *))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, point, event);
                    return result;
                };
            });
        } oncePerIdentifier:@"UIView (CIGAM) outsideEdge"];
    }
}

- (UIEdgeInsets)cigam_outsideEdge {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_outsideEdge)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_tintColorDidChangeBlock;
- (void)setCigam_tintColorDidChangeBlock:(void (^)(__kindof UIView * _Nonnull))cigam_tintColorDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChangeBlock, cigam_tintColorDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (cigam_tintColorDidChangeBlock) {
        [CIGAMHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(tintColorDidChange), ^(UIView *selfObject) {
                if (selfObject.cigam_tintColorDidChangeBlock) {
                    selfObject.cigam_tintColorDidChangeBlock(selfObject);
                }
            });
        } oncePerIdentifier:@"UIView (CIGAM) tintColorDidChangeBlock"];
    }
}

- (void (^)(__kindof UIView * _Nonnull))cigam_tintColorDidChangeBlock {
    return (void (^)(__kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChangeBlock);
}

static char kAssociatedObjectKey_hitTestBlock;
- (void)setCigam_hitTestBlock:(__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))cigam_hitTestBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock, cigam_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [CIGAMHelper executeBlock:^{
        ExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.cigam_hitTestBlock) {
                UIView *view = selfObject.cigam_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });
    } oncePerIdentifier:@"UIView (CIGAM) hitTestBlock"];
}

- (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))cigam_hitTestBlock {
    return (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock);
}

- (CGPoint)cigam_convertPoint:(CGPoint)point toView:(nullable UIView *)view {
    if (view) {
        return [view cigam_convertPoint:point fromView:view];
    }
    return [self convertPoint:point toView:view];
}

- (CGPoint)cigam_convertPoint:(CGPoint)point fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGPoint pointInFromWindow = fromWindow == view ? point : [view convertPoint:point toView:nil];
        CGPoint pointInSelfWindow = [selfWindow convertPoint:pointInFromWindow fromWindow:fromWindow];
        CGPoint pointInSelf = selfWindow == self ? pointInSelfWindow : [self convertPoint:pointInSelfWindow fromView:nil];
        return pointInSelf;
    }
    return [self convertPoint:point fromView:view];
}

- (CGRect)cigam_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view cigam_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)cigam_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

+ (void)cigam_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)cigam_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)cigam_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        if (animations) {
            animations();
        }
    }
}

+ (void)cigam_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (void)CIGAMSymbolicUIViewBecomeFirstResponderWithoutKeyWindow {
    CIGAMLogWarn(@"UIView (CIGAM)", @"尝试让一个处于非 keyWindow 上的 %@ becomeFirstResponder，可能导致界面显示异常，请添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

@end

@implementation UIView (CIGAM_ViewController)

CIGAMSynthesizeBOOLProperty(cigam_isControllerRootView, setCigam_isControllerRootView)

- (BOOL)cigam_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    UIViewController *viewController = self.cigam_viewController;
    return viewController.cigam_visibleState >= CIGAMViewControllerWillAppear && viewController.cigam_visibleState < CIGAMViewControllerWillDisappear;
}

static char kAssociatedObjectKey_viewController;
- (void)setCigam_viewController:(__kindof UIViewController * _Nullable)cigam_viewController {
    CIGAMWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController);
    if (!weakContainer) {
        weakContainer = [[CIGAMWeakObjectContainer alloc] init];
    }
    weakContainer.object = cigam_viewController;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewController, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.cigam_isControllerRootView = !!cigam_viewController;
}

- (__kindof UIViewController *)cigam_viewController {
    if (self.cigam_isControllerRootView) {
        return (__kindof UIViewController *)((CIGAMWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController)).object;
    }
    return self.superview.cigam_viewController;
}

@end

@interface UIViewController (CIGAM_View)

@end

@implementation UIViewController (CIGAM_View)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            if (@available(iOS 11.0, *)) {
                selfObject.view.cigam_viewController = selfObject;
            } else {
                // 临时修复 iOS 10.0.2 上在输入框内切换输入法可能引发死循环的 bug，待查
                // https://github.com/Tencent/CIGAM_iOS/issues/471
                ((UIView *)[selfObject cigam_valueForKey:@"_view"]).cigam_viewController = selfObject;
            }
        });
    });
}

@end


@implementation UIView (CIGAM_Runtime)

- (BOOL)cigam_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIStackView class],
                                               [UILabel class],
                                               [UIButton class],
                                               [UISegmentedControl class],
                                               [UITextField class],
                                               [UISlider class],
                                               [UISwitch class],
                                               [UIActivityIndicatorView class],
                                               [UIProgressView class],
                                               [UIPageControl class],
                                               [UIStepper class],
                                               [UITableView class],
                                               [UITableViewCell class],
                                               [UIImageView class],
                                               [UICollectionView class],
                                               [UICollectionViewCell class],
                                               [UICollectionReusableView class],
                                               [UITextView class],
                                               [UIScrollView class],
                                               [UIDatePicker class],
                                               [UIPickerView class],
                                               [UIVisualEffectView class],
                                               // Apple 不再接受使用了 UIWebView 的 App 提交，所以这里去掉 UIWebView
                                               // https://github.com/Tencent/CIGAM_iOS/issues/741
//                                               [UIWebView class],
                                               [UIWindow class],
                                               [UINavigationBar class],
                                               [UIToolbar class],
                                               [UITabBar class],
                                               [UISearchBar class],
                                               [UIControl class],
                                               [UIView class],
                                               nil];
    
    for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
        Class superclass = viewSuperclasses[i];
        if ([self cigam_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end


const CGFloat CIGAMViewSelfSizingHeight = INFINITY;

@implementation UIView (CIGAM_Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIView class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect frame) {
                
                // CIGAMViewSelfSizingHeight 的功能
                if (frame.size.width > 0 && isinf(frame.size.height)) {
                    CGFloat height = flat([selfObject sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
                    frame = CGRectSetHeight(frame, height);
                }
                
                // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(frame)) {
                    CIGAMLogWarn(@"UIView (CIGAM)", @"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
                    if (CIGAMCMIActivated && !ShouldPrintCIGAMWarnLogToConsole) {
                        NSAssert(NO, @"UIView setFrame: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        frame = CGRectSafeValue(frame);
                    }
                }
                
                CGRect precedingFrame = selfObject.frame;
                BOOL valueChange = !CGRectEqualToRect(frame, precedingFrame);
                if (selfObject.cigam_frameWillChangeBlock && valueChange) {
                    frame = selfObject.cigam_frameWillChangeBlock(selfObject, frame);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
                if (selfObject.cigam_frameDidChangeBlock && valueChange) {
                    selfObject.cigam_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect bounds) {
                
                CGRect precedingFrame = selfObject.frame;
                CGRect precedingBounds = selfObject.bounds;
                BOOL valueChange = !CGSizeEqualToSize(bounds.size, precedingBounds.size);// bounds 只有 size 发生变化才会影响 frame
                if (selfObject.cigam_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectMake(CGRectGetMinX(precedingFrame) + CGFloatGetCenter(CGRectGetWidth(bounds), CGRectGetWidth(precedingFrame)), CGRectGetMinY(precedingFrame) + CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(precedingFrame)), bounds.size.width, bounds.size.height);
                    followingFrame = selfObject.cigam_frameWillChangeBlock(selfObject, followingFrame);
                    bounds = CGRectSetSize(bounds, followingFrame.size);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
                
                if (selfObject.cigam_frameDidChangeBlock && valueChange) {
                    selfObject.cigam_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setCenter:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGPoint center) {
                
                CGRect precedingFrame = selfObject.frame;
                CGPoint precedingCenter = selfObject.center;
                BOOL valueChange = !CGPointEqualToPoint(center, precedingCenter);
                if (selfObject.cigam_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectSetXY(precedingFrame, center.x - CGRectGetWidth(selfObject.frame) / 2, center.y - CGRectGetHeight(selfObject.frame) / 2);
                    followingFrame = selfObject.cigam_frameWillChangeBlock(selfObject, followingFrame);
                    center = CGPointMake(CGRectGetMidX(followingFrame), CGRectGetMidY(followingFrame));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, center);
                
                if (selfObject.cigam_frameDidChangeBlock && valueChange) {
                    selfObject.cigam_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setTransform:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGAffineTransform transform) {
                
                CGRect precedingFrame = selfObject.frame;
                CGAffineTransform precedingTransform = selfObject.transform;
                BOOL valueChange = !CGAffineTransformEqualToTransform(transform, precedingTransform);
                if (selfObject.cigam_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectApplyAffineTransformWithAnchorPoint(precedingFrame, transform, selfObject.layer.anchorPoint);
                    selfObject.cigam_frameWillChangeBlock(selfObject, followingFrame);// 对于 CGAffineTransform，无法根据修改后的 rect 来算出新的 transform，所以就不修改 transform 的值了
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGAffineTransform);
                originSelectorIMP = (void (*)(id, SEL, CGAffineTransform))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transform);
                
                if (selfObject.cigam_frameDidChangeBlock && valueChange) {
                    selfObject.cigam_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
    });
}

- (CGFloat)cigam_top {
    return CGRectGetMinY(self.frame);
}

- (void)setCigam_top:(CGFloat)top {
    self.frame = CGRectSetY(self.frame, top);
}

- (CGFloat)cigam_left {
    return CGRectGetMinX(self.frame);
}

- (void)setCigam_left:(CGFloat)left {
    self.frame = CGRectSetX(self.frame, left);
}

- (CGFloat)cigam_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setCigam_bottom:(CGFloat)bottom {
    self.frame = CGRectSetY(self.frame, bottom - CGRectGetHeight(self.frame));
}

- (CGFloat)cigam_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setCigam_right:(CGFloat)right {
    self.frame = CGRectSetX(self.frame, right - CGRectGetWidth(self.frame));
}

- (CGFloat)cigam_width {
    return CGRectGetWidth(self.frame);
}

- (void)setCigam_width:(CGFloat)width {
    self.frame = CGRectSetWidth(self.frame, width);
}

- (CGFloat)cigam_height {
    return CGRectGetHeight(self.frame);
}

- (void)setCigam_height:(CGFloat)height {
    self.frame = CGRectSetHeight(self.frame, height);
}

- (CGFloat)cigam_extendToTop {
    return self.cigam_top;
}

- (void)setCigam_extendToTop:(CGFloat)cigam_extendToTop {
    self.cigam_height = self.cigam_bottom - cigam_extendToTop;
    self.cigam_top = cigam_extendToTop;
}

- (CGFloat)cigam_extendToLeft {
    return self.cigam_left;
}

- (void)setCigam_extendToLeft:(CGFloat)cigam_extendToLeft {
    self.cigam_width = self.cigam_right - cigam_extendToLeft;
    self.cigam_left = cigam_extendToLeft;
}

- (CGFloat)cigam_extendToBottom {
    return self.cigam_bottom;
}

- (void)setCigam_extendToBottom:(CGFloat)cigam_extendToBottom {
    self.cigam_height = cigam_extendToBottom - self.cigam_top;
    self.cigam_bottom = cigam_extendToBottom;
}

- (CGFloat)cigam_extendToRight {
    return self.cigam_right;
}

- (void)setCigam_extendToRight:(CGFloat)cigam_extendToRight {
    self.cigam_width = cigam_extendToRight - self.cigam_left;
    self.cigam_right = cigam_extendToRight;
}

- (CGFloat)cigam_leftWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)cigam_topWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

@end


@implementation UIView (CGAffineTransform)

- (CGFloat)cigam_scaleX {
    return self.transform.a;
}

- (CGFloat)cigam_scaleY {
    return self.transform.d;
}

- (CGFloat)cigam_translationX {
    return self.transform.tx;
}

- (CGFloat)cigam_translationY {
    return self.transform.ty;
}

@end


@implementation UIView (CIGAM_Snapshotting)

- (UIImage *)cigam_snapshotLayerImage {
    return [UIImage cigam_imageWithView:self];
}

- (UIImage *)cigam_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage cigam_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end


@implementation UIView (CIGAM_Debug)

CIGAMSynthesizeBOOLProperty(cigam_needsDifferentDebugColor, setCigam_needsDifferentDebugColor)
CIGAMSynthesizeBOOLProperty(cigam_hasDebugColor, setCigam_hasDebugColor)

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setCigam_shouldShowDebugColor:(BOOL)cigam_shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(cigam_shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_shouldShowDebugColor) {
        [CIGAMHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
                if (selfObject.cigam_shouldShowDebugColor) {
                    selfObject.cigam_hasDebugColor = YES;
                    selfObject.backgroundColor = [selfObject cigam_debugColor];
                    [selfObject cigam_renderColorWithSubviews:selfObject.subviews];
                }
            });
        } oncePerIdentifier:@"UIView (CIGAMDebug) shouldShowDebugColor"];
        
        [self setNeedsLayout];
    }
}
- (BOOL)cigam_shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_layoutSubviewsBlock;
- (void)setCigam_layoutSubviewsBlock:(void (^)(__kindof UIView * _Nonnull))cigam_layoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock, cigam_layoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    Class viewClass = self.class;
    [CIGAMHelper executeBlock:^{
        ExtendImplementationOfVoidMethodWithoutArguments(viewClass, @selector(layoutSubviews), ^(__kindof UIView *selfObject) {
            if (selfObject.cigam_layoutSubviewsBlock && [selfObject isMemberOfClass:viewClass]) {
                selfObject.cigam_layoutSubviewsBlock(selfObject);
            }
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UIView %@-%@", NSStringFromClass(viewClass), NSStringFromSelector(@selector(layoutSubviews))]];
}

- (void (^)(UIView * _Nonnull))cigam_layoutSubviewsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock);
}

static char kAssociatedObjectKey_sizeThatFitsBlock;
- (void)setCigam_sizeThatFitsBlock:(CGSize (^)(__kindof UIView * _Nonnull, CGSize, CGSize))cigam_sizeThatFitsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock, cigam_sizeThatFitsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (!cigam_sizeThatFitsBlock) return;
    
    // Extend 每个实例对象的类是为了保证比子类的 sizeThatFits 逻辑要更晚调用
    Class viewClass = self.class;
    [CIGAMHelper executeBlock:^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument(viewClass, @selector(sizeThatFits:), CGSize, CGSize, ^CGSize(UIView *selfObject, CGSize firstArgv, CGSize originReturnValue) {
            if (selfObject.cigam_sizeThatFitsBlock && [selfObject isMemberOfClass:viewClass]) {
                originReturnValue = selfObject.cigam_sizeThatFitsBlock(selfObject, firstArgv, originReturnValue);
            }
            return originReturnValue;
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UIView %@-%@", NSStringFromClass(viewClass), NSStringFromSelector(@selector(sizeThatFits:))]];
}

- (CGSize (^)(__kindof UIView * _Nonnull, CGSize, CGSize))cigam_sizeThatFitsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock);
}

- (void)cigam_renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self cigam_renderColorWithSubviews:stackView.arrangedSubviews];
        }
        view.cigam_hasDebugColor = YES;
        view.cigam_shouldShowDebugColor = self.cigam_shouldShowDebugColor;
        view.cigam_needsDifferentDebugColor = self.cigam_needsDifferentDebugColor;
        view.backgroundColor = [self cigam_debugColor];
    }
}

- (UIColor *)cigam_debugColor {
    if (!self.cigam_needsDifferentDebugColor) {
        return UIColorTestRed;
    } else {
        return [[UIColor cigam_randomColor] colorWithAlphaComponent:.3];
    }
}

@end
