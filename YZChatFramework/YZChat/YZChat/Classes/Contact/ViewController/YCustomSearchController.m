//
//  YUICustomSearchController.m
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YCustomSearchController.h"
#import <QMUIKit/QMUIKit.h>

@interface YCustomSearchController ()
@property(nonatomic, strong) UIView *customDimmingView;

@end

@implementation YCustomSearchController

- (void)setCustomDimmingView:(UIView *)customDimmingView {
    if (_customDimmingView != customDimmingView) {
        [_customDimmingView removeFromSuperview];
    }
    _customDimmingView = customDimmingView;
    
    self.dimsBackgroundDuringPresentation = !_customDimmingView;
    if ([self isViewLoaded]) {
        [self addCustomDimmingView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addCustomDimmingView];
}

- (void)addCustomDimmingView {
    UIView *superviewOfDimmingView = self.searchResultsController.view.superview;
    if (self.customDimmingView && self.customDimmingView.superview != superviewOfDimmingView) {
        [superviewOfDimmingView insertSubview:self.customDimmingView atIndex:0];
        [self layoutCustomDimmingView];
    }
}

- (void)layoutCustomDimmingView {
    UIView *searchBarContainerView = nil;
    for (UIView *subview in self.view.subviews) {
        if ([NSStringFromClass(subview.class) isEqualToString:@"UISearchBarContainerView"]) {
            searchBarContainerView = subview;
            break;
        }
    }
    self.customDimmingView.frame = CGRectInsetEdges(self.customDimmingView.superview.bounds, UIEdgeInsetsMake(searchBarContainerView ? CGRectGetMaxY(searchBarContainerView.frame) : 0, 0, 0, 0));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.customDimmingView) {
        [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
            [self layoutCustomDimmingView];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
