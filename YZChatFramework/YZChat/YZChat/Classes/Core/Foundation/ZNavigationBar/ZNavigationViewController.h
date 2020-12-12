//
//  CustomNavigationViewController.h
//  YChat
//
//  Created by magic on 2020/9/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZNavigationTransitionAnimation) {
    
    /**
     *  水平动画
     */
    ZNavigationTransitionAnimationHorizontal = 0,
    
    /**
     *  垂直动画
     */
    ZNavigationTransitionAnimationVertical,
    
    /**
     *  淡入淡出
     */
    ZNavigationTransitionAnimationFade,
    
    /**
     *  无
     */
    ZNavigationTransitionAnimationNone,
};

@interface ZNavigationViewController : UINavigationController

/**
 *  push 到新的 ViewController
 *
 *  @param viewController 需要 push 的 ViewController
 */
- (void)pushViewController:(UIViewController *)viewController;

/**
 *  push 到新的 ViewController
 *
 *  @param viewController 需要 push 的 ViewController
 *  @param animation      动画类型
 */
- (void)pushViewController:(UIViewController *)viewController withAnimation:(ZNavigationTransitionAnimation)animation;

/**
 *  push 到新的 ViewController
 *
 *  @param viewController 需要 push 的 ViewController
 *  @param completion      动画完成后执行的 block
 */
- (void)pushViewController:(UIViewController *)viewController completion:(void (^)(void))completion;


/**
 *  push 到新的 ViewController
 *
 *  @param viewController 需要 push 的 ViewController
 *  @param animation      动画类型
 *  @param completion      动画完成后执行的 block
 */
- (void)pushViewController:(UIViewController *)viewController withAnimation:(ZNavigationTransitionAnimation)animation completion:(void (^)(void))completion;



/**
 *  弹出当前最上层的 viewcontroller，无动画
 */
- (UIViewController *)popViewController;

/**
 *  弹出当前最上层的 viewcontroller
 *
 *  @param animation 动画类型 */
- (UIViewController *)popViewControllerWithAnimation:(ZNavigationTransitionAnimation)animation;

/**
 *  弹出当前最上层的 viewcontroller
 *
 *  @param animation 动画类型
 *  @param completion 动画完成后执行的操作
 */
- (UIViewController *)popViewControllerWithAnimation:(ZNavigationTransitionAnimation)animation completion:(void (^)(void))completion;

/**
 *  弹出到指定的 viewcontroller
 *
 *  @param viewController viewController
 *  @param animated       是否需要动画
 *  @param completion      动画完成后执行
 */
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 *  弹出到根 viewcontroller
 *
 *  @param animated  是否需要动画
 *  @param completion 动画完成后执行
 */
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;


/**
 *  移除指定的 viewcontroller
 *
 *  @param viewController 要移除的 viewcontroller
 */
- (void)removeViewController:(UIViewController *)viewController;

/**
 *  移除指定的 viewcontrollers
 *
 *  @param viewControllers 要移除的 viewcontroller 数组
 */
- (void)removeViewControllers:(NSArray *)viewControllers;

- (UIViewController *)previousViewController;

- (void)replaceViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;

+ (ZNavigationViewController *)currentNavigationViewController;

@end
