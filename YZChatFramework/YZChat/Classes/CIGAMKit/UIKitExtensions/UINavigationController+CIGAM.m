/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationController+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 16/1/12.
//

#import "UINavigationController+CIGAM.h"
#import "CIGAMCore.h"
#import "CIGAMLog.h"
#import "CIGAMWeakObjectContainer.h"
#import "UIViewController+CIGAM.h"

@interface _CIGAMNavigationInteractiveGestureDelegator : NSObject <UIGestureRecognizerDelegate>

@property(nonatomic, weak, readonly) UINavigationController *parentViewController;
- (instancetype)initWithParentViewController:(UINavigationController *)parentViewController;
@end

@interface UINavigationController ()

@property(nonatomic, strong) NSMutableArray<CIGAMNavigationActionDidChangeBlock> *cigamnc_navigationActionDidChangeBlocks;
@property(nullable, nonatomic, readwrite) UIViewController *cigam_endedTransitionTopViewController;
@property(nullable, nonatomic, weak, readonly) id<UIGestureRecognizerDelegate> cigam_interactivePopGestureRecognizerDelegate;
@property(nullable, nonatomic, strong) _CIGAMNavigationInteractiveGestureDelegator *cigam_interactiveGestureDelegator;
@end

@implementation UINavigationController (CIGAM)

CIGAMSynthesizeIdStrongProperty(cigamnc_navigationActionDidChangeBlocks, setCigamnc_navigationActionDidChangeBlocks)
CIGAMSynthesizeIdWeakProperty(cigam_endedTransitionTopViewController, setCigam_endedTransitionTopViewController)
CIGAMSynthesizeIdWeakProperty(cigam_interactivePopGestureRecognizerDelegate, setCigam_interactivePopGestureRecognizerDelegate)
CIGAMSynthesizeIdStrongProperty(cigam_interactiveGestureDelegator, setCigam_interactiveGestureDelegator)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UINavigationController class], @selector(initWithNibName:bundle:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UINavigationController *(UINavigationController *selfObject, NSString *firstArgv, NSBundle *secondArgv) {
                
                // call super
                UINavigationController *(*originSelectorIMP)(id, SEL, NSString *, NSBundle *);
                originSelectorIMP = (UINavigationController *(*)(id, SEL, NSString *, NSBundle *))originalIMPProvider();
                UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                [selfObject cigam_didInitialize];
                
                return result;
            };
        });
        
        OverrideImplementation([UINavigationController class], @selector(initWithCoder:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UINavigationController *(UINavigationController *selfObject, NSCoder *firstArgv) {
                
                // call super
                UINavigationController *(*originSelectorIMP)(id, SEL, NSCoder *);
                originSelectorIMP = (UINavigationController *(*)(id, SEL, NSCoder *))originalIMPProvider();
                UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject cigam_didInitialize];
                
                return result;
            };
        });
        
        // iOS 12 及以前，initWithNavigationBarClass:toolbarClass:、initWithRootViewController: 会调用 initWithNibName:bundle:，所以这两个方法在 iOS 12 下不需要再次调用 cigam_didInitialize 了。
        if (@available(iOS 13.0, *)) {
            OverrideImplementation([UINavigationController class], @selector(initWithNavigationBarClass:toolbarClass:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(UINavigationController *selfObject, Class firstArgv, Class secondArgv) {
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL, Class, Class);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL, Class, Class))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                    
                    [selfObject cigam_didInitialize];
                    
                    return result;
                };
            });
            
            OverrideImplementation([UINavigationController class], @selector(initWithRootViewController:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(UINavigationController *selfObject, UIViewController *firstArgv) {
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL, UIViewController *);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL, UIViewController *))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    [selfObject cigam_didInitialize];
                    
                    return result;
                };
            });
        }
        
        
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(viewDidLoad), ^(UINavigationController *selfObject) {
            selfObject.cigam_interactivePopGestureRecognizerDelegate = selfObject.interactivePopGestureRecognizer.delegate;
            selfObject.cigam_interactiveGestureDelegator = [[_CIGAMNavigationInteractiveGestureDelegator alloc] initWithParentViewController:selfObject];
            selfObject.interactivePopGestureRecognizer.delegate = selfObject.cigam_interactiveGestureDelegator;
            
            // 根据 NavBarContainerClasses 的值来决定是否应用 bar.tintColor
            // tintColor 没有被添加 UI_APPEARANCE_SELECTOR，所以没有采用 UIAppearance 的方式去实现（虽然它实际上是支持的）
            if (CIGAMCMIActivated) {
                BOOL shouldSetTintColor = NO;
                if (NavBarContainerClasses.count) {
                    for (Class class in NavBarContainerClasses) {
                        if ([selfObject isKindOfClass:class]) {
                            shouldSetTintColor = YES;
                            break;
                        }
                    }
                } else {
                    shouldSetTintColor = YES;
                }
                if (shouldSetTintColor) {
                    selfObject.navigationBar.tintColor = NavBarTintColor;
                }
            }
            if (CIGAMCMIActivated) {
                BOOL shouldSetTintColor = NO;
                if (ToolBarContainerClasses.count) {
                    for (Class class in ToolBarContainerClasses) {
                        if ([selfObject isKindOfClass:class]) {
                            shouldSetTintColor = YES;
                            break;
                        }
                    }
                } else {
                    shouldSetTintColor = YES;
                }
                if (shouldSetTintColor) {
                    selfObject.toolbar.tintColor = ToolBarTintColor;
                }
            }
        });
        
        if (@available(iOS 11.0, *)) {
            OverrideImplementation(NSClassFromString([NSString cigam_stringByConcat:@"_", @"UINavigationBar", @"ContentView", nil]), NSSelectorFromString(@"__backButtonAction:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, id firstArgv) {
                    
                    if ([selfObject.superview isKindOfClass:UINavigationBar.class]) {
                        UINavigationBar *bar = (UINavigationBar *)selfObject.superview;
                        if ([bar.delegate isKindOfClass:UINavigationController.class]) {
                            UINavigationController *navController = (UINavigationController *)bar.delegate;
                            BOOL canPopViewController = [navController canPopViewController:navController.topViewController byPopGesture:NO];
                            if (!canPopViewController) return;
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, id);
                    originSelectorIMP = (void (*)(id, SEL, id))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                };
            });
        } else {
            OverrideImplementation([UINavigationBar class], NSSelectorFromString(@"_shouldPopForTouchAtPoint:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UINavigationBar *selfObject, CGPoint firstArgv) {

                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, firstArgv);

                    // 点击 navigationBar 任意地方都会触发这个方法，只有点到返回按钮时 result 才可能是 YES
                    if (result) {
                        if ([selfObject.delegate isKindOfClass:UINavigationController.class]) {
                            UINavigationController *navController = (UINavigationController *)selfObject.delegate;
                            BOOL canPopViewController = [navController canPopViewController:navController.topViewController byPopGesture:NO];
                            if (!canPopViewController) {
                                return NO;
                            }
                        }
                    }

                    return result;
                };
            });
        }
        
        OverrideImplementation([UINavigationController class], NSSelectorFromString(@"navigationTransitionView:didEndTransition:fromView:toView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UINavigationController *selfObject, UIView *transitionView, NSInteger transition, UIView *fromView, UIView *toView) {
                
                BOOL (*originSelectorIMP)(id, SEL, UIView *, NSInteger , UIView *, UIView *);
                originSelectorIMP = (BOOL (*)(id, SEL, UIView *, NSInteger , UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transitionView, transition, fromView, toView);
                selfObject.cigam_endedTransitionTopViewController = selfObject.topViewController;
            };
        });
        
#pragma mark - pushViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(pushViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                if (selfObject.presentedViewController) {
                    CIGAMLogWarn(NSStringFromClass(originClass), @"push 的时候 UINavigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用");
                }
                
                // call super
                void (^callSuperBlock)(void) = ^void(void) {
                    void (*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, viewController, animated);
                };
                
                BOOL willPushActually = viewController && ![viewController isKindOfClass:UITabBarController.class] && ![selfObject.viewControllers containsObject:viewController];
                
                if (!willPushActually) {
                    callSuperBlock();
                    return;
                }
                
                UIViewController *appearingViewController = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.topViewController ? @[selfObject.topViewController] : nil;
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionWillPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                callSuperBlock();
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionDidPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionPushCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
            };
        });
        
#pragma mark - popViewControllerAnimated:
        OverrideImplementation([UINavigationController class], @selector(popViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIViewController *(UINavigationController *selfObject, BOOL animated) {
                
                // call super
                UIViewController *(^callSuperBlock)(void) = ^UIViewController *(void) {
                    UIViewController *(*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (UIViewController *(*)(id, SEL, BOOL))originalIMPProvider();
                    UIViewController *result = originSelectorIMP(selfObject, originCMD, animated);
                    return result;
                };
                
                BOOL willPopActually = selfObject.viewControllers.count > 1;// 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = selfObject.viewControllers[selfObject.viewControllers.count - 2];
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.lastObject ? @[selfObject.viewControllers.lastObject] : nil;
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                UIViewController *result = callSuperBlock();
                
                // UINavigationController 不可见时 return 值可能为 nil
                // https://github.com/Tencent/CIGAM_iOS/issues/1180
                NSAssert(result && disappearingViewControllers && disappearingViewControllers.firstObject == result, @"CIGAM 认为 popViewController 会成功，但实际上失败了");
                disappearingViewControllers = result ? @[result] : disappearingViewControllers;
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });
        
#pragma mark - popToViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(popToViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *poppedViewControllers = originSelectorIMP(selfObject, originCMD, viewController, animated);
                    return poppedViewControllers;
                };
                
                BOOL willPopActually = selfObject.viewControllers.count > 1 && [selfObject.viewControllers containsObject:viewController] && selfObject.topViewController != viewController;// 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = nil;
                NSUInteger index = [selfObject.viewControllers indexOfObject:appearingViewController];
                if (index != NSNotFound) {
                    disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(index + 1, selfObject.viewControllers.count - index - 1)];
                }

                [selfObject setCigam_navigationAction:CIGAMNavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                NSArray<UIViewController *> *result = callSuperBlock();
                
                NSAssert(!(selfObject.isViewLoaded && selfObject.view.window) || [result isEqualToArray:disappearingViewControllers], @"CIGAM 计算得到的 popToViewController 结果和系统的不一致");
                disappearingViewControllers = result ?: disappearingViewControllers;
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });

#pragma mark - popToRootViewControllerAnimated:
        OverrideImplementation([UINavigationController class], @selector(popToRootViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, animated);
                    return result;
                };
                
                BOOL willPopActually = selfObject.viewControllers.count > 1;
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = selfObject.cigam_rootViewController;
                NSArray<UIViewController *> *disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(1, selfObject.viewControllers.count - 1)];
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                NSArray<UIViewController *> *result = callSuperBlock();
                
                // UINavigationController 不可见时 return 值可能为 nil
                // https://github.com/Tencent/CIGAM_iOS/issues/1180
                NSAssert(!(selfObject.isViewLoaded && selfObject.view.window) || [result isEqualToArray:disappearingViewControllers], @"CIGAM 计算得到的 popToRootViewController 结果和系统的不一致");
                disappearingViewControllers = result ?: disappearingViewControllers;
                
                [selfObject setCigam_navigationAction:CIGAMNavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });

#pragma mark - setViewControllers:animated:
        OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {

                UIViewController *appearingViewController = selfObject.topViewController != viewControllers.lastObject ? viewControllers.lastObject : nil;// setViewControllers 执行前后 topViewController 没有变化，则赋值为 nil，表示没有任何界面有“重新显示”，这个 nil 的值也用于在 CIGAMNavigationController 里实现 viewControllerKeepingAppearWhenSetViewControllersWithAnimated:
                NSMutableArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.mutableCopy;
                [disappearingViewControllers removeObjectsInArray:viewControllers];
                disappearingViewControllers = disappearingViewControllers.count ? disappearingViewControllers : nil;

                [selfObject setCigam_navigationAction:CIGAMNavigationActionWillSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                // call super
                void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, viewControllers, animated);

                [selfObject setCigam_navigationAction:CIGAMNavigationActionDidSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                [selfObject cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionSetCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setCigam_navigationAction:CIGAMNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
            };
        });
    });
}

- (void)cigam_didInitialize {
}

static char kAssociatedObjectKey_navigationAction;
- (void)setCigam_navigationAction:(CIGAMNavigationAction)cigam_navigationAction
                        animated:(BOOL)animated
         appearingViewController:(UIViewController *)appearingViewController
     disappearingViewControllers:(NSArray<UIViewController *> *)disappearingViewControllers {
    BOOL valueChanged = self.cigam_navigationAction != cigam_navigationAction;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationAction, @(cigam_navigationAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged && self.cigamnc_navigationActionDidChangeBlocks.count) {
        [self.cigamnc_navigationActionDidChangeBlocks enumerateObjectsUsingBlock:^(CIGAMNavigationActionDidChangeBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj(cigam_navigationAction, animated, self, appearingViewController, disappearingViewControllers);
        }];
    }
}

- (CIGAMNavigationAction)cigam_navigationAction {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationAction)) unsignedIntegerValue];
}

- (void)cigam_addNavigationActionDidChangeBlock:(CIGAMNavigationActionDidChangeBlock)block {
    if (!self.cigamnc_navigationActionDidChangeBlocks) {
        self.cigamnc_navigationActionDidChangeBlocks = NSMutableArray.new;
    }
    [self.cigamnc_navigationActionDidChangeBlocks addObject:block];
}

// TODO: molice 改为用 CIGAMNavigationAction 判断
- (BOOL)cigam_isPushing {
    BOOL isPushing = self.cigam_navigationAction > CIGAMNavigationActionWillPush && self.cigam_navigationAction <= CIGAMNavigationActionPushCompleted;
    return isPushing;
}

// TODO: molice 改为用 CIGAMNavigationAction 判断
- (BOOL)cigam_isPopping {
    BOOL isPopping = self.cigam_navigationAction > CIGAMNavigationActionWillPop && self.cigam_navigationAction <= CIGAMNavigationActionPopCompleted;
    return isPopping;
}

- (UIViewController *)cigam_topViewController {
    if (self.cigam_isPushing) {
        return self.topViewController;
    }
    return self.cigam_endedTransitionTopViewController ? self.cigam_endedTransitionTopViewController : self.topViewController;
}

- (nullable UIViewController *)cigam_rootViewController {
    return self.viewControllers.firstObject;
}

- (void)cigam_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 cigam_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    [self pushViewController:viewController animated:animated];
    if (completion) {
        [self cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
}

- (UIViewController *)cigam_popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 cigam_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    UIViewController *result = [self popViewControllerAnimated:animated];
    if (completion) {
        [self cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (NSArray<UIViewController *> *)cigam_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 cigam_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    NSArray<UIViewController *> *result = [self popToViewController:viewController animated:animated];
    if (completion) {
        [self cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (NSArray<UIViewController *> *)cigam_popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 cigam_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    NSArray<UIViewController *> *result = [self popToRootViewControllerAnimated:animated];
    if (completion) {
        [self cigam_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (BOOL)canPopViewController:(UIViewController *)viewController byPopGesture:(BOOL)byPopGesture {
    BOOL canPopViewController = YES;
    
    if ([viewController respondsToSelector:@selector(shouldPopViewControllerByBackButtonOrPopGesture:)] &&
        [viewController shouldPopViewControllerByBackButtonOrPopGesture:byPopGesture] == NO) {
        canPopViewController = NO;
    }
    
    return canPopViewController;
}

- (BOOL)shouldForceEnableInteractivePopGestureRecognizer {
    UIViewController *viewController = [self topViewController];
    return self.viewControllers.count > 1 && self.interactivePopGestureRecognizer.enabled && [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] && [viewController forceEnableInteractivePopGestureRecognizer];
}

@end


@implementation _CIGAMNavigationInteractiveGestureDelegator

- (instancetype)initWithParentViewController:(UINavigationController *)parentViewController {
    if (self = [super init]) {
        _parentViewController = parentViewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

// iOS 13.4 开始会优先询问该方法，只有返回 YES 后才会继续后续的逻辑
- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        NSObject <UIGestureRecognizerDelegate> *originGestureDelegate = self.parentViewController.cigam_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = YES;
            [originGestureDelegate cigam_performSelector:_cmd withPrimitiveReturnValue:&originalValue arguments:&gestureRecognizer, &event, nil];
            if (!originalValue && [self.parentViewController shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        BOOL canPopViewController = [self.parentViewController canPopViewController:self.parentViewController.topViewController byPopGesture:YES];
        if (canPopViewController) {
            if ([self.parentViewController.cigam_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
                return [self.parentViewController.cigam_interactivePopGestureRecognizerDelegate gestureRecognizerShouldBegin:gestureRecognizer];
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = self.parentViewController.cigam_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
            if (!originalValue && [self.parentViewController shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        if ([self.parentViewController.cigam_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
            return [self.parentViewController.cigam_interactivePopGestureRecognizerDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
        }
    }
    return NO;
}

// 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
        // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
        return YES;
    }
    return NO;
}

@end


@implementation UIViewController (BackBarButtonSupport)
@end
