/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMConfiguration.m
//  cigam
//
//  Created by CIGAM Team on 15/3/29.
//

#import "CIGAMConfiguration.h"
#import "CIGAMCore.h"
#import "UIImage+CIGAM.h"
#import "NSString+CIGAM.h"
#import "UIViewController+CIGAM.h"
#import "CIGAMKit.h"

#import "CIGAMConfigurationTemplate.h"

// 在 iOS 8 - 11 上实际测量得到
// Measured on iOS 8 - 11
const CGSize kCIGAMUINavigationBarBackIndicatorImageSize = {13, 21};

@interface CIGAMConfiguration ()

@property(nonatomic, strong) UITabBarAppearance *tabBarAppearance API_AVAILABLE(ios(13.0));
@end

@implementation UIViewController (CIGAMConfiguration)

- (NSArray <UIViewController *>*)cigam_existingViewControllersOfClasses:(NSArray<Class<UIAppearanceContainer>> *)classes {
    NSMutableSet *viewControllers = [NSMutableSet set];
    if (self.presentedViewController) {
        [viewControllers addObjectsFromArray:[self.presentedViewController cigam_existingViewControllersOfClasses:classes]];
    }
    if ([self isKindOfClass:UINavigationController.class]) {
        [viewControllers addObjectsFromArray:[((UINavigationController *)self).visibleViewController cigam_existingViewControllersOfClasses:classes]];
    }
    if ([self isKindOfClass:UITabBarController.class]) {
        [viewControllers addObjectsFromArray:[((UITabBarController *)self).selectedViewController cigam_existingViewControllersOfClasses:classes]];
    }
    for (Class class in classes) {
        if ([self isKindOfClass:class]) {
            [viewControllers addObject:self];
            break;
        }
    }
    return viewControllers.allObjects;
}

@end

@implementation CIGAMConfiguration

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static CIGAMConfiguration *sharedInstance;
    dispatch_once(&pred, ^{
        sharedInstance = [[CIGAMConfiguration alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDefaultConfiguration];
    }
    return self;
}

static BOOL CIGAM_hasAppliedInitialTemplate;
- (void)applyInitialTemplate {
    if (CIGAM_hasAppliedInitialTemplate) {
        return;
    }

    CIGAM_hasAppliedInitialTemplate = YES;
    _active = YES;
    [[[CIGAMConfigurationTemplate alloc] init] applyConfigurationTemplate];
}

#pragma mark - Initialize default values

- (void)initDefaultConfiguration {
    
#pragma mark - Global Color
    
    self.clearColor = UIColorMakeWithRGBA(255, 255, 255, 0);
    self.whiteColor = UIColorMake(255, 255, 255);
    self.blackColor = UIColorMake(0, 0, 0);
    self.grayColor = UIColorMake(179, 179, 179);
    self.grayDarkenColor = UIColorMake(163, 163, 163);
    self.grayLightenColor = UIColorMake(198, 198, 198);
    self.redColor = UIColorMake(250, 58, 58);
    self.greenColor = UIColorMake(159, 214, 97);
    self.blueColor = UIColorMake(49, 189, 243);
    self.yellowColor = UIColorMake(255, 207, 71);

    self.linkColor = UIColorMake(56, 116, 171);
    self.disabledColor = self.grayColor;
    self.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);
    self.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);
    self.separatorColor = UIColorMake(222, 224, 226);
    self.separatorDashedColor = UIColorMake(17, 17, 17);
    self.placeholderColor = UIColorMake(196, 200, 208);
    
    self.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    self.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    self.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
#pragma mark - UIControl
    
    self.controlHighlightedAlpha = 0.5f;
    self.controlDisabledAlpha = 0.5f;
    
#pragma mark - UIButton
    
    self.buttonHighlightedAlpha = self.controlHighlightedAlpha;
    self.buttonDisabledAlpha = self.controlDisabledAlpha;
    self.buttonTintColor = self.blueColor;
    
    self.ghostButtonColorBlue = self.blueColor;
    self.ghostButtonColorRed = self.redColor;
    self.ghostButtonColorGreen = self.greenColor;
    self.ghostButtonColorGray = self.grayColor;
    self.ghostButtonColorWhite = self.whiteColor;
    
    self.fillButtonColorBlue = self.blueColor;
    self.fillButtonColorRed = self.redColor;
    self.fillButtonColorGreen = self.greenColor;
    self.fillButtonColorGray = self.grayColor;
    self.fillButtonColorWhite = self.whiteColor;
    
#pragma mark - UITextField & UITextView
    
    self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    
#pragma mark - NavigationBar

    self.navBarHighlightedAlpha = 0.2f;
    self.navBarDisabledAlpha = 0.2f;
    self.sizeNavBarBackIndicatorImageAutomatically = YES;
    self.navBarCloseButtonImage = [UIImage cigam_imageWithShape:CIGAMImageShapeNavClose size:CGSizeMake(16, 16) tintColor:self.navBarTintColor];

    self.navBarLoadingMarginRight = 3;
    self.navBarAccessoryViewMarginLeft = 5;
    self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage cigam_imageWithShape:CIGAMImageShapeTriangle size:CGSizeMake(8, 5) tintColor:self.navBarTitleColor] cigam_imageWithOrientation:UIImageOrientationDown];
    
#pragma mark - Toolbar
    
    self.toolBarHighlightedAlpha = 0.4f;
    self.toolBarDisabledAlpha = 0.4f;
    
#pragma mark - SearchBar
    
    self.searchBarPlaceholderColor = self.placeholderColor;
    self.searchBarTextFieldCornerRadius = 2.0;
    
#pragma mark - TableView / TableViewCell
    
    self.tableViewEstimatedHeightEnabled = YES;
    
    self.tableViewSeparatorColor = self.separatorColor;

    self.tableViewCellNormalHeight = UITableViewAutomaticDimension;
    self.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);
    self.tableViewCellWarningBackgroundColor = self.yellowColor;
    self.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12;
    
    self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionHeaderFont = UIFontBoldMake(12);
    self.tableViewSectionFooterFont = UIFontBoldMake(12);
    self.tableViewSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewSectionFooterTextColor = self.grayColor;
    self.tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    
    self.tableViewGroupedSeparatorColor = self.tableViewSeparatorColor;
    self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
    self.tableViewGroupedSectionFooterFont = UIFontMake(12);
    self.tableViewGroupedSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewGroupedSectionFooterTextColor = self.grayColor;
    self.tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension;
    self.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension;
    self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
    self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
    
    self.tableViewInsetGroupedCornerRadius = 10;
    self.tableViewInsetGroupedHorizontalInset = PreferredValueForVisualDevice(20, 15);
    self.tableViewInsetGroupedSeparatorColor = self.tableViewSeparatorColor;
    self.tableViewInsetGroupedSectionHeaderFont = self.tableViewGroupedSectionHeaderFont;
    self.tableViewInsetGroupedSectionFooterFont = self.tableViewGroupedSectionFooterFont;
    self.tableViewInsetGroupedSectionHeaderTextColor = self.tableViewSectionHeaderTextColor;
    self.tableViewInsetGroupedSectionFooterTextColor = self.tableViewGroupedSectionFooterTextColor;
    self.tableViewInsetGroupedSectionHeaderAccessoryMargins = self.tableViewGroupedSectionHeaderAccessoryMargins;
    self.tableViewInsetGroupedSectionFooterAccessoryMargins = self.tableViewGroupedSectionFooterAccessoryMargins;
    self.tableViewInsetGroupedSectionHeaderDefaultHeight = self.tableViewGroupedSectionHeaderDefaultHeight;
    self.tableViewInsetGroupedSectionFooterDefaultHeight = self.tableViewGroupedSectionFooterDefaultHeight;
    self.tableViewInsetGroupedSectionHeaderContentInset = self.tableViewGroupedSectionHeaderContentInset;
    self.tableViewInsetGroupedSectionFooterContentInset = self.tableViewGroupedSectionFooterContentInset;
    
#pragma mark - UIWindowLevel
    self.windowLevelCIGAMAlertView = UIWindowLevelAlert - 4.0;
    self.windowLevelCIGAMConsole = 1;
    
#pragma mark - CIGAMLog
    self.shouldPrintDefaultLog = YES;
    self.shouldPrintInfoLog = YES;
    self.shouldPrintWarnLog = YES;
    self.shouldPrintCIGAMWarnLogToConsole = IS_DEBUG;
    
#pragma mark - CIGAMBadge
    self.badgeOffset = CIGAMBadgeInvalidateOffset;
    self.badgeOffsetLandscape = CIGAMBadgeInvalidateOffset;
    self.updatesIndicatorOffset = CIGAMBadgeInvalidateOffset;
    self.updatesIndicatorOffsetLandscape = CIGAMBadgeInvalidateOffset;
    
#pragma mark - Others
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    self.needsBackBarButtonItemTitle = YES;
    self.preventConcurrentNavigationControllerTransitions = YES;
    self.shouldFixTabBarSafeAreaInsetsBug = YES;
    self.sendAnalyticsToCIGAMTeam = YES;
}

#pragma mark - Switch Setter

- (void)setSwitchOnTintColor:(UIColor *)switchOnTintColor {
    _switchOnTintColor = switchOnTintColor;
    [UISwitch appearance].onTintColor = switchOnTintColor;
}

- (void)setSwitchThumbTintColor:(UIColor *)switchThumbTintColor {
    _switchThumbTintColor = switchThumbTintColor;
    [UISwitch appearance].thumbTintColor = switchThumbTintColor;
}

#pragma mark - NavigationBar Setter

- (void)setNavBarButtonFont:(UIFont *)navBarButtonFont {
    _navBarButtonFont = navBarButtonFont;
    // by molice 2017-08-04 只要用 appearence 的方式修改 UIBarButtonItem 的 font，就会导致界面切换时 UIBarButtonItem 抖动，系统的问题，所以暂时不修改 appearance。
    // by molice 2018-06-14 iOS 11 观察貌似又没抖动了，先试试看
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]];
    NSDictionary<NSAttributedStringKey,id> *attributes = navBarButtonFont ? @{NSFontAttributeName: navBarButtonFont} : nil;
    [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateDisabled];
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor {
    _navBarTintColor = navBarTintColor;
    // tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(navigationBarTintColor)]) {
            navigationController.navigationBar.tintColor = _navBarTintColor;
        }
    }];
}

- (void)setNavBarBarTintColor:(UIColor *)navBarBarTintColor {
    _navBarBarTintColor = navBarBarTintColor;
    UINavigationBar.cigam_appearanceConfigured.barTintColor = _navBarBarTintColor;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(navigationBarBarTintColor)]) {
            navigationController.navigationBar.barTintColor = _navBarBarTintColor;
        }
    }];
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage {
    _navBarShadowImage = navBarShadowImage;
    [self configureNavBarShadowImage];
}

- (void)setNavBarShadowImageColor:(UIColor *)navBarShadowImageColor {
    _navBarShadowImageColor = navBarShadowImageColor;
    [self configureNavBarShadowImage];
}

- (void)configureNavBarShadowImage {
    UIImage *shadowImage = self.navBarShadowImage;
    if (shadowImage || self.navBarShadowImageColor) {
        if (shadowImage) {
            if (self.navBarShadowImageColor && shadowImage.renderingMode != UIImageRenderingModeAlwaysOriginal) {
                shadowImage = [shadowImage cigam_imageWithTintColor:self.navBarShadowImageColor];
            }
        } else {
            shadowImage = [UIImage cigam_imageWithColor:self.navBarShadowImageColor size:CGSizeMake(4, PixelOne) cornerRadius:0];
        }
        
        // 反向更新 NavBarShadowImage，以保证业务代码直接使用 NavBarShadowImage 宏能得到正确的图片
        _navBarShadowImage = shadowImage;
    }
    
    UINavigationBar.cigam_appearanceConfigured.shadowImage = shadowImage;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(navigationBarShadowImage)]) {
            navigationController.navigationBar.shadowImage = shadowImage;
        }
    }];
}

- (void)setNavBarStyle:(UIBarStyle)navBarStyle {
    _navBarStyle = navBarStyle;
    UINavigationBar.cigam_appearanceConfigured.barStyle = navBarStyle;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(navigationBarStyle)]) {
            navigationController.navigationBar.barStyle = navBarStyle;
        }
    }];
}

- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage {
    _navBarBackgroundImage = navBarBackgroundImage;
    [UINavigationBar.cigam_appearanceConfigured setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(navigationBarBackgroundImage)]) {
            [navigationController.navigationBar setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        }
    }];
}

- (void)setNavBarTitleFont:(UIFont *)navBarTitleFont {
    _navBarTitleFont = navBarTitleFont;
    [self updateNavigationBarTitleAttributesIfNeeded];
}

- (void)setNavBarTitleColor:(UIColor *)navBarTitleColor {
    _navBarTitleColor = navBarTitleColor;
    [self updateNavigationBarTitleAttributesIfNeeded];
}

- (void)updateNavigationBarTitleAttributesIfNeeded {
    NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = UINavigationBar.cigam_appearanceConfigured.titleTextAttributes.mutableCopy;
    if (!titleTextAttributes) {
        titleTextAttributes = [[NSMutableDictionary alloc] init];
    }
    if (self.navBarTitleFont) {
        titleTextAttributes[NSFontAttributeName] = self.navBarTitleFont;
    }
    if (self.navBarTitleColor) {
        titleTextAttributes[NSForegroundColorAttributeName] = self.navBarTitleColor;
    }
    UINavigationBar.cigam_appearanceConfigured.titleTextAttributes = titleTextAttributes;
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(titleViewTintColor)]) {
            navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
        }
    }];
}

- (void)setNavBarLargeTitleFont:(UIFont *)navBarLargeTitleFont {
    _navBarLargeTitleFont = navBarLargeTitleFont;
    [self updateNavigationBarLargeTitleTextAttributesIfNeeded];
}

- (void)setNavBarLargeTitleColor:(UIColor *)navBarLargeTitleColor {
    _navBarLargeTitleColor = navBarLargeTitleColor;
    [self updateNavigationBarLargeTitleTextAttributesIfNeeded];
}

- (void)updateNavigationBarLargeTitleTextAttributesIfNeeded {
    if (@available(iOS 11, *)) {
        NSMutableDictionary<NSString *, id> *largeTitleTextAttributes = [[NSMutableDictionary alloc] init];
        if (self.navBarLargeTitleFont) {
            largeTitleTextAttributes[NSFontAttributeName] = self.navBarLargeTitleFont;
        }
        if (self.navBarLargeTitleColor) {
            largeTitleTextAttributes[NSForegroundColorAttributeName] = self.navBarLargeTitleColor;
        }
        UINavigationBar.cigam_appearanceConfigured.largeTitleTextAttributes = largeTitleTextAttributes;
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            navigationController.navigationBar.largeTitleTextAttributes = largeTitleTextAttributes;
        }];
    }
}

- (void)setSizeNavBarBackIndicatorImageAutomatically:(BOOL)sizeNavBarBackIndicatorImageAutomatically {
    _sizeNavBarBackIndicatorImageAutomatically = sizeNavBarBackIndicatorImageAutomatically;
    if (sizeNavBarBackIndicatorImageAutomatically && self.navBarBackIndicatorImage && !CGSizeEqualToSize(self.navBarBackIndicatorImage.size, kCIGAMUINavigationBarBackIndicatorImageSize)) {
        self.navBarBackIndicatorImage = self.navBarBackIndicatorImage;// 重新设置一次，以触发自动调整大小
    }
}

- (void)setNavBarBackIndicatorImage:(UIImage *)navBarBackIndicatorImage {
    _navBarBackIndicatorImage = navBarBackIndicatorImage;
    
    // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
    // Make sure custom back button image is the same size as the system's back button image, i.e. (13, 21), due to the same frame size they share.
    if (navBarBackIndicatorImage && self.sizeNavBarBackIndicatorImageAutomatically) {
        CGSize systemBackIndicatorImageSize = kCIGAMUINavigationBarBackIndicatorImageSize;
        CGSize customBackIndicatorImageSize = _navBarBackIndicatorImage.size;
        if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
            CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
            _navBarBackIndicatorImage = [[_navBarBackIndicatorImage cigam_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                                                                                                           0,
                                                                                                                           imageExtensionVerticalFloat,
                                                                                                                           systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width)] imageWithRenderingMode:_navBarBackIndicatorImage.renderingMode];
        }
    }
    
    UINavigationBar *navBarAppearance = UINavigationBar.cigam_appearanceConfigured;
    navBarAppearance.backIndicatorImage = _navBarBackIndicatorImage;
    navBarAppearance.backIndicatorTransitionMaskImage = _navBarBackIndicatorImage;
    
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.navigationBar.backIndicatorImage = _navBarBackIndicatorImage;
        navigationController.navigationBar.backIndicatorTransitionMaskImage = _navBarBackIndicatorImage;
    }];

}

- (void)setNavBarBackButtonTitlePositionAdjustment:(UIOffset)navBarBackButtonTitlePositionAdjustment {
    _navBarBackButtonTitlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
    
    UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
    [backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    }];
}

#pragma mark - ToolBar Setter

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    // tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.tintColor = _toolBarTintColor;
    }];
}

- (void)setToolBarStyle:(UIBarStyle)toolBarStyle {
    _toolBarStyle = toolBarStyle;
    UIToolbar.cigam_appearanceConfigured.barStyle = toolBarStyle;
    [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.barStyle = toolBarStyle;
    }];
}

- (void)setToolBarBarTintColor:(UIColor *)toolBarBarTintColor {
    _toolBarBarTintColor = toolBarBarTintColor;
    UIToolbar.cigam_appearanceConfigured.barTintColor = _toolBarBarTintColor;
    [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.barTintColor = _toolBarBarTintColor;
    }];
}

- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage {
    _toolBarBackgroundImage = toolBarBackgroundImage;
    [UIToolbar.cigam_appearanceConfigured setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.toolbar setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }];
}

- (void)setToolBarShadowImageColor:(UIColor *)toolBarShadowImageColor {
    _toolBarShadowImageColor = toolBarShadowImageColor;
    UIImage *shadowImage = toolBarShadowImageColor ? [UIImage cigam_imageWithColor:_toolBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0] : nil;
    [UIToolbar.cigam_appearanceConfigured setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        [navigationController.toolbar setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    }];
}

#pragma mark - TabBar Setter

- (UITabBarAppearance *)tabBarAppearance {
    if (!_tabBarAppearance) {
        _tabBarAppearance = [[UITabBarAppearance alloc] init];
        [_tabBarAppearance configureWithDefaultBackground];
    }
    return _tabBarAppearance;
}

- (void)updateTabBarAppearance {
    if (@available(iOS 13.0, *)) {
        UITabBar.cigam_appearanceConfigured.standardAppearance = self.tabBarAppearance;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.standardAppearance = self.tabBarAppearance;
        }];
    }
}

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor {
    _tabBarBarTintColor = tabBarBarTintColor;
    
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.backgroundColor = tabBarBarTintColor;
        [self updateTabBarAppearance];
    } else {
        UITabBar.cigam_appearanceConfigured.barTintColor = _tabBarBarTintColor;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.barTintColor = _tabBarBarTintColor;
        }];
    }
}

- (void)setTabBarStyle:(UIBarStyle)tabBarStyle {
    _tabBarStyle = tabBarStyle;
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:tabBarStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
        [self updateTabBarAppearance];
    } else {
        UITabBar.cigam_appearanceConfigured.barStyle = tabBarStyle;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.barStyle = tabBarStyle;
        }];
    }
}

- (void)setTabBarBackgroundImage:(UIImage *)tabBarBackgroundImage {
    _tabBarBackgroundImage = tabBarBackgroundImage;
    
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.backgroundImage = tabBarBackgroundImage;
        [self updateTabBarAppearance];
    } else {
        UITabBar.cigam_appearanceConfigured.backgroundImage = tabBarBackgroundImage;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.backgroundImage = tabBarBackgroundImage;
        }];
    }
}

- (void)setTabBarShadowImageColor:(UIColor *)tabBarShadowImageColor {
    _tabBarShadowImageColor = tabBarShadowImageColor;
    
    if (@available(iOS 13.0, *)) {
        self.tabBarAppearance.shadowColor = tabBarShadowImageColor;
        [self updateTabBarAppearance];
    } else {
        UIImage *shadowImage = [UIImage cigam_imageWithColor:_tabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0];
        [UITabBar.cigam_appearanceConfigured setShadowImage:shadowImage];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.shadowImage = shadowImage;
        }];
    }
}

- (void)setTabBarItemTitleFont:(UIFont *)tabBarItemTitleFont {
    _tabBarItemTitleFont = tabBarItemTitleFont;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance cigam_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
            attributes[NSFontAttributeName] = tabBarItemTitleFont;
            itemAppearance.normal.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.cigam_appearanceConfigured titleTextAttributesForState:UIControlStateNormal]];
        if (_tabBarItemTitleFont) {
            textAttributes[NSFontAttributeName] = _tabBarItemTitleFont;
        }
        [UITabBarItem.cigam_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            }];
        }];
    }
}

- (void)setTabBarItemTitleFontSelected:(UIFont *)tabBarItemTitleFontSelected {
    _tabBarItemTitleFontSelected = tabBarItemTitleFontSelected;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance cigam_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
            attributes[NSFontAttributeName] = tabBarItemTitleFontSelected;
            itemAppearance.selected.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.cigam_appearanceConfigured titleTextAttributesForState:UIControlStateSelected]];
        if (tabBarItemTitleFontSelected) {
            textAttributes[NSFontAttributeName] = tabBarItemTitleFontSelected;
        }
        [UITabBarItem.cigam_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
            }];
        }];
    }
}

- (void)setTabBarItemTitleColor:(UIColor *)tabBarItemTitleColor {
    _tabBarItemTitleColor = tabBarItemTitleColor;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance cigam_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = tabBarItemTitleColor;
            itemAppearance.normal.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.cigam_appearanceConfigured titleTextAttributesForState:UIControlStateNormal]];
        textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColor;
        [UITabBarItem.cigam_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            }];
        }];
    }
}

- (void)setTabBarItemTitleColorSelected:(UIColor *)tabBarItemTitleColorSelected {
    _tabBarItemTitleColorSelected = tabBarItemTitleColorSelected;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance cigam_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = tabBarItemTitleColorSelected;
            itemAppearance.selected.titleTextAttributes = attributes.copy;
        }];
        [self updateTabBarAppearance];
    } else {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.cigam_appearanceConfigured titleTextAttributesForState:UIControlStateSelected]];
        textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColorSelected;
        [UITabBarItem.cigam_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
            }];
        }];
    }
}

- (void)setTabBarItemImageColor:(UIColor *)tabBarItemImageColor {
    _tabBarItemImageColor = tabBarItemImageColor;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance cigam_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            itemAppearance.normal.iconColor = tabBarItemImageColor;
        }];
        [self updateTabBarAppearance];
    } else {
        UITabBar.cigam_appearanceConfigured.unselectedItemTintColor = tabBarItemImageColor;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.unselectedItemTintColor = tabBarItemImageColor;
        }];
    }
}

- (void)setTabBarItemImageColorSelected:(UIColor *)tabBarItemImageColorSelected {
    _tabBarItemImageColorSelected = tabBarItemImageColorSelected;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBarAppearance cigam_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            itemAppearance.selected.iconColor = tabBarItemImageColorSelected;
        }];
        [self updateTabBarAppearance];
    } else {
        // iOS 12 及以下使用 tintColor 实现，但 tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
        //        UITabBar.cigam_appearanceConfigured.tintColor = tabBarItemImageColorSelected;
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.tintColor = tabBarItemImageColorSelected;
        }];
    }
}

- (void)setStatusbarStyleLightInitially:(BOOL)statusbarStyleLightInitially {
    _statusbarStyleLightInitially = statusbarStyleLightInitially;
    [[CIGAMHelper visibleViewController] setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Appearance Updating Views

// 解决某些场景下更新配置表无法覆盖样式的问题 https://github.com/Tencent/CIGAM_iOS/issues/700

- (NSArray <UITabBarController *>*)appearanceUpdatingTabBarControllers {
    NSArray<Class<UIAppearanceContainer>> *classes = nil;
    if (self.tabBarContainerClasses.count > 0) {
        classes = self.tabBarContainerClasses;
    } else {
        classes = @[UITabBarController.class];
    }
    // tabBarContainerClasses 里可能会设置非 UITabBarController 的 class，由于这里只需要关注 UITabBarController 的，所以做一次过滤
    classes = [classes cigam_filterWithBlock:^BOOL(Class<UIAppearanceContainer>  _Nonnull item) {
        return [item.class isSubclassOfClass:UITabBarController.class];
    }];
    return (NSArray <UITabBarController *>*)[self appearanceUpdatingViewControllersOfClasses:classes];
}

- (NSArray <UINavigationController *>*)appearanceUpdatingNavigationControllers {
    NSArray<Class<UIAppearanceContainer>> *classes = nil;
    if (self.navBarContainerClasses.count > 0) {
        classes = self.navBarContainerClasses;
    } else {
        classes = @[UINavigationController.class];
    }
    // navBarContainerClasses 里可能会设置非 UINavigationController 的 class，由于这里只需要关注 UINavigationController 的，所以做一次过滤
    classes = [classes cigam_filterWithBlock:^BOOL(Class<UIAppearanceContainer>  _Nonnull item) {
        return [item.class isSubclassOfClass:UINavigationController.class];
    }];
    return (NSArray <UINavigationController *>*)[self appearanceUpdatingViewControllersOfClasses:classes];
}

- (NSArray <UINavigationController *>*)appearanceUpdatingToolbarControllers {
    NSArray<Class<UIAppearanceContainer>> *classes = nil;
    if (self.toolBarContainerClasses.count > 0) {
        classes = self.toolBarContainerClasses;
    } else {
        classes = @[UINavigationController.class];
    }
    // toolBarContainerClasses 里可能会设置非 UINavigationController 的 class，由于这里只需要关注 UINavigationController 的，所以做一次过滤
    classes = [classes cigam_filterWithBlock:^BOOL(Class<UIAppearanceContainer>  _Nonnull item) {
        return [item.class isSubclassOfClass:UINavigationController.class];
    }];
    return (NSArray <UINavigationController *>*)[self appearanceUpdatingViewControllersOfClasses:classes];
}

- (NSArray <UIViewController *>*)appearanceUpdatingViewControllersOfClasses:(NSArray<Class<UIAppearanceContainer>> *)classes {
    if (!classes.count) return nil;
    NSMutableArray *viewControllers = [NSMutableArray array];
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (window.rootViewController) {
            [viewControllers addObjectsFromArray:[window.rootViewController cigam_existingViewControllersOfClasses:classes]];
        }
    }];
    return viewControllers;
}

@end

@implementation UINavigationBar (CIGAMConfiguration)

+ (instancetype)cigam_appearanceConfigured {
    if (CIGAMCMIActivated && NavBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:NavBarContainerClasses];
    }
    return [self appearance];
}

@end

@implementation UITabBar (CIGAMConfiguration)

+ (instancetype)cigam_appearanceConfigured {
    if (CIGAMCMIActivated && TabBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:TabBarContainerClasses];
    }
    return [self appearance];
}

@end

@implementation UIToolbar (CIGAMConfiguration)

+ (instancetype)cigam_appearanceConfigured {
    if (CIGAMCMIActivated && ToolBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:ToolBarContainerClasses];
    }
    return [self appearance];
}

@end

@implementation UITabBarItem (CIGAMConfiguration)

+ (instancetype)cigam_appearanceConfigured {
    if (CIGAMCMIActivated && TabBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:TabBarContainerClasses];
    }
    return [self appearance];
}

@end
