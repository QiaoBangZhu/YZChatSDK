//
//  CustomNavigationViewController.m
//  YChat
//
//  Created by magic on 2020/9/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ZNavigationViewController.h"
#import "CommonConstant.h"
#import "ZNavigationPopVerticalAnimation.h"
#import "ZNavigationPushVerticalAnimation.h"
#import "ZNavigationPopFadeAnimation.h"
#import "ZNavigationPushFadeAnimation.h"

@interface ZNavigationViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL shouldIgnorePush;

@end

@implementation ZNavigationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setup {
    self.delegate = self;
    self.interactivePopGestureRecognizer.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setShouldIgnorePush:(BOOL)shouldIgnorePush
{
    _shouldIgnorePush = shouldIgnorePush;
    if (IOS8_OR_LATER) {
        _shouldIgnorePush = NO;
    }
}

//- (void)pushViewController:(UIViewController *)viewController {
//
//    [self pushViewController:viewController withAnimation:(ZNavigationTransitionAnimation)viewController.animation];
//}
//
//- (void)pushViewController:(UIViewController *)viewController withAnimation:(ZNavigationTransitionAnimation)animation {
//    [self pushViewController:viewController withAnimation:animation completion:nil];
//}
//
//- (void)pushViewController:(UIViewController *)viewController completion:(void (^)(void))completion {
//    [self pushViewController:viewController withAnimation:(ZNavigationTransitionAnimation)viewController.animation completion:completion];
//}
//
//- (void)pushViewController:(UIViewController *)viewController withAnimation:(ZNavigationTransitionAnimation)animation completion:(void (^)(void))completion {
//    viewController.animation = (ZNavigationTransitionAnimation)animation;
//    viewController.completionBlock = completion;
//
//    switch (animation) {
//        case ZNavigationTransitionAnimationHorizontal:
//        {
//            [self pushViewController:viewController animated:YES];
//        }
//            break;
//        case ZNavigationTransitionAnimationVertical:
//        {
//            viewController.disableInteractivePopGestureRecognizer = YES;
//            [self pushViewController:viewController animated:YES];
//        }
//            break;
//        case ZNavigationTransitionAnimationFade:
//        {
//            viewController.disableInteractivePopGestureRecognizer = YES;
//            [self pushViewController:viewController animated:YES];
//        }
//            break;
//        case ZNavigationTransitionAnimationNone:
//        default:
//            [self pushViewController:viewController animated:NO];
//            break;
//    }
//}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //iOS 7 连续 Push 多个 VC 会 Crash
    if (self.shouldIgnorePush) {
        return;
    }
    
    if (animated) {
        self.shouldIgnorePush = YES;
    }
    
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - pop about

- (UIViewController *)popViewController {
    return [self popViewControllerWithAnimation:ZNavigationTransitionAnimationNone];
}

- (UIViewController *)popViewControllerWithAnimation:(ZNavigationTransitionAnimation)animation {
    return [self popViewControllerWithAnimation:animation completion:nil];
}

//- (UIViewController *)popViewControllerWithAnimation:(ZNavigationTransitionAnimation)animation completion:(void (^)(void))completion {
//    if (self.viewControllers.count >= 2) {
//
//        UIViewController *toViewController = self.viewControllers[self.viewControllers.count - 2];
//        UIViewController *fromViewController = self.viewControllers.lastObject;
//
//        fromViewController.animation = (ZNavigationTransitionAnimation)animation;
//        toViewController.completionBlock = completion;
//
//        switch (animation) {
//            case ZNavigationTransitionAnimationHorizontal:
//            case ZNavigationTransitionAnimationVertical:
//            case ZNavigationTransitionAnimationFade:
//                return [self popViewControllerAnimated:YES];
//                break;
//            case ZNavigationTransitionAnimationNone:
//            default:
//                return [self popViewControllerAnimated:NO];
//                break;
//        }
//
//    }
//    else {
//        if (completion) {
//            completion();
//        }
//        return self.viewControllers.lastObject;
//    }
//}

//- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
//{
//    viewController.completionBlock = completion;
//    return [self popToViewController:viewController animated:animated];
//}
//
//- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
//{
//    self.rootViewController.completionBlock = completion;
//    return [self popToRootViewControllerAnimated:animated];
//}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (self.shouldIgnorePush) {
        return nil;
    }
    
    if (animated) {
        self.shouldIgnorePush = YES;
    }
    
    return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.shouldIgnorePush) {
        return nil;
    }
    
    if (animated) {
        self.shouldIgnorePush = YES;
    }
    
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (self.shouldIgnorePush) {
        return nil;
    }
    
    if (animated) {
        self.shouldIgnorePush = YES;
    }
    return [super popToRootViewControllerAnimated:animated];
}


#pragma mark - remove about

- (void)replaceViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    if (viewControllers.count > index)
    {
        [viewControllers replaceObjectAtIndex:index withObject:viewController];
    }
    [self setViewControllers:viewControllers animated:NO];
}

- (void)removeViewController:(UIViewController *)viewController {
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeObject:viewController];
    [self setViewControllers:viewControllers animated:NO];
}

- (void)removeViewControllers:(NSArray *)viewControllers {
    NSMutableArray *newViewControllers = [self.viewControllers mutableCopy];
    [newViewControllers removeObjectsInArray:viewControllers];
    [self setViewControllers:newViewControllers animated:NO];
}

#pragma mark - UINavigationControllerDelegate
//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
//{
//    //    if ([toVC isKindOfClass:[ZMapViewController class]] || [fromVC isKindOfClass:[ZMapViewController class]])
//    //    {
//    //        if (operation == UINavigationControllerOperationPush) {
//    //            return [ZNavigationPushMapAnimation new];
//    //        }
//    //        else if (operation == UINavigationControllerOperationPop)
//    //        {
//    //            return nil;
//    //        }
//    //    }
//    //    else
//    //    {
//    //
//    //    }
//
//    if (operation == UINavigationControllerOperationPush) {
//        if (toVC.animation == ZNavigationTransitionAnimationVertical) {
//            return [ZNavigationPushVerticalAnimation new];
//        }
//        else if (toVC.animation == ZNavigationTransitionAnimationFade) {
//            return [ZNavigationPushFadeAnimation new];
//        }
//    }
//    else if (operation == UINavigationControllerOperationPop) {
//        if (fromVC.animation == ZNavigationTransitionAnimationVertical) {
//            return [ZNavigationPopVerticalAnimation new];
//        }
//        else if (fromVC.animation == ZNavigationTransitionAnimationFade) {
//            return [ZNavigationPopFadeAnimation new];
//        }
//    }
//    return nil;
//}
//
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    self.shouldIgnorePush = NO;
//
//    if (viewController.completionBlock) {
//        viewController.completionBlock();
//        viewController.completionBlock = nil;
//    }
//}
//
//
//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
//{
//    if (self.shouldIgnorePush) {
//        return NO;
//    }
//
//    // 如果只有一个 VC，就不要启用滑动手势了
//    if (self.viewControllers.count <= 1) {
//        return NO;
//    }
//
//    if ([self.topViewController isKindOfClass:[BaseViewController class]])
//    {
//        BaseViewController *vc = (BaseViewController *)self.topViewController;
//        if (vc.disableInteractivePopGestureRecognizer) {
//            return NO;
//        }
//    }
//
//    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
//        return NO;
//    }
//
//    return YES;
//}

- (UIViewController *)rootViewController {
    return self.viewControllers.firstObject;
}

- (UIViewController *)previousViewController
{
    if (self.childViewControllers.count > 2)
    {
        return self.childViewControllers[self.childViewControllers.count - 2];
    }
    else
    {
        return nil;
    }
}

+ (ZNavigationViewController *)currentNavigationViewController
{
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[ZNavigationViewController class]])
    {
        ZNavigationViewController *rootVC = (ZNavigationViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC.visibleViewController.navigationController isKindOfClass:[ZNavigationViewController class]])
        {
            return (ZNavigationViewController *)rootVC.visibleViewController.navigationController;
        }
    }
    return nil;
}
@end
