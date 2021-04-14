/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMConfigurationMacros.h
//  cigam
//
//  Created by CIGAM Team on 14-7-2.
//

#import "CIGAMConfiguration.h"


/**
 *  提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 *  @warning 请不要在 + load 方法里调用 CIGAMConfigurationTemplate 或 CIGAMConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 *  @waining 维护时，如果需要增加一个宏，则需要定义一个新的 CIGAMConfiguration 属性。
 */


// 单例的宏

#define CIGAMCMI ({[[CIGAMConfiguration sharedInstance] applyInitialTemplate];[CIGAMConfiguration sharedInstance];})

/// 标志当前项目是否正使用配置表功能
#define CIGAMCMIActivated            [CIGAMCMI active]

#pragma mark - Global Color

// 基础颜色
#define UIColorClear                [CIGAMCMI clearColor]
#define UIColorWhite                [CIGAMCMI whiteColor]
#define UIColorBlack                [CIGAMCMI blackColor]
#define UIColorGray                 [CIGAMCMI grayColor]
#define UIColorGrayDarken           [CIGAMCMI grayDarkenColor]
#define UIColorGrayLighten          [CIGAMCMI grayLightenColor]
#define UIColorRed                  [CIGAMCMI redColor]
#define UIColorGreen                [CIGAMCMI greenColor]
#define UIColorBlue                 [CIGAMCMI blueColor]
#define UIColorYellow               [CIGAMCMI yellowColor]

// 功能颜色
#define UIColorLink                 [CIGAMCMI linkColor]                       // 全局统一文字链接颜色
#define UIColorDisabled             [CIGAMCMI disabledColor]                   // 全局统一文字disabled颜色
#define UIColorForBackground        [CIGAMCMI backgroundColor]                 // 全局统一的背景色
#define UIColorMask                 [CIGAMCMI maskDarkColor]                   // 全局统一的mask背景色
#define UIColorMaskWhite            [CIGAMCMI maskLightColor]                  // 全局统一的mask背景色，白色
#define UIColorSeparator            [CIGAMCMI separatorColor]                  // 全局分隔线颜色
#define UIColorSeparatorDashed      [CIGAMCMI separatorDashedColor]            // 全局分隔线颜色（虚线）
#define UIColorPlaceholder          [CIGAMCMI placeholderColor]                // 全局的输入框的placeholder颜色

// 测试用的颜色
#define UIColorTestRed              [CIGAMCMI testColorRed]
#define UIColorTestGreen            [CIGAMCMI testColorGreen]
#define UIColorTestBlue             [CIGAMCMI testColorBlue]

// 可操作的控件
#pragma mark - UIControl

#define UIControlHighlightedAlpha       [CIGAMCMI controlHighlightedAlpha]          // 一般control的Highlighted透明值
#define UIControlDisabledAlpha          [CIGAMCMI controlDisabledAlpha]             // 一般control的Disable透明值

// 按钮
#pragma mark - UIButton
#define ButtonHighlightedAlpha          [CIGAMCMI buttonHighlightedAlpha]           // 按钮Highlighted状态的透明度
#define ButtonDisabledAlpha             [CIGAMCMI buttonDisabledAlpha]              // 按钮Disabled状态的透明度
#define ButtonTintColor                 [CIGAMCMI buttonTintColor]                  // 普通按钮的颜色

#define GhostButtonColorBlue            [CIGAMCMI ghostButtonColorBlue]              // CIGAMGhostButtonColorBlue的颜色
#define GhostButtonColorRed             [CIGAMCMI ghostButtonColorRed]               // CIGAMGhostButtonColorRed的颜色
#define GhostButtonColorGreen           [CIGAMCMI ghostButtonColorGreen]             // CIGAMGhostButtonColorGreen的颜色
#define GhostButtonColorGray            [CIGAMCMI ghostButtonColorGray]              // CIGAMGhostButtonColorGray的颜色
#define GhostButtonColorWhite           [CIGAMCMI ghostButtonColorWhite]             // CIGAMGhostButtonColorWhite的颜色

#define FillButtonColorBlue             [CIGAMCMI fillButtonColorBlue]              // CIGAMFillButtonColorBlue的颜色
#define FillButtonColorRed              [CIGAMCMI fillButtonColorRed]               // CIGAMFillButtonColorRed的颜色
#define FillButtonColorGreen            [CIGAMCMI fillButtonColorGreen]             // CIGAMFillButtonColorGreen的颜色
#define FillButtonColorGray             [CIGAMCMI fillButtonColorGray]              // CIGAMFillButtonColorGray的颜色
#define FillButtonColorWhite            [CIGAMCMI fillButtonColorWhite]             // CIGAMFillButtonColorWhite的颜色

#pragma mark - TextInput
#define TextFieldTextColor              [CIGAMCMI textFieldTextColor]               // CIGAMTextField、CIGAMTextView 的文字颜色
#define TextFieldTintColor              [CIGAMCMI textFieldTintColor]               // CIGAMTextField、CIGAMTextView 的tintColor
#define TextFieldTextInsets             [CIGAMCMI textFieldTextInsets]              // CIGAMTextField 的内边距
#define KeyboardAppearance              [CIGAMCMI keyboardAppearance]

#pragma mark - UISwitch
#define SwitchOnTintColor               [CIGAMCMI switchOnTintColor]                 // UISwitch 打开时的背景色（除了圆点外的其他颜色）
#define SwitchOffTintColor              [CIGAMCMI switchOffTintColor]                // UISwitch 关闭时的背景色（除了圆点外的其他颜色）
#define SwitchTintColor                 [CIGAMCMI switchTintColor]                   // UISwitch 关闭时的周围边框颜色
#define SwitchThumbTintColor            [CIGAMCMI switchThumbTintColor]              // UISwitch 中间的操控圆点的颜色

#pragma mark - NavigationBar

#define NavBarContainerClasses                          [CIGAMCMI navBarContainerClasses]
#define NavBarHighlightedAlpha                          [CIGAMCMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [CIGAMCMI navBarDisabledAlpha]
#define NavBarButtonFont                                [CIGAMCMI navBarButtonFont]
#define NavBarButtonFontBold                            [CIGAMCMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [CIGAMCMI navBarBackgroundImage]
#define NavBarShadowImage                               [CIGAMCMI navBarShadowImage]
#define NavBarShadowImageColor                          [CIGAMCMI navBarShadowImageColor]
#define NavBarBarTintColor                              [CIGAMCMI navBarBarTintColor]
#define NavBarStyle                                     [CIGAMCMI navBarStyle]
#define NavBarTintColor                                 [CIGAMCMI navBarTintColor]
#define NavBarTitleColor                                [CIGAMCMI navBarTitleColor]
#define NavBarTitleFont                                 [CIGAMCMI navBarTitleFont]
#define NavBarLargeTitleColor                           [CIGAMCMI navBarLargeTitleColor]
#define NavBarLargeTitleFont                            [CIGAMCMI navBarLargeTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [CIGAMCMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [CIGAMCMI navBarBackIndicatorImage]
#define SizeNavBarBackIndicatorImageAutomatically       [CIGAMCMI sizeNavBarBackIndicatorImageAutomatically]
#define NavBarCloseButtonImage                          [CIGAMCMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [CIGAMCMI navBarLoadingMarginRight]                          // titleView里左边的loading的右边距
#define NavBarAccessoryViewMarginLeft                   [CIGAMCMI navBarAccessoryViewMarginLeft]                     // titleView里的accessoryView的左边距
#define NavBarActivityIndicatorViewStyle                [CIGAMCMI navBarActivityIndicatorViewStyle]                  // titleView loading 的style
#define NavBarAccessoryViewTypeDisclosureIndicatorImage [CIGAMCMI navBarAccessoryViewTypeDisclosureIndicatorImage]   // titleView上倒三角的默认图片


#pragma mark - TabBar

#define TabBarContainerClasses                          [CIGAMCMI tabBarContainerClasses]
#define TabBarBackgroundImage                           [CIGAMCMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [CIGAMCMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [CIGAMCMI tabBarShadowImageColor]
#define TabBarStyle                                     [CIGAMCMI tabBarStyle]
#define TabBarItemTitleFont                             [CIGAMCMI tabBarItemTitleFont]
#define TabBarItemTitleFontSelected                     [CIGAMCMI tabBarItemTitleFontSelected]
#define TabBarItemTitleColor                            [CIGAMCMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [CIGAMCMI tabBarItemTitleColorSelected]
#define TabBarItemImageColor                            [CIGAMCMI tabBarItemImageColor]
#define TabBarItemImageColorSelected                    [CIGAMCMI tabBarItemImageColorSelected]

#pragma mark - Toolbar

#define ToolBarContainerClasses                         [CIGAMCMI toolBarContainerClasses]
#define ToolBarHighlightedAlpha                         [CIGAMCMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [CIGAMCMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [CIGAMCMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [CIGAMCMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [CIGAMCMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [CIGAMCMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [CIGAMCMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [CIGAMCMI toolBarShadowImageColor]
#define ToolBarStyle                                    [CIGAMCMI toolBarStyle]
#define ToolBarButtonFont                               [CIGAMCMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBorderColor                   [CIGAMCMI searchBarTextFieldBorderColor]
#define SearchBarTextFieldBackgroundImage               [CIGAMCMI searchBarTextFieldBackgroundImage]
#define SearchBarBackgroundImage                        [CIGAMCMI searchBarBackgroundImage]
#define SearchBarTintColor                              [CIGAMCMI searchBarTintColor]
#define SearchBarTextColor                              [CIGAMCMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [CIGAMCMI searchBarPlaceholderColor]
#define SearchBarFont                                   [CIGAMCMI searchBarFont]
#define SearchBarSearchIconImage                        [CIGAMCMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [CIGAMCMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [CIGAMCMI searchBarTextFieldCornerRadius]


#pragma mark - TableView / TableViewCell

#define TableViewEstimatedHeightEnabled                 [CIGAMCMI tableViewEstimatedHeightEnabled]            // 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

#define TableViewBackgroundColor                        [CIGAMCMI tableViewBackgroundColor]                   // 普通列表的背景色
#define TableSectionIndexColor                          [CIGAMCMI tableSectionIndexColor]                     // 列表右边索引条的文字颜色
#define TableSectionIndexBackgroundColor                [CIGAMCMI tableSectionIndexBackgroundColor]           // 列表右边索引条的背景色
#define TableSectionIndexTrackingBackgroundColor        [CIGAMCMI tableSectionIndexTrackingBackgroundColor]   // 列表右边索引条按下时的背景色
#define TableViewSeparatorColor                         [CIGAMCMI tableViewSeparatorColor]                    // 列表分隔线颜色

#define TableViewCellNormalHeight                       [CIGAMCMI tableViewCellNormalHeight]                  // CIGAMTableView 的默认 cell 高度
#define TableViewCellTitleLabelColor                    [CIGAMCMI tableViewCellTitleLabelColor]               // cell的title颜色
#define TableViewCellDetailLabelColor                   [CIGAMCMI tableViewCellDetailLabelColor]              // cell的detailTitle颜色
#define TableViewCellBackgroundColor                    [CIGAMCMI tableViewCellBackgroundColor]               // 列表 cell 的背景色
#define TableViewCellSelectedBackgroundColor            [CIGAMCMI tableViewCellSelectedBackgroundColor]       // 列表 cell 按下时的背景色
#define TableViewCellWarningBackgroundColor             [CIGAMCMI tableViewCellWarningBackgroundColor]        // 列表 cell 在提醒状态下的背景色

#define TableViewCellDisclosureIndicatorImage           [CIGAMCMI tableViewCellDisclosureIndicatorImage]      // 列表 cell 右边的箭头图片
#define TableViewCellCheckmarkImage                     [CIGAMCMI tableViewCellCheckmarkImage]                // 列表 cell 右边的打钩checkmark
#define TableViewCellDetailButtonImage                  [CIGAMCMI tableViewCellDetailButtonImage]             // 列表 cell 右边的 i 按钮
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [CIGAMCMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]   // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

#define TableViewSectionHeaderBackgroundColor           [CIGAMCMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor           [CIGAMCMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                      [CIGAMCMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                      [CIGAMCMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor                 [CIGAMCMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor                 [CIGAMCMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderAccessoryMargins          [CIGAMCMI tableViewSectionHeaderAccessoryMargins]
#define TableViewSectionFooterAccessoryMargins          [CIGAMCMI tableViewSectionFooterAccessoryMargins]
#define TableViewSectionHeaderContentInset              [CIGAMCMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset              [CIGAMCMI tableViewSectionFooterContentInset]

#define TableViewGroupedBackgroundColor                 [CIGAMCMI tableViewGroupedBackgroundColor]               // Grouped 类型的 CIGAMTableView 的背景色
#define TableViewGroupedSeparatorColor                  [CIGAMCMI tableViewGroupedSeparatorColor]                // Grouped 类型的 CIGAMTableView 分隔线颜色
#define TableViewGroupedCellTitleLabelColor             [CIGAMCMI tableViewGroupedCellTitleLabelColor]           // Grouped 类型的列表的 CIGAMTableViewCell 的标题颜色
#define TableViewGroupedCellDetailLabelColor            [CIGAMCMI tableViewGroupedCellDetailLabelColor]          // Grouped 类型的列表的 CIGAMTableViewCell 的副标题颜色
#define TableViewGroupedCellBackgroundColor             [CIGAMCMI tableViewGroupedCellBackgroundColor]           // Grouped 类型的列表的 CIGAMTableViewCell 的背景色
#define TableViewGroupedCellSelectedBackgroundColor     [CIGAMCMI tableViewGroupedCellSelectedBackgroundColor]   // Grouped 类型的列表的 CIGAMTableViewCell 点击时的背景色
#define TableViewGroupedCellWarningBackgroundColor      [CIGAMCMI tableViewGroupedCellWarningBackgroundColor]    // Grouped 类型的列表的 CIGAMTableViewCell 在提醒状态下的背景色
#define TableViewGroupedSectionHeaderFont               [CIGAMCMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont               [CIGAMCMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor          [CIGAMCMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor          [CIGAMCMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderAccessoryMargins   [CIGAMCMI tableViewGroupedSectionHeaderAccessoryMargins]
#define TableViewGroupedSectionFooterAccessoryMargins   [CIGAMCMI tableViewGroupedSectionFooterAccessoryMargins]
#define TableViewGroupedSectionHeaderDefaultHeight      [CIGAMCMI tableViewGroupedSectionHeaderDefaultHeight]
#define TableViewGroupedSectionFooterDefaultHeight      [CIGAMCMI tableViewGroupedSectionFooterDefaultHeight]
#define TableViewGroupedSectionHeaderContentInset       [CIGAMCMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset       [CIGAMCMI tableViewGroupedSectionFooterContentInset]

#define TableViewInsetGroupedCornerRadius               [CIGAMCMI tableViewInsetGroupedCornerRadius] // InsetGrouped 类型的 UITableView 内 cell 的圆角值
#define TableViewInsetGroupedHorizontalInset            [CIGAMCMI tableViewInsetGroupedHorizontalInset] // InsetGrouped 类型的 UITableView 内的左右缩进值
#define TableViewInsetGroupedBackgroundColor            [CIGAMCMI tableViewInsetGroupedBackgroundColor] // InsetGrouped 类型的 UITableView 的背景色
#define TableViewInsetGroupedSeparatorColor                  [CIGAMCMI tableViewInsetGroupedSeparatorColor]                // InsetGrouped 类型的 CIGAMTableView 分隔线颜色
#define TableViewInsetGroupedCellTitleLabelColor             [CIGAMCMI tableViewInsetGroupedCellTitleLabelColor]           // InsetGrouped 类型的列表的 CIGAMTableViewCell 的标题颜色
#define TableViewInsetGroupedCellDetailLabelColor            [CIGAMCMI tableViewInsetGroupedCellDetailLabelColor]          // InsetGrouped 类型的列表的 CIGAMTableViewCell 的副标题颜色
#define TableViewInsetGroupedCellBackgroundColor             [CIGAMCMI tableViewInsetGroupedCellBackgroundColor]           // InsetGrouped 类型的列表的 CIGAMTableViewCell 的背景色
#define TableViewInsetGroupedCellSelectedBackgroundColor     [CIGAMCMI tableViewInsetGroupedCellSelectedBackgroundColor]   // InsetGrouped 类型的列表的 CIGAMTableViewCell 点击时的背景色
#define TableViewInsetGroupedCellWarningBackgroundColor      [CIGAMCMI tableViewInsetGroupedCellWarningBackgroundColor]    // InsetGrouped 类型的列表的 CIGAMTableViewCell 在提醒状态下的背景色
#define TableViewInsetGroupedSectionHeaderFont               [CIGAMCMI tableViewInsetGroupedSectionHeaderFont]
#define TableViewInsetGroupedSectionFooterFont               [CIGAMCMI tableViewInsetGroupedSectionFooterFont]
#define TableViewInsetGroupedSectionHeaderTextColor          [CIGAMCMI tableViewInsetGroupedSectionHeaderTextColor]
#define TableViewInsetGroupedSectionFooterTextColor          [CIGAMCMI tableViewInsetGroupedSectionFooterTextColor]
#define TableViewInsetGroupedSectionHeaderAccessoryMargins   [CIGAMCMI tableViewInsetGroupedSectionHeaderAccessoryMargins]
#define TableViewInsetGroupedSectionFooterAccessoryMargins   [CIGAMCMI tableViewInsetGroupedSectionFooterAccessoryMargins]
#define TableViewInsetGroupedSectionHeaderDefaultHeight      [CIGAMCMI tableViewInsetGroupedSectionHeaderDefaultHeight]
#define TableViewInsetGroupedSectionFooterDefaultHeight      [CIGAMCMI tableViewInsetGroupedSectionFooterDefaultHeight]
#define TableViewInsetGroupedSectionHeaderContentInset       [CIGAMCMI tableViewInsetGroupedSectionHeaderContentInset]
#define TableViewInsetGroupedSectionFooterContentInset       [CIGAMCMI tableViewInsetGroupedSectionFooterContentInset]

#pragma mark - UIWindowLevel
#define UIWindowLevelCIGAMAlertView                      [CIGAMCMI windowLevelCIGAMAlertView]
#define UIWindowLevelCIGAMConsole                        [CIGAMCMI windowLevelCIGAMConsole]

#pragma mark - CIGAMLog
#define ShouldPrintDefaultLog                           [CIGAMCMI shouldPrintDefaultLog]
#define ShouldPrintInfoLog                              [CIGAMCMI shouldPrintInfoLog]
#define ShouldPrintWarnLog                              [CIGAMCMI shouldPrintWarnLog]
#define ShouldPrintCIGAMWarnLogToConsole                 [CIGAMCMI shouldPrintCIGAMWarnLogToConsole] // 是否在出现 CIGAMLogWarn 时自动把这些 log 以 CIGAMConsole 的方式显示到设备屏幕上

#pragma mark - CIGAMBadge
#define BadgeBackgroundColor                            [CIGAMCMI badgeBackgroundColor]
#define BadgeTextColor                                  [CIGAMCMI badgeTextColor]
#define BadgeFont                                       [CIGAMCMI badgeFont]
#define BadgeContentEdgeInsets                          [CIGAMCMI badgeContentEdgeInsets]
#define BadgeOffset                                     [CIGAMCMI badgeOffset]
#define BadgeOffsetLandscape                            [CIGAMCMI badgeOffsetLandscape]
#define BadgeCenterOffset                               [CIGAMCMI badgeCenterOffset]
#define BadgeCenterOffsetLandscape                      [CIGAMCMI badgeCenterOffsetLandscape]

#define UpdatesIndicatorColor                           [CIGAMCMI updatesIndicatorColor]
#define UpdatesIndicatorSize                            [CIGAMCMI updatesIndicatorSize]
#define UpdatesIndicatorOffset                          [CIGAMCMI updatesIndicatorOffset]
#define UpdatesIndicatorOffsetLandscape                 [CIGAMCMI updatesIndicatorOffsetLandscape]
#define UpdatesIndicatorCenterOffset                    [CIGAMCMI updatesIndicatorCenterOffset]
#define UpdatesIndicatorCenterOffsetLandscape           [CIGAMCMI updatesIndicatorCenterOffsetLandscape]

#pragma mark - Others

#define AutomaticCustomNavigationBarTransitionStyle [CIGAMCMI automaticCustomNavigationBarTransitionStyle] // 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
#define SupportedOrientationMask                        [CIGAMCMI supportedOrientationMask]          // 默认支持的横竖屏方向
#define AutomaticallyRotateDeviceOrientation            [CIGAMCMI automaticallyRotateDeviceOrientation]  // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
#define StatusbarStyleLightInitially                    [CIGAMCMI statusbarStyleLightInitially]      // 默认的状态栏内容是否使用白色，默认为 NO，在 iOS 13 下会自动根据是否 Dark Mode 而切换样式，iOS 12 及以前则为黑色
#define NeedsBackBarButtonItemTitle                     [CIGAMCMI needsBackBarButtonItemTitle]       // 全局是否需要返回按钮的title，不需要则只显示一个返回image
#define HidesBottomBarWhenPushedInitially               [CIGAMCMI hidesBottomBarWhenPushedInitially] // CIGAMCommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
#define PreventConcurrentNavigationControllerTransitions [CIGAMCMI preventConcurrentNavigationControllerTransitions] // PreventConcurrentNavigationControllerTransitions : 自动保护 CIGAMNavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
#define NavigationBarHiddenInitially                    [CIGAMCMI navigationBarHiddenInitially]      // preferredNavigationBarHidden 的初始值，默认为NO
#define ShouldFixTabBarTransitionBugInIPhoneX           [CIGAMCMI shouldFixTabBarTransitionBugInIPhoneX] // 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
#define ShouldFixTabBarSafeAreaInsetsBug [CIGAMCMI shouldFixTabBarSafeAreaInsetsBug] // 是否要对 iOS 11 及以后的版本修复当存在 UITabBar 时，UIScrollView 的 inset.bottom 可能错误的 bug（issue #218 #934），默认为 YES
#define ShouldFixSearchBarMaskViewLayoutBug             [CIGAMCMI shouldFixSearchBarMaskViewLayoutBug] // 是否自动修复 UISearchController.searchBar 被当作 tableHeaderView 使用时可能出现的布局 bug(issue #950)
#define SendAnalyticsToCIGAMTeam                         [CIGAMCMI sendAnalyticsToCIGAMTeam] // 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 CIGAM 统计用
#define DynamicPreferredValueForIPad                    [CIGAMCMI dynamicPreferredValueForIPad] // 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
#define IgnoreKVCAccessProhibited                       [CIGAMCMI ignoreKVCAccessProhibited] // 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
#define AdjustScrollIndicatorInsetsByContentInsetAdjustment [CIGAMCMI adjustScrollIndicatorInsetsByContentInsetAdjustment] // 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。

