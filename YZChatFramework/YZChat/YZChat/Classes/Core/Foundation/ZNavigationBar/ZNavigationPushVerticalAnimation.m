//
//  ZNavigationPushVerticalAnimation.m
//  YChat
//
//  Created by magic on 2020/9/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ZNavigationPushVerticalAnimation.h"

@implementation ZNavigationPushVerticalAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.55;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    ZMapViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    [[transitionContext containerView] addSubview:toVC.view];
//    toVC.view.transform = CGAffineTransformMakeTranslation(0, toVC.view.bounds.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
//        toVC.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
