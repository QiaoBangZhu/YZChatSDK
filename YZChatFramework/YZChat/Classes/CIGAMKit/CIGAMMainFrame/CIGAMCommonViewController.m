/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMCommonViewController.m
//  cigam
//
//  Created by CIGAM Team on 14-6-22.
//

#import "CIGAMCommonViewController.h"
#import "CIGAMCore.h"
#import "CIGAMNavigationTitleView.h"
#import "CIGAMEmptyView.h"
#import "NSString+CIGAM.h"
#import "NSObject+CIGAM.h"
#import "UIViewController+CIGAM.h"
#import "UIGestureRecognizer+CIGAM.h"
#import "UIView+CIGAM.h"

@interface CIGAMViewControllerHideKeyboardDelegateObject : NSObject <UIGestureRecognizerDelegate, CIGAMKeyboardManagerDelegate>

@property(nonatomic, weak) CIGAMCommonViewController *viewController;

- (instancetype)initWithViewController:(CIGAMCommonViewController *)viewController;
@end

@interface CIGAMCommonViewController () {
    UITapGestureRecognizer *_hideKeyboardTapGestureRecognizer;
    CIGAMKeyboardManager *_hideKeyboardManager;
    CIGAMViewControllerHideKeyboardDelegateObject *_hideKeyboadDelegateObject;
}

@property(nonatomic,strong,readwrite) CIGAMNavigationTitleView *titleView;
@end

@implementation CIGAMCommonViewController

#pragma mark - 生命周期

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.titleView = [[CIGAMNavigationTitleView alloc] init];
    self.titleView.title = self.title;// 从 storyboard 初始化的话，可能带有 self.title 的值
    self.navigationItem.titleView = self.titleView;
    
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.supportedOrientationMask = SupportedOrientationMask;
    
    if (CIGAMCMIActivated) {
        self.hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially;
        self.cigam_preferredStatusBarStyleBlock = ^UIStatusBarStyle{
            return StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
        };
    }
    
    if (@available(iOS 11.0, *)) {
        self.cigam_prefersHomeIndicatorAutoHiddenBlock = ^BOOL{
            return NO;
        };
    }

    
    // 动态字体notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.view.backgroundColor && CIGAMCMIActivated) {// nib 里可能设置了，所以做个 if 的判断
        self.view.backgroundColor = UIColorForBackground;
    }
    
    // 点击空白区域降下键盘 CIGAMCommonViewController (CIGAMKeyboard)
    // 如果子类重写了才初始化这些对象（即便子类 return NO）
    BOOL shouldEnabledKeyboardObject = [self cigam_hasOverrideMethod:@selector(shouldHideKeyboardWhenTouchInView:) ofSuperclass:[CIGAMCommonViewController class]];
    if (shouldEnabledKeyboardObject) {
        _hideKeyboadDelegateObject = [[CIGAMViewControllerHideKeyboardDelegateObject alloc] initWithViewController:self];
        
        _hideKeyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
        self.hideKeyboardTapGestureRecognizer.delegate = _hideKeyboadDelegateObject;
        self.hideKeyboardTapGestureRecognizer.enabled = NO;
        [self.view addGestureRecognizer:self.hideKeyboardTapGestureRecognizer];
        
        _hideKeyboardManager = [[CIGAMKeyboardManager alloc] initWithDelegate:_hideKeyboadDelegateObject];
    }
    
    [self initSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // fix iOS 11 and later, shouldHideKeyboardWhenTouchInView: will not work when calling becomeFirstResponder in UINavigationController.rootViewController.viewDidLoad
    // https://github.com/Tencent/CIGAM_iOS/issues/495
    if (@available(iOS 11.0, *)) {
        if (self.hideKeyboardManager && [CIGAMKeyboardManager isKeyboardVisible]) {
            self.hideKeyboardTapGestureRecognizer.enabled = YES;
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationItems];
    [self setupToolbarItems];
}

#pragma mark - 空列表视图 CIGAMEmptyView

@synthesize emptyView = _emptyView;

- (CIGAMEmptyView *)emptyView {
    if (!_emptyView && self.isViewLoaded) {
        _emptyView = [[CIGAMEmptyView alloc] initWithFrame:self.view.bounds];
    }
    return _emptyView;
}

- (void)showEmptyView {
    [self.view addSubview:self.emptyView];
}

- (void)hideEmptyView {
    [_emptyView removeFromSuperview];
}

- (BOOL)isEmptyViewShowing {
    return _emptyView && _emptyView.superview;
}

- (void)showEmptyViewWithLoading {
    [self showEmptyView];
    [self.emptyView setImage:nil];
    [self.emptyView setLoadingViewHidden:NO];
    [self.emptyView setTextLabelText:nil];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
}

- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:nil text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:image text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action {
    [self showEmptyView];
    [self.emptyView setLoadingViewHidden:!showLoading];
    [self.emptyView setImage:image];
    [self.emptyView setTextLabelText:text];
    [self.emptyView setDetailTextLabelText:detailText];
    [self.emptyView setActionButtonTitle:buttonTitle];
    [self.emptyView.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.emptyView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)layoutEmptyView {
    if (_emptyView) {
        // 由于为self.emptyView设置frame时会调用到self.view，为了避免导致viewDidLoad提前触发，这里需要判断一下self.view是否已经被初始化
        BOOL viewDidLoad = self.emptyView.superview && [self isViewLoaded];
        if (viewDidLoad) {
            CGSize newEmptyViewSize = self.emptyView.superview.bounds.size;
            CGSize oldEmptyViewSize = self.emptyView.frame.size;
            if (!CGSizeEqualToSize(newEmptyViewSize, oldEmptyViewSize)) {
                self.emptyView.cigam_frameApplyTransform = CGRectFlatMake(CGRectGetMinX(self.emptyView.frame), CGRectGetMinY(self.emptyView.frame), newEmptyViewSize.width, newEmptyViewSize.height);
            }
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientationMask;
}

@end

@implementation CIGAMCommonViewController (CIGAMSubclassingHooks)

- (void)initSubviews {
    // 子类重写
}

- (void)setupNavigationItems {
    // 子类重写
}

- (void)setupToolbarItems {
    // 子类重写
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    // 子类重写
}

@end

@implementation CIGAMCommonViewController (CIGAMNavigationController)

- (void)updateNavigationBarAppearance {
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if (!navigationBar) return;
    
    if ([self respondsToSelector:@selector(navigationBarBackgroundImage)]) {
        [navigationBar setBackgroundImage:[self navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    }
    if ([self respondsToSelector:@selector(navigationBarBarTintColor)]) {
        navigationBar.barTintColor = [self navigationBarBarTintColor];
    }
    if ([self respondsToSelector:@selector(navigationBarStyle)]) {
        navigationBar.barStyle = [self navigationBarStyle];
    }
    if ([self respondsToSelector:@selector(navigationBarShadowImage)]) {
        navigationBar.shadowImage = [self navigationBarShadowImage];
    }
    if ([self respondsToSelector:@selector(navigationBarTintColor)]) {
        navigationBar.tintColor = [self navigationBarTintColor];
    }
    if ([self respondsToSelector:@selector(titleViewTintColor)]) {
        self.titleView.tintColor = [self titleViewTintColor];
    }
}

#pragma mark - <CIGAMNavigationControllerDelegate>

- (BOOL)preferredNavigationBarHidden {
    return NavigationBarHiddenInitially;
}

- (void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated {
    // 通常和 viewWillAppear: 里做的事情保持一致
    [self setupNavigationItems];
    [self setupToolbarItems];
}

@end

@implementation CIGAMCommonViewController (CIGAMKeyboard)

- (UITapGestureRecognizer *)hideKeyboardTapGestureRecognizer {
    return _hideKeyboardTapGestureRecognizer;
}

- (CIGAMKeyboardManager *)hideKeyboardManager {
    return _hideKeyboardManager;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    // 子类重写，默认返回 NO，也即不主动干预键盘的状态
    return NO;
}

@end

@implementation CIGAMViewControllerHideKeyboardDelegateObject

- (instancetype)initWithViewController:(CIGAMCommonViewController *)viewController {
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.viewController.hideKeyboardTapGestureRecognizer) {
        return YES;
    }
    
    if (![CIGAMKeyboardManager isKeyboardVisible]) {
        return NO;
    }
    
    UIView *targetView = gestureRecognizer.cigam_targetView;
    
    // 点击了本身就是输入框的 view，就不要降下键盘了
    if ([targetView isKindOfClass:[UITextField class]] || [targetView isKindOfClass:[UITextView class]]) {
        return NO;
    }
    
    if ([self.viewController shouldHideKeyboardWhenTouchInView:targetView]) {
        [self.viewController.view endEditing:YES];
    }
    return NO;
}

#pragma mark - <CIGAMKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(CIGAMKeyboardUserInfo *)keyboardUserInfo {
    if (![self.viewController cigam_isViewLoadedAndVisible]) return;
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = YES;
}

- (void)keyboardWillHideWithUserInfo:(CIGAMKeyboardUserInfo *)keyboardUserInfo {
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = NO;
}

@end
