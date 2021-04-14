/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMNavigationController.m
//  cigam
//
//  Created by CIGAM Team on 14-6-24.
//

#import "CIGAMNavigationController.h"
#import "CIGAMCore.h"
#import "CIGAMNavigationTitleView.h"
#import "CIGAMCommonViewController.h"
#import "UIViewController+CIGAM.h"
#import "UINavigationController+CIGAM.h"
#import "UIView+CIGAM.h"
#import "UINavigationItem+CIGAM.h"
#import "UINavigationController+CIGAM.h"
#import "CIGAMLog.h"
#import "CIGAMMultipleDelegates.h"
#import "CIGAMWeakObjectContainer.h"

@protocol CIGAM_viewWillAppearNotifyDelegate <NSObject>

- (void)cigam_viewControllerDidInvokeViewWillAppear:(UIViewController *)viewController;

@end

@interface _CIGAMNavigationControllerDelegator : NSObject <CIGAMNavigationControllerDelegate>

@property(nonatomic, weak) CIGAMNavigationController *navigationController;
@end

@interface CIGAMNavigationController () <UIGestureRecognizerDelegate, CIGAM_viewWillAppearNotifyDelegate>

@property(nonatomic, strong) _CIGAMNavigationControllerDelegator *delegator;

/// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面。
/// 在 getter 方法里会根据配置表开关 PreventConcurrentNavigationControllerTransitions 的值来控制这个属性是否生效。
@property(nonatomic, assign) BOOL isViewControllerTransiting;

/// 即将要被pop的controller
@property(nonatomic, weak) UIViewController *viewControllerPopping;

@end

@interface UIViewController (CIGAMNavigationControllerTransition)

@property(nonatomic, weak) id<CIGAM_viewWillAppearNotifyDelegate> cigam_viewWillAppearNotifyDelegate;

@end

@implementation UIViewController (CIGAMNavigationControllerTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIViewController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if ([selfObject.cigam_viewWillAppearNotifyDelegate respondsToSelector:@selector(cigam_viewControllerDidInvokeViewWillAppear:)]) {
                    [selfObject.cigam_viewWillAppearNotifyDelegate cigam_viewControllerDidInvokeViewWillAppear:selfObject];
                }
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if ([selfObject.navigationController.viewControllers containsObject:selfObject] && [selfObject.navigationController isKindOfClass:[CIGAMNavigationController class]]) {
                    ((CIGAMNavigationController *)selfObject.navigationController).isViewControllerTransiting = NO;
                }
                selfObject.cigam_poppingByInteractivePopGestureRecognizer = NO;
                selfObject.cigam_willAppearByInteractivePopGestureRecognizer = NO;
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidDisappear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                selfObject.cigam_poppingByInteractivePopGestureRecognizer = NO;
                selfObject.cigam_willAppearByInteractivePopGestureRecognizer = NO;
            };
        });
    });
}

static char kAssociatedObjectKey_cigam_viewWillAppearNotifyDelegate;
- (void)setCigam_viewWillAppearNotifyDelegate:(id<CIGAM_viewWillAppearNotifyDelegate>)cigam_viewWillAppearNotifyDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cigam_viewWillAppearNotifyDelegate, [[CIGAMWeakObjectContainer alloc] initWithObject:cigam_viewWillAppearNotifyDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<CIGAM_viewWillAppearNotifyDelegate>)cigam_viewWillAppearNotifyDelegate {
    id weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_cigam_viewWillAppearNotifyDelegate);
    if ([weakContainer isKindOfClass:[CIGAMWeakObjectContainer class]]) {
        id notifyDelegate = [weakContainer object];
        return notifyDelegate;
    }
    return nil;
}

@end

@implementation CIGAMNavigationController

#pragma mark - 生命周期函数 && 基类方法重写

- (void)cigam_didInitialize {
    [super cigam_didInitialize];
    self.cigam_multipleDelegatesEnabled = YES;
    self.delegator = [[_CIGAMNavigationControllerDelegator alloc] init];
    self.delegator.navigationController = self;
    self.delegate = self.delegator;
    
    BeginIgnoreDeprecatedWarning
    [self didInitialize];
    EndIgnoreDeprecatedWarning
}

- (void)didInitialize {
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 手势允许多次addTarget
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleInteractivePopGestureRecognizer:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self willShowViewController:self.topViewController animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didShowViewController:self.topViewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        // 只剩 1 个 viewController 或者不存在 viewController 时，调用 popViewControllerAnimated: 后不会有任何变化，所以不需要触发 willPop / didPop
        return [super popViewControllerAnimated:animated];
    }
    
    UIViewController *viewController = [self topViewController];
    self.viewControllerPopping = viewController;
    
    if (animated) {
        self.viewControllerPopping.cigam_viewWillAppearNotifyDelegate = self;
        
        self.isViewControllerTransiting = YES;
    }
    
    if ([viewController respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewController) willPopInNavigationControllerWithAnimated:animated];
    }
    
    //    CIGAMLog(@"NavigationItem", @"call popViewControllerAnimated:%@, current viewControllers = %@", StringFromBOOL(animated), self.viewControllers);
    
    viewController = [super popViewControllerAnimated:animated];
    
    //    CIGAMLog(@"NavigationItem", @"pop viewController: %@", viewController);
    
    if ([viewController respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewController) didPopInNavigationControllerWithAnimated:animated];
    }
    return viewController;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController || self.topViewController == viewController) {
        // 当要被 pop 到的 viewController 已经处于最顶层时，调用 super 默认也是什么都不做，所以直接 return 掉
        return [super popToViewController:viewController animated:animated];
    }
    
    self.viewControllerPopping = self.topViewController;
    
    if (animated) {
        self.viewControllerPopping.cigam_viewWillAppearNotifyDelegate = self;
        self.isViewControllerTransiting = YES;
    }
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if (viewControllerPopping == viewController) {
            break;
        }
        
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> *poppedViewControllers = [super popToViewController:viewController animated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 在配合 tabBarItem 使用的情况下，快速重复点击相同 item 可能会重复调用 popToRootViewControllerAnimated:，而此时其实已经处于 rootViewController 了，就没必要继续走后续的流程，否则一些变量会得不到重置。
    if (self.topViewController == self.cigam_rootViewController) {
        return nil;
    }
    
    self.viewControllerPopping = self.topViewController;
    
    if (animated) {
        self.viewControllerPopping.cigam_viewWillAppearNotifyDelegate = self;
        self.isViewControllerTransiting = YES;
    }
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> * poppedViewControllers = [super popToRootViewControllerAnimated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    return poppedViewControllers;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    UIViewController *topViewController = self.topViewController;
    
    // will pop
    NSMutableArray<UIViewController *> *viewControllersPopping = self.viewControllers.mutableCopy;
    [viewControllersPopping removeObjectsInArray:viewControllers];
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)obj) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    // setViewControllers 不会触发 pushViewController，所以这里也要更新一下返回按钮的文字
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull viewController, NSUInteger idx, BOOL * _Nonnull stop) {
        [self updateBackItemTitleWithCurrentViewController:viewController nextViewController:idx + 1 < viewControllers.count ? viewControllers[idx + 1] : nil];
    }];
    
    [super setViewControllers:viewControllers animated:animated];
    
    // did pop
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)obj) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    // 操作前后如果 topViewController 没发生变化，则为它调用一个特殊的时机
    if (topViewController == viewControllers.lastObject) {
        if ([topViewController respondsToSelector:@selector(viewControllerKeepingAppearWhenSetViewControllersWithAnimated:)]) {
            [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)topViewController) viewControllerKeepingAppearWhenSetViewControllersWithAnimated:animated];
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController) return;
    
    if (self.isViewControllerTransiting) {
        CIGAMLogWarn(NSStringFromClass(self.class), @"%@, 上一次界面切换的动画尚未结束就试图进行新的 push 操作，为了避免产生 bug，拦截了这次 push。\n%s, isViewControllerTransiting = %@, viewController = %@, self.viewControllers = %@", NSStringFromClass(self.class),  __func__, StringFromBOOL(self.isViewControllerTransiting), viewController, self.viewControllers);
        animated = NO;
    }
    
    if (self.isViewLoaded) {
        if (self.view.window) {
            // 增加 self.view.window 作为判断条件是因为当 UINavigationController 不可见时（例如上面盖着一个 prenset 起来的 vc，或者 nav 所在的 tabBar 切到别的 tab 去了），pushViewController 会被执行，但 navigationController:didShowViewController:animated: 的 delegate 不会被触发，导致 isViewControllerTransiting 的标志位无法正确恢复，所以做个保护。
            // https://github.com/Tencent/CIGAM_iOS/issues/261
            if (animated) {
                self.isViewControllerTransiting = YES;
            }
        } else {
            CIGAMLogWarn(NSStringFromClass(self.class), @"push 的时候 navigationController 不可见（例如上面盖着一个 prenset vc，或者切到别的 tab，可能导致一些 UINavigationControllerDelegate 不会被调用");
        }
    }
    
    // 在 push 前先设置好返回按钮的文字
    [self updateBackItemTitleWithCurrentViewController:self.topViewController nextViewController:viewController];
    
    [super pushViewController:viewController animated:animated];
    
    // 某些情况下 push 操作可能会被系统拦截，实际上该 push 并不生效，这种情况下应当恢复相关标志位，否则会影响后续的 push 操作
    // https://github.com/Tencent/CIGAM_iOS/issues/426
    if (![self.viewControllers containsObject:viewController]) {
        self.isViewControllerTransiting = NO;
    }
}

- (void)updateBackItemTitleWithCurrentViewController:(UIViewController *)currentViewController nextViewController:(UIViewController *)nextViewController {
    if (!currentViewController) return;
    
    // 如果某个 viewController 显式声明了返回按钮的文字，则无视配置表 NeedsBackBarButtonItemTitle 的值
    UIViewController<CIGAMNavigationControllerAppearanceDelegate> *vc = (UIViewController<CIGAMNavigationControllerAppearanceDelegate> *)nextViewController;
    if ([vc respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
        NSString *title = [vc backBarButtonItemTitleWithPreviousViewController:currentViewController];
        currentViewController.navigationItem.backBarButtonItem = title ? [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:NULL] : nil;
        return;
    }
    
    // 全局屏蔽返回按钮的文字
    if (CIGAMCMIActivated && !NeedsBackBarButtonItemTitle) {
#ifdef IOS14_SDK_ALLOWED
        if (@available(iOS 14.0, *)) {
            // 用新 API 来屏蔽返回按钮的文字，才能保证 iOS 14 长按返回按钮时能正确出现 viewController title
            currentViewController.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
            return;
        }
#endif
        // 业务自己设置的 backBarButtonItem 优先级高于配置表
        if (!currentViewController.navigationItem.backBarButtonItem) {
            currentViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        }
    }
}

#pragma mark - 自定义方法

- (BOOL)isViewControllerTransiting {
    // 如果配置表里这个开关关闭，则为了使 isViewControllerTransiting 功能失效，强制返回 NO
    if (!PreventConcurrentNavigationControllerTransitions) {
        return NO;
    }
    return _isViewControllerTransiting;
}

// 接管系统手势返回的回调
- (void)handleInteractivePopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    UIViewController<CIGAMNavigationControllerTransitionDelegate> *viewControllerWillDisappear = [self.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<CIGAMNavigationControllerTransitionDelegate> *viewControllerWillAppear = [self.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    viewControllerWillDisappear.cigam_poppingByInteractivePopGestureRecognizer = YES;
    viewControllerWillDisappear.cigam_willAppearByInteractivePopGestureRecognizer = NO;
    
    viewControllerWillAppear.cigam_poppingByInteractivePopGestureRecognizer = NO;
    viewControllerWillAppear.cigam_willAppearByInteractivePopGestureRecognizer = YES;
    
    if (state == UIGestureRecognizerStateBegan) {
        // UIGestureRecognizerStateBegan 对应 viewWillAppear:，只要在 viewWillAppear: 里的修改都是安全的，但只要过了 viewWillAppear:，后续的修改都是不安全的，所以这里用 dispatch 的方式将标志位的赋值放到 viewWillAppear: 的下一个 Runloop 里
        dispatch_async(dispatch_get_main_queue(), ^{
            viewControllerWillDisappear.cigam_navigationControllerPopGestureRecognizerChanging = YES;
            viewControllerWillAppear.cigam_navigationControllerPopGestureRecognizerChanging = YES;
        });
    } else if (state > UIGestureRecognizerStateChanged) {
        viewControllerWillDisappear.cigam_navigationControllerPopGestureRecognizerChanging = NO;
        viewControllerWillAppear.cigam_navigationControllerPopGestureRecognizerChanging = NO;
    }
    
    if (state == UIGestureRecognizerStateEnded) {
        if (self.transitionCoordinator.cancelled) {
            CIGAMLog(NSStringFromClass(self.class), @"手势返回放弃了");
            UIViewController<CIGAMNavigationControllerTransitionDelegate> *temp = viewControllerWillDisappear;
            viewControllerWillDisappear = viewControllerWillAppear;
            viewControllerWillAppear = temp;
        } else {
            CIGAMLog(NSStringFromClass(self.class), @"执行手势返回");
        }
    }
    
    if ([viewControllerWillDisappear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:isCancelled:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerWillDisappear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer isCancelled:self.transitionCoordinator.cancelled viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
    
    if ([viewControllerWillAppear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:isCancelled:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerWillAppear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer isCancelled:self.transitionCoordinator.cancelled viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
    
    BeginIgnoreDeprecatedWarning
    if ([viewControllerWillDisappear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerWillDisappear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
    
    if ([viewControllerWillAppear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<CIGAMNavigationControllerTransitionDelegate> *)viewControllerWillAppear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
    EndIgnoreDeprecatedWarning
}

- (void)cigam_viewControllerDidInvokeViewWillAppear:(UIViewController *)viewController {
    viewController.cigam_viewWillAppearNotifyDelegate = nil;
    [self.delegator navigationController:self willShowViewController:self.viewControllerPopping animated:YES];
    self.viewControllerPopping = nil;
    self.isViewControllerTransiting = NO;
}

#pragma mark - StatusBar

- (UIViewController *)childViewControllerIfSearching:(UIViewController *)childViewController customBlock:(BOOL (^)(UIViewController *vc))hasCustomizedStatusBarBlock {
    
    UIViewController *presentedViewController = childViewController.presentedViewController;
    
    // 3. 命中这个条件意味着 viewControllers 里某个 vc 被设置了 definesPresentationContext = YES 并 present 了一个 vc（最常见的是进入搜索状态的 UISearchController），此时对 self 而言是不存在 presentedViewController 的，所以在上面第1步里无法得到这个被 present 起来的 vc，也就无法将 statusBar 的控制权交给它，所以这里要特殊处理一下，保证状态栏正确交给 present 起来的 vc
    if (!presentedViewController.beingDismissed && presentedViewController && presentedViewController != self.presentedViewController && hasCustomizedStatusBarBlock(presentedViewController)) {
        return [self childViewControllerIfSearching:childViewController.presentedViewController customBlock:hasCustomizedStatusBarBlock];
    }
    
    // 4. 普通 dismiss，或者 iOS 13 默认的半屏 present 手势拖拽下来过程中，或者 UISearchController 退出搜索状态时，都会触发 statusBar 样式刷新，此时的 childViewController 依然是被 dismiss 的那个 vc，但状态栏应该交给背后的界面去控制，所以这里做个保护。为什么需要递归再查一次，是因为 self.topViewController 也可能正在显示一个 present 起来的搜索界面。
    if (childViewController.beingDismissed) {
        return [self childViewControllerIfSearching:self.topViewController customBlock:hasCustomizedStatusBarBlock];
    }
    
    return childViewController;
}

// 参数 hasCustomizedStatusBarBlock 用于判断指定 vc 是否有自己控制状态栏 hidden/style 的实现。
- (UIViewController *)childViewControllerForStatusBarWithCustomBlock:(BOOL (^)(UIViewController *vc))hasCustomizedStatusBarBlock {
    // 1. 有 modal present 则优先交给 modal present 的 vc 控制（例如进入搜索状态且没指定 definesPresentationContext 的 UISearchController）
    UIViewController *childViewController = self.visibleViewController;
    
    // 2. 如果 modal present 是一个 UINavigationController，则 self.visibleViewController 拿到的是该 UINavigationController.topViewController，而不是该 UINavigationController 本身，所以这里要特殊处理一下，才能让下文的 beingDismissed 判断生效
    if (childViewController.navigationController && (self.presentedViewController == childViewController.navigationController)) {
        childViewController = childViewController.navigationController;
    }
    
    childViewController = [self childViewControllerIfSearching:childViewController customBlock:hasCustomizedStatusBarBlock];
    
    if (CIGAMCMIActivated) {
        if (hasCustomizedStatusBarBlock(childViewController)) {
            return childViewController;
        }
        return nil;
    }
    return childViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return [self childViewControllerForStatusBarWithCustomBlock:^BOOL(UIViewController *vc) {
        return vc.cigam_prefersStatusBarHiddenBlock || [vc cigam_hasOverrideUIKitMethod:@selector(prefersStatusBarHidden)];
    }];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self childViewControllerForStatusBarWithCustomBlock:^BOOL(UIViewController *vc) {
        return vc.cigam_preferredStatusBarStyleBlock || [vc cigam_hasOverrideUIKitMethod:@selector(preferredStatusBarStyle)];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 按照系统的文档，当 -[UIViewController childViewControllerForStatusBarStyle] 返回值不为 nil 时，会询问返回的 vc 的 preferredStatusBarStyle，只有当返回 nil 时才会询问 self 的 preferredStatusBarStyle，但实测在 iOS 13 默认的半屏 present 或者 UISearchController 进入搜索状态时，即便在 childViewControllerForStatusBarStyle 里返回了正确的 vc，最终依然会来询问 -[self preferredStatusBarStyle]，导致样式错误，所以这里做个保护。
    UIViewController *childViewController = [self childViewControllerForStatusBarStyle];
    if (childViewController) {
        return [childViewController preferredStatusBarStyle];
    }
    
    if (CIGAMCMIActivated) {
        return StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
    return [super preferredStatusBarStyle];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return [self.visibleViewController cigam_hasOverrideUIKitMethod:_cmd] ? [self.visibleViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // fix UIAlertController:supportedInterfaceOrientations was invoked recursively!
    // crash in iOS 9 and show log in iOS 10 and later
    // https://github.com/Tencent/CIGAM_iOS/issues/502
    // https://github.com/Tencent/CIGAM_iOS/issues/632
    UIViewController *visibleViewController = self.visibleViewController;
    if (!visibleViewController || visibleViewController.isBeingDismissed || [visibleViewController isKindOfClass:UIAlertController.class]) {
        visibleViewController = self.topViewController;
    }
    return [visibleViewController cigam_hasOverrideUIKitMethod:_cmd] ? [visibleViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

#pragma mark - HomeIndicator

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.topViewController;
}

@end


@implementation CIGAMNavigationController (UISubclassingHooks)

- (void)willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 子类可以重写
}

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 子类可以重写
}

@end

@implementation _CIGAMNavigationControllerDelegator

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(CIGAMNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController willShowViewController:viewController animated:animated];
}

- (void)navigationController:(CIGAMNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    navigationController.viewControllerPopping = nil;
    [navigationController didShowViewController:viewController animated:animated];
}

@end


// 以下 Category 用于解决三种控制返回按钮的方式的优先级冲突问题
// https://github.com/Tencent/CIGAM_iOS/issues/1130

@interface UINavigationItem (CIGAMBackBarButtonItemTitle)
@property(nonatomic, strong) UIBarButtonItem *cigambbbt_backItem;
@end

@implementation UINavigationItem (CIGAMBackBarButtonItemTitle)

CIGAMSynthesizeIdStrongProperty(cigambbbt_backItem, setCigambbbt_backItem);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UINavigationItem class], @selector(setBackBarButtonItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationItem *selfObject, UIBarButtonItem *backBarButtonItem) {
                
                UINavigationBar *navigationBar = selfObject.cigam_navigationBar;
                UINavigationController *navigationController = selfObject.cigam_navigationController;
                if (navigationController) {
                    if ([navigationBar.items containsObject:selfObject]
                        && (navigationBar.topItem != selfObject || navigationController.cigam_isPushing || navigationController.cigam_isPopping)
                        && (!selfObject.cigambbbt_backItem || selfObject.cigambbbt_backItem != backBarButtonItem)) {
                        // 当前 vc 存在子界面，此时要修改 backBarButtonItem，根据优先级，应该先判断子界面是否使用了 backBarButtonItemTitleWithPreviousViewController:
                        UIViewController *currentViewController = nil;
                        UIViewController *nextViewController = nil;
                        NSInteger indexForChildViewController = [navigationBar.items indexOfObject:selfObject] + 1;
                        if (indexForChildViewController < navigationController.viewControllers.count) {
                            nextViewController = navigationController.viewControllers[indexForChildViewController];
                            currentViewController = navigationController.viewControllers[indexForChildViewController - 1];
                        } else if (navigationController.cigam_isPopping) {
                            // 当 UINavigationController 正在 pop 时，navigationBar.items 里仍包含即将被 pop 的界面，但 navigationController.viewControllers 里已经是 pop 结束后的界面了，所以需要从 transitionCoordinator 里获取即将被 pop 的界面
                            nextViewController = [navigationController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
                            currentViewController = [navigationController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
                        }
                        if ([nextViewController respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
                            NSAssert(!!currentViewController, @"currentViewController 和 nextViewController 必须同时存在");
                            selfObject.cigambbbt_backItem = backBarButtonItem;
                            return;
                        } else if (!nextViewController) {
                            CIGAMLogWarn(@"UINavigationItem (CIGAMBackBarButtonItemTitle)", @"当前界面理应存在子界面，但获取不到，cigam_isPopping = %@, navigationBar.items = %@", StringFromBOOL(navigationController.cigam_isPopping), navigationBar.items);
                        }
                    }
                }
                
                if (selfObject.cigambbbt_backItem) {
                    selfObject.cigambbbt_backItem = nil;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIBarButtonItem *);
                originSelectorIMP = (void (*)(id, SEL, UIBarButtonItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, backBarButtonItem);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // 恢复被屏蔽的那一次 setBackBarButtonItem
                if (selfObject.navigationItem.cigambbbt_backItem) {
                    selfObject.navigationItem.backBarButtonItem = selfObject.navigationItem.cigambbbt_backItem;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

@end

@implementation CIGAMNavigationTitleView (CIGAMNavigationController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 在先设置了 title 再设置 titleView 时，保证 titleView 的样式能正确。
        OverrideImplementation([UINavigationItem class], @selector(setTitleView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationItem *selfObject, CIGAMNavigationTitleView *titleView) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, titleView);
                
                if ([titleView isKindOfClass:CIGAMNavigationTitleView.class]) {
                    if ([selfObject.cigam_viewController respondsToSelector:@selector(titleViewTintColor)]) {
                        titleView.tintColor = ((id<CIGAMNavigationControllerDelegate>)selfObject.cigam_viewController).titleViewTintColor;
                    }
                }
            };
        });
    });
}

@end