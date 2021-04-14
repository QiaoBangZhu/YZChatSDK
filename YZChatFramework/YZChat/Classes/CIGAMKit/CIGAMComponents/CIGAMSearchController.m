/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMSearchController.m
//  Test
//
//  Created by CIGAM Team on 16/5/25.
//

#import "CIGAMSearchController.h"
#import "CIGAMCore.h"
#import "CIGAMSearchBar.h"
#import "CIGAMCommonTableViewController.h"
#import "CIGAMEmptyView.h"
#import "UISearchBar+CIGAM.h"
#import "UITableView+CIGAM.h"
#import "NSString+CIGAM.h"
#import "NSObject+CIGAM.h"
#import "UIView+CIGAM.h"
#import "UIViewController+CIGAM.h"

BeginIgnoreDeprecatedWarning

@class CIGAMSearchResultsTableViewController;

@protocol CIGAMSearchResultsTableViewControllerDelegate <NSObject>

- (void)didLoadTableViewInSearchResultsTableViewController:(CIGAMSearchResultsTableViewController *)viewController;
@end

@interface CIGAMSearchResultsTableViewController : CIGAMCommonTableViewController

@property(nonatomic,weak) id<CIGAMSearchResultsTableViewControllerDelegate> delegate;
@end

@implementation CIGAMSearchResultsTableViewController

- (void)initTableView {
    [super initTableView];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if ([self.delegate respondsToSelector:@selector(didLoadTableViewInSearchResultsTableViewController:)]) {
        [self.delegate didLoadTableViewInSearchResultsTableViewController:self];
    }
}

@end

@interface CIGAMCustomSearchController : UISearchController

@property(nonatomic, strong) UIView *customDimmingView;
@end

@implementation CIGAMCustomSearchController

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
        if ([NSStringFromClass(subview.class) isEqualToString:@"_UISearchBarContainerView"]) {
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

@end

@interface CIGAMSearchController () <CIGAMSearchResultsTableViewControllerDelegate>

@property(nonatomic,strong) CIGAMCustomSearchController *searchController;
@end

@implementation CIGAMSearchController

- (instancetype)initWithContentsViewController:(UIViewController *)viewController {
    if (self = [self initWithNibName:nil bundle:nil]) {
        // 将 definesPresentationContext 置为 YES 有两个作用：
        // 1、保证从搜索结果界面进入子界面后，顶部的searchBar不会依然停留在navigationBar上
        // 2、使搜索结果界面的tableView的contentInset.top正确适配searchBar
        viewController.definesPresentationContext = YES;
        
        CIGAMSearchResultsTableViewController *searchResultsViewController = [[CIGAMSearchResultsTableViewController alloc] init];
        searchResultsViewController.delegate = self;
        self.searchController = [[CIGAMCustomSearchController alloc] initWithSearchResultsController:searchResultsViewController];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        _searchBar = self.searchController.searchBar;
        if (CGRectIsEmpty(self.searchBar.frame)) {
            // iOS8 下 searchBar.frame 默认是 CGRectZero，不 sizeToFit 就看不到了
            [self.searchBar sizeToFit];
        }
        [self.searchBar cigam_styledAsCIGAMSearchBar];
        
        self.hidesNavigationBarDuringPresentation = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 主动触发 loadView，如果不这么做，那么有可能直到 CIGAMSearchController 被销毁，这期间 self.searchController 都没有被触发 loadView，然后在 dealloc 时就会报错，提示尝试在释放 self.searchController 时触发了 self.searchController 的 loadView
    [self.searchController loadViewIfNeeded];
}

- (void)setSearchResultsDelegate:(id<CIGAMSearchControllerDelegate>)searchResultsDelegate {
    _searchResultsDelegate = searchResultsDelegate;
    self.tableView.dataSource = _searchResultsDelegate;
    self.tableView.delegate = _searchResultsDelegate;
}

- (BOOL)isActive {
    return self.searchController.active;
}

- (void)setActive:(BOOL)active {
    [self setActive:active animated:NO];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated {
    self.searchController.active = active;
}

- (UITableView *)tableView {
    return ((CIGAMCommonTableViewController *)self.searchController.searchResultsController).tableView;
}

- (void)setLaunchView:(UIView *)dimmingView {
    _launchView = dimmingView;
    self.searchController.customDimmingView = _launchView;
}

- (BOOL)hidesNavigationBarDuringPresentation {
    return self.searchController.hidesNavigationBarDuringPresentation;
}

- (void)setHidesNavigationBarDuringPresentation:(BOOL)hidesNavigationBarDuringPresentation {
    self.searchController.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation;
}

- (void)setCigam_prefersStatusBarHiddenBlock:(BOOL (^)(void))cigam_prefersStatusBarHiddenBlock {
    [super setCigam_prefersStatusBarHiddenBlock:cigam_prefersStatusBarHiddenBlock];
    self.searchController.cigam_prefersStatusBarHiddenBlock = cigam_prefersStatusBarHiddenBlock;
}

- (void)setCigam_preferredStatusBarStyleBlock:(UIStatusBarStyle (^)(void))cigam_preferredStatusBarStyleBlock {
    [super setCigam_preferredStatusBarStyleBlock:cigam_preferredStatusBarStyleBlock];
    self.searchController.cigam_preferredStatusBarStyleBlock = cigam_preferredStatusBarStyleBlock;
}

#pragma mark - CIGAMEmptyView

- (void)showEmptyView {
    // 搜索框文字为空时，界面会显示遮罩，此时不需要显示emptyView了
    // 为什么加这个是因为当搜索框被点击时（进入搜索状态）会触发searchController:updateResultsForSearchString:，里面如果直接根据搜索结果为空来showEmptyView的话，就会导致在遮罩层上有emptyView出现，要么在那边showEmptyView之前判断一下searchBar.text.length，要么在showEmptyView里判断，为了方便，这里选择后者。
    if (self.searchBar.text.length <= 0) {
        return;
    }
    
    [super showEmptyView];
    
    // 格式化样式，以适应当前项目的需求
    self.emptyView.backgroundColor = TableViewBackgroundColor ?: UIColorWhite;
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:willShowEmptyView:)]) {
        [self.searchResultsDelegate searchController:self willShowEmptyView:self.emptyView];
    }
    
    if (self.searchController) {
        UIView *superview = self.searchController.searchResultsController.view;
        [superview addSubview:self.emptyView];
    } else {
        NSAssert(NO, @"CIGAMSearchController无法为emptyView找到合适的superview");
    }
    
    [self layoutEmptyView];
}

#pragma mark - <CIGAMSearchResultsTableViewControllerDelegate>

- (void)didLoadTableViewInSearchResultsTableViewController:(CIGAMSearchResultsTableViewController *)viewController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:didLoadSearchResultsTableView:)]) {
        [self.searchResultsDelegate searchController:self didLoadSearchResultsTableView:viewController.tableView];
    }
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:updateResultsForSearchString:)]) {
        [self.searchResultsDelegate searchController:self updateResultsForSearchString:searchController.searchBar.text];
    }
}

#pragma mark - <UISearchControllerDelegate>

- (void)willPresentSearchController:(UISearchController *)searchController {
    if (self.searchController.cigam_prefersStatusBarHiddenBlock || self.searchController.cigam_preferredStatusBarStyleBlock) {
        [self.searchController setNeedsStatusBarAppearanceUpdate];
    }
    if ([self.searchResultsDelegate respondsToSelector:@selector(willPresentSearchController:)]) {
        [self.searchResultsDelegate willPresentSearchController:self];
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(didPresentSearchController:)]) {
        [self.searchResultsDelegate didPresentSearchController:self];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if (self.searchController.cigam_prefersStatusBarHiddenBlock || self.searchController.cigam_preferredStatusBarStyleBlock) {
        [self.searchController setNeedsStatusBarAppearanceUpdate];
    }
    if ([self.searchResultsDelegate respondsToSelector:@selector(willDismissSearchController:)]) {
        [self.searchResultsDelegate willDismissSearchController:self];
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // 退出搜索必定先隐藏emptyView
    [self hideEmptyView];
    
    if ([self.searchResultsDelegate respondsToSelector:@selector(didDismissSearchController:)]) {
        [self.searchResultsDelegate didDismissSearchController:self];
    }
}

@end

EndIgnoreDeprecatedWarning

@implementation CIGAMCommonTableViewController (Search)

CIGAMSynthesizeIdStrongProperty(searchController, setSearchController)
CIGAMSynthesizeIdStrongProperty(searchBar, setSearchBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithoutArguments([CIGAMCommonTableViewController class], @selector(initSubviews), ^(CIGAMCommonTableViewController *selfObject) {
            [selfObject initSearchController];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([CIGAMCommonTableViewController class], @selector(viewWillAppear:), BOOL, ^(CIGAMCommonTableViewController *selfObject, BOOL firstArgv) {
            if (!selfObject.searchController.tableView.allowsMultipleSelection) {
                [selfObject.searchController.tableView cigam_clearsSelection];
            }
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([CIGAMCommonTableViewController class], @selector(showEmptyView), ^(CIGAMCommonTableViewController *selfObject) {
            if ([selfObject shouldHideSearchBarWhenEmptyViewShowing] && selfObject.tableView.tableHeaderView == selfObject.searchBar) {
                selfObject.tableView.tableHeaderView = nil;
            }
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([CIGAMCommonTableViewController class], @selector(hideEmptyView), ^(CIGAMCommonTableViewController *selfObject) {
            if (selfObject.shouldShowSearchBar && [selfObject shouldHideSearchBarWhenEmptyViewShowing] && selfObject.tableView.tableHeaderView == nil) {
                [selfObject initSearchController];
                // 隐藏 emptyView 后重新设置 tableHeaderView，会导致原先 shouldHideTableHeaderViewInitial 隐藏头部的操作被重置，所以下面的 force 参数要传 YES
                // https://github.com/Tencent/CIGAM_iOS/issues/128
                selfObject.tableView.tableHeaderView = selfObject.searchBar;
                [selfObject hideTableHeaderViewInitialIfCanWithAnimated:NO force:YES];
            }
        });
    });
}

static char kAssociatedObjectKey_shouldShowSearchBar;
- (void)setShouldShowSearchBar:(BOOL)shouldShowSearchBar {
    BOOL isValueChanged = self.shouldShowSearchBar != shouldShowSearchBar;
    if (!isValueChanged) {
        return;
    }
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowSearchBar, @(shouldShowSearchBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (shouldShowSearchBar) {
        [self initSearchController];
    } else {
        if (self.searchBar) {
            if (self.tableView.tableHeaderView == self.searchBar) {
                self.tableView.tableHeaderView = nil;
            }
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
        }
        if (self.searchController) {
            self.searchController.searchResultsDelegate = nil;
            self.searchController = nil;
        }
    }
}

- (BOOL)shouldShowSearchBar {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowSearchBar)) boolValue];
}

- (void)initSearchController {
    if ([self isViewLoaded] && self.shouldShowSearchBar && !self.searchController) {
        self.searchController = [[CIGAMSearchController alloc] initWithContentsViewController:self];
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchBar.placeholder = @"搜索";
        self.searchController.searchBar.cigam_usedAsTableHeaderView = YES;// 以 tableHeaderView 的方式使用 searchBar 的话，将其置为 YES，以辅助兼容一些系统 bug
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchBar = self.searchController.searchBar;
    }
}

- (BOOL)shouldHideSearchBarWhenEmptyViewShowing {
    return NO;
}

#pragma mark - <CIGAMSearchControllerDelegate>

- (void)searchController:(CIGAMSearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    
}

@end
