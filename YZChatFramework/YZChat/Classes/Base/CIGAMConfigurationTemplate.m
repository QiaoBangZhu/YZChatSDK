/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMConfigurationTemplate.m
//  cigam
//
//  Created by CIGAM Team on 15/3/29.
//

#import "CIGAMConfigurationTemplate.h"
#import "CIGAMKit.h"

#import "UIColor+ColorExtension.h"

@implementation CIGAMConfigurationTemplate

#pragma mark - <CIGAMConfigurationTemplateProtocol>

- (void)applyConfigurationTemplate {

    // === 修改配置值 === //

    #pragma mark - Global Color

    CIGAMCMI.clearColor = UIColorMakeWithRGBA(255, 255, 255, 0);                 // UIColorClear : 透明色
    CIGAMCMI.whiteColor = UIColorMake(255, 255, 255);                            // UIColorWhite : 白色（不用 [UIColor whiteColor] 是希望保持颜色空间为 RGB）
    CIGAMCMI.blackColor = UIColorMake(0, 0, 0);                                  // UIColorBlack : 黑色（不用 [UIColor blackColor] 是希望保持颜色空间为 RGB）
    CIGAMCMI.grayColor = UIColorMake(179, 179, 179);                             // UIColorGray  : 最常用的灰色
    CIGAMCMI.grayDarkenColor = UIColorMake(163, 163, 163);                       // UIColorGrayDarken : 深一点的灰色
    CIGAMCMI.grayLightenColor = UIColorMake(198, 198, 198);                      // UIColorGrayLighten : 浅一点的灰色
    CIGAMCMI.redColor = UIColorMake(250, 58, 58);                                // UIColorRed : 红色
    CIGAMCMI.greenColor = UIColorMake(159, 214, 97);                             // UIColorGreen : 绿色
    CIGAMCMI.blueColor = UIColorMake(49, 189, 243);                              // UIColorBlue : 蓝色
    CIGAMCMI.yellowColor = UIColorMake(255, 207, 71);                            // UIColorYellow : 黄色

    CIGAMCMI.linkColor = UIColorMake(56, 116, 171);                              // UIColorLink : 文字链接颜色
    CIGAMCMI.disabledColor = UIColorGray;                                        // UIColorDisabled : 全局 disabled 的颜色，一般用于 UIControl 等控件
    CIGAMCMI.backgroundColor = nil;                                              // UIColorForBackground : 界面背景色，默认用于 CIGAMCommonViewController.view 的背景色
    CIGAMCMI.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);                 // UIColorMask : 深色的背景遮罩，默认用于 QMAlertController、CIGAMDialogViewController 等弹出控件的遮罩
    CIGAMCMI.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);           // UIColorMaskWhite : 浅色的背景遮罩，CIGAMKit 里默认没用到，只是占个位
    CIGAMCMI.separatorColor = UIColorMake(222, 224, 226);                        // UIColorSeparator : 全局默认的分割线颜色，默认用于列表分隔线颜色、UIView (CIGAMBorder) 分隔线颜色
    CIGAMCMI.separatorDashedColor = UIColorMake(17, 17, 17);                     // UIColorSeparatorDashed : 全局默认的虚线分隔线的颜色，默认 CIGAMKit 暂时没用到
    CIGAMCMI.placeholderColor = UIColorMake(196, 200, 208);                      // UIColorPlaceholder，全局的输入框的 placeholder 颜色，默认用于 CIGAMTextField、CIGAMTextView，不影响系统 UIKit 的输入框

    // 测试用的颜色
    CIGAMCMI.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    CIGAMCMI.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    CIGAMCMI.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);


    #pragma mark - UIControl

    CIGAMCMI.controlHighlightedAlpha = 0.5f;                                     // UIControlHighlightedAlpha : UIControl 系列控件在 highlighted 时的 alpha，默认用于 CIGAMButton、 CIGAMNavigationTitleView
    CIGAMCMI.controlDisabledAlpha = 0.5f;                                        // UIControlDisabledAlpha : UIControl 系列控件在 disabled 时的 alpha，默认用于 CIGAMButton

    #pragma mark - UIButton
    CIGAMCMI.buttonHighlightedAlpha = UIControlHighlightedAlpha;                 // ButtonHighlightedAlpha : CIGAMButton 在 highlighted 时的 alpha，不影响系统的 UIButton
    CIGAMCMI.buttonDisabledAlpha = UIControlDisabledAlpha;                       // ButtonDisabledAlpha : CIGAMButton 在 disabled 时的 alpha，不影响系统的 UIButton
    CIGAMCMI.buttonTintColor = UIColorBlue;                                      // ButtonTintColor : CIGAMButton 默认的 tintColor，不影响系统的 UIButton

    CIGAMCMI.ghostButtonColorBlue = UIColorBlue;                                 // GhostButtonColorBlue : CIGAMGhostButtonColorBlue 的颜色
    CIGAMCMI.ghostButtonColorRed = UIColorRed;                                   // GhostButtonColorRed : CIGAMGhostButtonColorRed 的颜色
    CIGAMCMI.ghostButtonColorGreen = UIColorGreen;                               // GhostButtonColorGreen : CIGAMGhostButtonColorGreen 的颜色
    CIGAMCMI.ghostButtonColorGray = UIColorGray;                                 // GhostButtonColorGray : CIGAMGhostButtonColorGray 的颜色
    CIGAMCMI.ghostButtonColorWhite = UIColorWhite;                               // GhostButtonColorWhite : CIGAMGhostButtonColorWhite 的颜色

    CIGAMCMI.fillButtonColorBlue = UIColorBlue;                                  // FillButtonColorBlue : CIGAMFillButtonColorBlue 的颜色
    CIGAMCMI.fillButtonColorRed = UIColorRed;                                    // FillButtonColorRed : CIGAMFillButtonColorRed 的颜色
    CIGAMCMI.fillButtonColorGreen = UIColorGreen;                                // FillButtonColorGreen : CIGAMFillButtonColorGreen 的颜色
    CIGAMCMI.fillButtonColorGray = UIColorGray;                                  // FillButtonColorGray : CIGAMFillButtonColorGray 的颜色
    CIGAMCMI.fillButtonColorWhite = UIColorWhite;                                // FillButtonColorWhite : CIGAMFillButtonColorWhite 的颜色

    #pragma mark - TextInput
    CIGAMCMI.textFieldTextColor = nil;                                           // TextFieldTextColor : CIGAMTextField、CIGAMTextView 的 textColor，不影响 UIKit 的输入框
    CIGAMCMI.textFieldTintColor = nil;                                           // TextFieldTintColor : CIGAMTextField、CIGAMTextView 的 tintColor，不影响 UIKit 的输入框
    CIGAMCMI.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);                 // TextFieldTextInsets : CIGAMTextField 的内边距，不影响 UITextField
    CIGAMCMI.keyboardAppearance = UIKeyboardAppearanceDefault;                   // KeyboardAppearance : UITextView、UITextField、UISearchBar 的 keyboardAppearance

    #pragma mark - UISwitch
    CIGAMCMI.switchOnTintColor = nil;                                            // SwitchOnTintColor : UISwitch 打开时的背景色（除了圆点外的其他颜色）
    CIGAMCMI.switchOffTintColor = nil;                                           // SwitchOffTintColor : UISwitch 关闭时的背景色（除了圆点外的其他颜色）
    CIGAMCMI.switchTintColor = nil;                                              // SwitchTintColor : UISwitch 关闭时的周围边框颜色
    CIGAMCMI.switchThumbTintColor = nil;                                         // SwitchThumbTintColor : UISwitch 中间的操控圆点的颜色

    #pragma mark - NavigationBar

    CIGAMCMI.navBarContainerClasses = @[CIGAMNavigationController.class];                                       // NavBarContainerClasses : NavigationBar 系列开关被用于 UIAppearance 时的生效范围（默认情况下除了用于 UIAppearance 外，还用于实现了 CIGAMNavigationControllerAppearanceDelegate 的 UIViewController），默认为 nil。当赋值为 nil 或者空数组时等效于 @[UINavigationController.class]，也即对所有 UINavigationBar 生效，包括系统的通讯录（ContactsUI.framework)、打印等。当值不为空时，获取 UINavigationBar 的 appearance 请使用 UINavigationBar.cigam_appearanceConfigured 方法代替系统的 UINavigationBar.appearance。请保证这个配置项先于其他任意 NavBar 配置项执行。
    CIGAMCMI.navBarHighlightedAlpha = 0.2f;                                      // NavBarHighlightedAlpha : CIGAMNavigationButton 在 highlighted 时的 alpha
    CIGAMCMI.navBarDisabledAlpha = 0.2f;                                         // NavBarDisabledAlpha : CIGAMNavigationButton 在 disabled 时的 alpha
    CIGAMCMI.navBarButtonFont = nil;                                             // NavBarButtonFont : CIGAMNavigationButtonTypeNormal 和 UINavigationBar 上的 UIBarButtonItem 的字体
    CIGAMCMI.navBarButtonFontBold = nil;                                         // NavBarButtonFontBold : CIGAMNavigationButtonTypeBold 的字体
    CIGAMCMI.navBarBackgroundImage = nil;                                        // NavBarBackgroundImage : UINavigationBar 的背景图
    CIGAMCMI.navBarShadowImage = nil;                                            // NavBarShadowImage : UINavigationBar.shadowImage，也即导航栏底部那条分隔线，配合 NavBarShadowImageColor 使用。
    CIGAMCMI.navBarShadowImageColor = UIColorWhite;                                       // NavBarShadowImageColor : UINavigationBar.shadowImage 的颜色，如果为 nil，则使用 NavBarShadowImage 的值，如果 NavBarShadowImage 也为 nil，则使用系统默认的分隔线。如果不为 nil，而 NavBarShadowImage 为 nil，则自动创建一张 1px 高的图并将其设置为 NavBarShadowImageColor 的颜色然后设置上去，如果 NavBarShadowImage 不为 nil 且 renderingMode 不为 UIImageRenderingModeAlwaysOriginal，则将 NavBarShadowImage 设置为 NavBarShadowImageColor 的颜色然后设置上去。
    CIGAMCMI.navBarBarTintColor = UIColorWhite;                                           // NavBarBarTintColor : UINavigationBar.barTintColor，也即背景色
    CIGAMCMI.navBarStyle = UIBarStyleDefault;                                    // NavBarStyle : UINavigationBar 的 barStyle
    CIGAMCMI.navBarTintColor = UIColorBlack;                                              // NavBarTintColor : NavBarContainerClasses 里的 UINavigationBar 的 tintColor，也即导航栏上面的按钮颜色
    CIGAMCMI.navBarTitleColor = UIColorBlack;                                             // NavBarTitleColor : UINavigationBar 的标题颜色，以及 CIGAMNavigationTitleView 的默认文字颜色
    CIGAMCMI.navBarTitleFont = nil;                                              // NavBarTitleFont : UINavigationBar 的标题字体，以及 CIGAMNavigationTitleView 的默认字体
    CIGAMCMI.navBarLargeTitleColor = nil;                                        // NavBarLargeTitleColor : UINavigationBar 在大标题模式下的标题颜色，仅在 iOS 11 之后才有效
    CIGAMCMI.navBarLargeTitleFont = nil;                                         // NavBarLargeTitleFont : UINavigationBar 在大标题模式下的标题字体，仅在 iOS 11 之后才有效
    CIGAMCMI.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;             // NavBarBarBackButtonTitlePositionAdjustment : 导航栏返回按钮的文字偏移
    CIGAMCMI.sizeNavBarBackIndicatorImageAutomatically = YES;                    // SizeNavBarBackIndicatorImageAutomatically : 是否要自动调整 NavBarBackIndicatorImage 的 size 为 (13, 21)
    CIGAMCMI.navBarBackIndicatorImage = nil;                                     // NavBarBackIndicatorImage : 导航栏的返回按钮的图片，图片尺寸建议为(13, 21)，否则最终的图片位置无法与系统原生的位置保持一致
    CIGAMCMI.navBarCloseButtonImage = [UIImage cigam_imageWithShape:CIGAMImageShapeNavClose size:CGSizeMake(16, 16) tintColor:NavBarTintColor];     // NavBarCloseButtonImage : CIGAMNavigationButton 用到的 × 的按钮图片

    CIGAMCMI.navBarLoadingMarginRight = 3;                                       // NavBarLoadingMarginRight : CIGAMNavigationTitleView 里左边 loading 的右边距
    CIGAMCMI.navBarAccessoryViewMarginLeft = 5;                                  // NavBarAccessoryViewMarginLeft : CIGAMNavigationTitleView 里右边 accessoryView 的左边距
    CIGAMCMI.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;// NavBarActivityIndicatorViewStyle : CIGAMNavigationTitleView 里左边 loading 的主题
    CIGAMCMI.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage cigam_imageWithShape:CIGAMImageShapeTriangle size:CGSizeMake(8, 5) tintColor:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];     // NavBarAccessoryViewTypeDisclosureIndicatorImage : CIGAMNavigationTitleView 右边箭头的图片

    #pragma mark - TabBar

    CIGAMCMI.tabBarContainerClasses = @[CIGAMTabBarViewController.class];                                       // TabBarContainerClasses : TabBar 系列开关的生效范围，默认为 nil，当赋值为 nil 或者空数组时等效于 @[UITabBarController.class]，也即对所有 UITabBar 生效。当值不为空时，获取 UITabBar 的 appearance 请使用 UITabBar.cigam_appearanceConfigured 方法代替系统的 UITabBar.appearance。请保证这个配置项先于其他任意 TabBar 配置项执行。
    CIGAMCMI.tabBarBackgroundImage = nil;                                        // TabBarBackgroundImage : UITabBar 的背景图
    CIGAMCMI.tabBarBarTintColor = nil;                                           // TabBarBarTintColor : UITabBar 的 barTintColor，如果需要看到磨砂效果则应该提供半透明的色值
    CIGAMCMI.tabBarShadowImageColor = nil;                                       // TabBarShadowImageColor : UITabBar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
    CIGAMCMI.tabBarStyle = UIBarStyleDefault;                                    // TabBarStyle : UITabBar 的 barStyle
    CIGAMCMI.tabBarItemTitleFont = nil;                                          // TabBarItemTitleFont : UITabBarItem 的标题字体
    CIGAMCMI.tabBarItemTitleFontSelected = nil;                                  // TabBarItemTitleFontSelected : 选中的 UITabBarItem 的标题字体
    CIGAMCMI.tabBarItemTitleColor = nil;                                         // TabBarItemTitleColor : 未选中的 UITabBarItem 的标题颜色
    CIGAMCMI.tabBarItemTitleColorSelected = nil;                                 // TabBarItemTitleColorSelected : 选中的 UITabBarItem 的标题颜色
    CIGAMCMI.tabBarItemImageColor = nil;                                         // TabBarItemImageColor : UITabBarItem 未选中时的图片颜色
    CIGAMCMI.tabBarItemImageColorSelected = nil;                                 // TabBarItemImageColorSelected : UITabBarItem 选中时的图片颜色

    #pragma mark - Toolbar

    CIGAMCMI.toolBarContainerClasses = @[CIGAMNavigationController.class];                                      // ToolBarContainerClasses : ToolBar 系列开关的生效范围，默认为 nil，当赋值为 nil 或者空数组时等效于 @[UINavigationController.class]，也即对所有 UIToolbar 生效。当值不为空时，获取 UIToolbar 的 appearance 请使用 UIToolbar.cigam_appearanceConfigured 方法代替系统的 UIToolbar.appearance。请保证这个配置项先于其他任意 ToolBar 配置项执行。
    CIGAMCMI.toolBarHighlightedAlpha = 0.4f;                                     // ToolBarHighlightedAlpha : CIGAMToolbarButton 在 highlighted 状态下的 alpha
    CIGAMCMI.toolBarDisabledAlpha = 0.4f;                                        // ToolBarDisabledAlpha : CIGAMToolbarButton 在 disabled 状态下的 alpha
    CIGAMCMI.toolBarTintColor = nil;                                             // ToolBarTintColor : NavBarContainerClasses 里的 UIToolbar 的 tintColor，以及 CIGAMToolbarButton normal 状态下的文字颜色
    CIGAMCMI.toolBarTintColorHighlighted = [ToolBarTintColor colorWithAlphaComponent:ToolBarHighlightedAlpha];   // ToolBarTintColorHighlighted : CIGAMToolbarButton 在 highlighted 状态下的文字颜色
    CIGAMCMI.toolBarTintColorDisabled = [ToolBarTintColor colorWithAlphaComponent:ToolBarDisabledAlpha];         // ToolBarTintColorDisabled : CIGAMToolbarButton 在 disabled 状态下的文字颜色
    CIGAMCMI.toolBarBackgroundImage = nil;                                       // ToolBarBackgroundImage : NavBarContainerClasses 里的 UIToolbar 的背景图
    CIGAMCMI.toolBarBarTintColor = nil;                                          // ToolBarBarTintColor : NavBarContainerClasses 里的 UIToolbar 的 tintColor
    CIGAMCMI.toolBarShadowImageColor = nil;                                      // ToolBarShadowImageColor : NavBarContainerClasses 里的 UIToolbar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
    CIGAMCMI.toolBarStyle = UIBarStyleDefault;                                   // ToolBarStyle : NavBarContainerClasses 里的 UIToolbar 的 barStyle
    CIGAMCMI.toolBarButtonFont = nil;                                            // ToolBarButtonFont : CIGAMToolbarButton 的字体

    #pragma mark - SearchBar

    CIGAMCMI.searchBarTextFieldBackgroundImage = nil;                            // SearchBarTextFieldBackgroundImage : CIGAMSearchBar 里的文本框的背景图，图片高度会决定输入框的高度
    CIGAMCMI.searchBarTextFieldBorderColor = nil;                                // SearchBarTextFieldBorderColor : CIGAMSearchBar 里的文本框的边框颜色
    CIGAMCMI.searchBarTextFieldCornerRadius = 2.0;                               // SearchBarTextFieldCornerRadius : CIGAMSearchBar 里的文本框的圆角大小，-1 表示圆角大小为输入框高度的一半
    CIGAMCMI.searchBarBackgroundImage = [UISearchBar cigam_generateBackgroundImageWithColor: UIColorWhite borderColor: nil];                                     // SearchBarBackgroundImage : 搜索框的背景图，如果需要设置底部分隔线的颜色也请绘制到图片里
    CIGAMCMI.searchBarTintColor = UIColorBlack;                                           // SearchBarTintColor : CIGAMSearchBar 的 tintColor，也即上面的操作控件的主题色
    CIGAMCMI.searchBarTextColor = nil;                                           // SearchBarTextColor : CIGAMSearchBar 里的文本框的文字颜色
    CIGAMCMI.searchBarPlaceholderColor = UIColorPlaceholder;                     // SearchBarPlaceholderColor : CIGAMSearchBar 里的文本框的 placeholder 颜色
    CIGAMCMI.searchBarFont = nil;                                                // SearchBarFont : CIGAMSearchBar 里的文本框的文字字体及 placeholder 的字体
    CIGAMCMI.searchBarSearchIconImage = nil;                                     // SearchBarSearchIconImage : CIGAMSearchBar 里的放大镜 icon
    CIGAMCMI.searchBarClearIconImage = nil;                                      // SearchBarClearIconImage : CIGAMSearchBar 里的文本框输入文字时右边的清空按钮的图片

    #pragma mark - Plain TableView

    CIGAMCMI.tableViewEstimatedHeightEnabled = YES;                              // TableViewEstimatedHeightEnabled : 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

    CIGAMCMI.tableViewBackgroundColor = nil;                                     // TableViewBackgroundColor : Plain 类型的 CIGAMTableView 的背景色颜色
    CIGAMCMI.tableSectionIndexColor = nil;                                       // TableSectionIndexColor : 列表右边的字母索引条的文字颜色
    CIGAMCMI.tableSectionIndexBackgroundColor = nil;                             // TableSectionIndexBackgroundColor : 列表右边的字母索引条的背景色
    CIGAMCMI.tableSectionIndexTrackingBackgroundColor = nil;                     // TableSectionIndexTrackingBackgroundColor : 列表右边的字母索引条在选中时的背景色
    CIGAMCMI.tableViewSeparatorColor = UIColorSeparator;                         // TableViewSeparatorColor : 列表的分隔线颜色

    CIGAMCMI.tableViewCellNormalHeight = UITableViewAutomaticDimension;          // TableViewCellNormalHeight : CIGAMTableView 的默认 cell 高度
    CIGAMCMI.tableViewCellTitleLabelColor = nil;                                 // TableViewCellTitleLabelColor : CIGAMTableViewCell 的 textLabel 的文字颜色
    CIGAMCMI.tableViewCellDetailLabelColor = nil;                                // TableViewCellDetailLabelColor : CIGAMTableViewCell 的 detailTextLabel 的文字颜色
    CIGAMCMI.tableViewCellBackgroundColor = nil;                                 // TableViewCellBackgroundColor : CIGAMTableViewCell 的背景色
    CIGAMCMI.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);  // TableViewCellSelectedBackgroundColor : CIGAMTableViewCell 点击时的背景色
    CIGAMCMI.tableViewCellWarningBackgroundColor = UIColorYellow;                // TableViewCellWarningBackgroundColor : CIGAMTableViewCell 用于表示警告时的背景色，备用
    CIGAMCMI.tableViewCellDisclosureIndicatorImage = nil;                        // TableViewCellDisclosureIndicatorImage : CIGAMTableViewCell 当 accessoryType 为 UITableViewCellAccessoryDisclosureIndicator 时的箭头的图片
    CIGAMCMI.tableViewCellCheckmarkImage = nil;                                  // TableViewCellCheckmarkImage : CIGAMTableViewCell 当 accessoryType 为 UITableViewCellAccessoryCheckmark 时的打钩的图片
    CIGAMCMI.tableViewCellDetailButtonImage = nil; // TableViewCellDetailButtonImage : CIGAMTableViewCell 当 accessoryType 为 UITableViewCellAccessoryDetailButton 或 UITableViewCellAccessoryDetailDisclosureButton 时右边的 i 按钮图片
    CIGAMCMI.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12; // TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator : 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

    CIGAMCMI.tableViewSectionHeaderBackgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];                         // TableViewSectionHeaderBackgroundColor : Plain 类型的 CIGAMTableView sectionHeader 的背景色
    CIGAMCMI.tableViewSectionFooterBackgroundColor = [UIColor colorWithHex: KCommonBackgroundColor];                         // TableViewSectionFooterBackgroundColor : Plain 类型的 CIGAMTableView sectionFooter 的背景色
    CIGAMCMI.tableViewSectionHeaderFont = UIFontBoldMake(12);                                            // TableViewSectionHeaderFont : Plain 类型的 CIGAMTableView sectionHeader 里的文字字体
    CIGAMCMI.tableViewSectionFooterFont = UIFontBoldMake(12);                                            // TableViewSectionFooterFont : Plain 类型的 CIGAMTableView sectionFooter 里的文字字体
    CIGAMCMI.tableViewSectionHeaderTextColor = UIColorGrayDarken;                                        // TableViewSectionHeaderTextColor : Plain 类型的 CIGAMTableView sectionHeader 里的文字颜色
    CIGAMCMI.tableViewSectionFooterTextColor = UIColorGray;                                              // TableViewSectionFooterTextColor : Plain 类型的 CIGAMTableView sectionFooter 里的文字颜色
    CIGAMCMI.tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewSectionHeaderAccessoryMargins : Plain 类型的 CIGAMTableView sectionHeader accessoryView 的间距
    CIGAMCMI.tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewSectionFooterAccessoryMargins : Plain 类型的 CIGAMTableView sectionFooter accessoryView 的间距
    CIGAMCMI.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionHeaderContentInset : Plain 类型的 CIGAMTableView sectionHeader 里的内容的 padding
    CIGAMCMI.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionFooterContentInset : Plain 类型的 CIGAMTableView sectionFooter 里的内容的 padding

    #pragma mark - Grouped TableView
    CIGAMCMI.tableViewGroupedBackgroundColor = nil;                                                      // TableViewGroupedBackgroundColor : Grouped 类型的 CIGAMTableView 的背景色
    CIGAMCMI.tableViewGroupedSeparatorColor = TableViewSeparatorColor;                                   // TableViewGroupedSeparatorColor : Grouped 类型的 CIGAMTableView 分隔线颜色
    CIGAMCMI.tableViewGroupedCellTitleLabelColor = TableViewCellTitleLabelColor;                         // TableViewGroupedCellTitleLabelColor : Grouped 类型的 CIGAMTableView cell 里的标题颜色
    CIGAMCMI.tableViewGroupedCellDetailLabelColor = TableViewCellDetailLabelColor;                       // TableViewGroupedCellDetailLabelColor : Grouped 类型的 CIGAMTableView cell 里的副标题颜色
    CIGAMCMI.tableViewGroupedCellBackgroundColor = TableViewCellBackgroundColor;                         // TableViewGroupedCellBackgroundColor : Grouped 类型的 CIGAMTableView cell 背景色
    CIGAMCMI.tableViewGroupedCellSelectedBackgroundColor = TableViewCellSelectedBackgroundColor;         // TableViewGroupedCellSelectedBackgroundColor : Grouped 类型的 CIGAMTableView cell 点击时的背景色
    CIGAMCMI.tableViewGroupedCellWarningBackgroundColor = TableViewCellWarningBackgroundColor;           // tableViewGroupedCellWarningBackgroundColor : Grouped 类型的 CIGAMTableView cell 在提醒状态下的背景色
    CIGAMCMI.tableViewGroupedSectionHeaderFont = UIFontMake(12);                                         // TableViewGroupedSectionHeaderFont : Grouped 类型的 CIGAMTableView sectionHeader 里的文字字体
    CIGAMCMI.tableViewGroupedSectionFooterFont = UIFontMake(12);                                         // TableViewGroupedSectionFooterFont : Grouped 类型的 CIGAMTableView sectionFooter 里的文字字体
    CIGAMCMI.tableViewGroupedSectionHeaderTextColor = UIColorGrayDarken;                                 // TableViewGroupedSectionHeaderTextColor : Grouped 类型的 CIGAMTableView sectionHeader 里的文字颜色
    CIGAMCMI.tableViewGroupedSectionFooterTextColor = UIColorGray;                                       // TableViewGroupedSectionFooterTextColor : Grouped 类型的 CIGAMTableView sectionFooter 里的文字颜色
    CIGAMCMI.tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewGroupedSectionHeaderAccessoryMargins : Grouped 类型的 CIGAMTableView sectionHeader accessoryView 的间距
    CIGAMCMI.tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewGroupedSectionFooterAccessoryMargins : Grouped 类型的 CIGAMTableView sectionFooter accessoryView 的间距
    CIGAMCMI.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension;                 // TableViewGroupedSectionHeaderDefaultHeight : Grouped 类型的 CIGAMTableView sectionHeader 的默认高度（也即没使用自定义的 sectionHeaderView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    CIGAMCMI.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension;                 // TableViewGroupedSectionFooterDefaultHeight : Grouped 类型的 CIGAMTableView sectionFooter 的默认高度（也即没使用自定义的 sectionFooterView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    CIGAMCMI.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);                // TableViewGroupedSectionHeaderContentInset : Grouped 类型的 CIGAMTableView sectionHeader 里的内容的 padding
    CIGAMCMI.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);                 // TableViewGroupedSectionFooterContentInset : Grouped 类型的 CIGAMTableView sectionFooter 里的内容的 padding

    #pragma mark - InsetGrouped TableView
    CIGAMCMI.tableViewInsetGroupedCornerRadius = 10;                                                     // TableViewInsetGroupedCornerRadius : InsetGrouped 类型的 UITableView 内 cell 的圆角值
    CIGAMCMI.tableViewInsetGroupedHorizontalInset = PreferredValueForVisualDevice(20, 15);               // TableViewInsetGroupedHorizontalInset: InsetGrouped 类型的 UITableView 内的左右缩进值
    CIGAMCMI.tableViewInsetGroupedBackgroundColor = TableViewGroupedBackgroundColor;                                                 // TableViewInsetGroupedBackgroundColor : InsetGrouped 类型的 UITableView 的背景色
    CIGAMCMI.tableViewInsetGroupedSeparatorColor = TableViewGroupedSeparatorColor;                                   // TableViewInsetGroupedSeparatorColor : InsetGrouped 类型的 CIGAMTableView 分隔线颜色
    CIGAMCMI.tableViewInsetGroupedCellTitleLabelColor = TableViewGroupedCellTitleLabelColor;                         // TableViewInsetGroupedCellTitleLabelColor : InsetGrouped 类型的 CIGAMTableView cell 里的标题颜色
    CIGAMCMI.tableViewInsetGroupedCellDetailLabelColor = TableViewGroupedCellDetailLabelColor;                       // TableViewInsetGroupedCellDetailLabelColor : InsetGrouped 类型的 CIGAMTableView cell 里的副标题颜色
    CIGAMCMI.tableViewInsetGroupedCellBackgroundColor = TableViewGroupedCellBackgroundColor;                         // TableViewInsetGroupedCellBackgroundColor : InsetGrouped 类型的 CIGAMTableView cell 背景色
    CIGAMCMI.tableViewInsetGroupedCellSelectedBackgroundColor = TableViewGroupedCellSelectedBackgroundColor;         // TableViewInsetGroupedCellSelectedBackgroundColor : InsetGrouped 类型的 CIGAMTableView cell 点击时的背景色
    CIGAMCMI.tableViewInsetGroupedCellWarningBackgroundColor = TableViewGroupedCellWarningBackgroundColor;           // TableViewInsetGroupedCellWarningBackgroundColor : InsetGrouped 类型的 CIGAMTableView cell 在提醒状态下的背景色
    CIGAMCMI.tableViewInsetGroupedSectionHeaderFont = TableViewGroupedSectionHeaderFont;                                         // TableViewInsetGroupedSectionHeaderFont : InsetGrouped 类型的 CIGAMTableView sectionHeader 里的文字字体
    CIGAMCMI.tableViewInsetGroupedSectionFooterFont = TableViewInsetGroupedSectionHeaderFont;                                         // TableViewInsetGroupedSectionFooterFont : InsetGrouped 类型的 CIGAMTableView sectionFooter 里的文字字体
    CIGAMCMI.tableViewInsetGroupedSectionHeaderTextColor = TableViewGroupedSectionHeaderTextColor;                                 // TableViewInsetGroupedSectionHeaderTextColor : InsetGrouped 类型的 CIGAMTableView sectionHeader 里的文字颜色
    CIGAMCMI.tableViewInsetGroupedSectionFooterTextColor = TableViewInsetGroupedSectionHeaderTextColor;                                       // TableViewInsetGroupedSectionFooterTextColor : InsetGrouped 类型的 CIGAMTableView sectionFooter 里的文字颜色
    CIGAMCMI.tableViewInsetGroupedSectionHeaderAccessoryMargins = TableViewGroupedSectionHeaderAccessoryMargins;                     // TableViewInsetGroupedSectionHeaderAccessoryMargins : InsetGrouped 类型的 CIGAMTableView sectionHeader accessoryView 的间距
    CIGAMCMI.tableViewInsetGroupedSectionFooterAccessoryMargins = TableViewInsetGroupedSectionHeaderAccessoryMargins;                     // TableViewInsetGroupedSectionFooterAccessoryMargins : InsetGrouped 类型的 CIGAMTableView sectionFooter accessoryView 的间距
    CIGAMCMI.tableViewInsetGroupedSectionHeaderDefaultHeight = TableViewGroupedSectionHeaderDefaultHeight;                 // TableViewInsetGroupedSectionHeaderDefaultHeight : InsetGrouped 类型的 CIGAMTableView sectionHeader 的默认高度（也即没使用自定义的 sectionHeaderView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    CIGAMCMI.tableViewInsetGroupedSectionFooterDefaultHeight = TableViewGroupedSectionFooterDefaultHeight;                 // TableViewInsetGroupedSectionFooterDefaultHeight : InsetGrouped 类型的 CIGAMTableView sectionFooter 的默认高度（也即没使用自定义的 sectionFooterView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    CIGAMCMI.tableViewInsetGroupedSectionHeaderContentInset = TableViewGroupedSectionHeaderContentInset;                // TableViewInsetGroupedSectionHeaderContentInset : InsetGrouped 类型的 CIGAMTableView sectionHeader 里的内容的 padding
    CIGAMCMI.tableViewInsetGroupedSectionFooterContentInset = TableViewInsetGroupedSectionHeaderContentInset;                 // TableViewInsetGroupedSectionFooterContentInset : InsetGrouped 类型的 CIGAMTableView sectionFooter 里的内容的 padding

    #pragma mark - UIWindowLevel
    CIGAMCMI.windowLevelCIGAMAlertView = UIWindowLevelAlert - 4.0;                // UIWindowLevelCIGAMAlertView : CIGAMModalPresentationViewController、CIGAMPopupContainerView 里使用的 UIWindow 的 windowLevel
    CIGAMCMI.windowLevelCIGAMConsole = 1;                                         // UIWindowLevelCIGAMConsole : CIGAMConsole 内部的 UIWindow 的 windowLevel

    #pragma mark - CIGAMLog
    CIGAMCMI.shouldPrintDefaultLog = YES;                                        // ShouldPrintDefaultLog : 是否允许输出 CIGAMLogLevelDefault 级别的 log
    CIGAMCMI.shouldPrintInfoLog = YES;                                           // ShouldPrintInfoLog : 是否允许输出 CIGAMLogLevelInfo 级别的 log
    CIGAMCMI.shouldPrintWarnLog = YES;                                           // ShouldPrintInfoLog : 是否允许输出 CIGAMLogLevelWarn 级别的 log

    #pragma mark - CIGAMBadge

    CIGAMCMI.badgeBackgroundColor = UIColorRed;                                  // BadgeBackgroundColor : CIGAMBadge 上的未读数的背景色
    CIGAMCMI.badgeTextColor = UIColorWhite;                                      // BadgeTextColor : CIGAMBadge 上的未读数的文字颜色
    CIGAMCMI.badgeFont = UIFontBoldMake(11);                                     // BadgeFont : CIGAMBadge 上的未读数的字体
    CIGAMCMI.badgeContentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);              // BadgeContentEdgeInsets : CIGAMBadge 上的未读数与圆圈之间的 padding
    CIGAMCMI.badgeOffset = CGPointMake(-9, 11);                                  // BadgeOffset : CIGAMBadge 上的未读数相对于目标 view 右上角的偏移
    CIGAMCMI.badgeOffsetLandscape = CGPointMake(-9, 6);                          // BadgeOffsetLandscape : CIGAMBadge 上的未读数在横屏下相对于目标 view 右上角的偏移
    BeginIgnoreDeprecatedWarning
    CIGAMCMI.badgeCenterOffset = CGPointMake(14, -10);                           // BadgeCenterOffset : CIGAMBadge 未读数相对于目标 view 中心的偏移
    CIGAMCMI.badgeCenterOffsetLandscape = CGPointMake(16, -7);                   // BadgeCenterOffsetLandscape : CIGAMBadge 未读数在横屏下相对于目标 view 中心的偏移
    EndIgnoreDeprecatedWarning

    CIGAMCMI.updatesIndicatorColor = UIColorRed;                                 // UpdatesIndicatorColor : CIGAMBadge 上的未读红点的颜色
    CIGAMCMI.updatesIndicatorSize = CGSizeMake(7, 7);                            // UpdatesIndicatorSize : CIGAMBadge 上的未读红点的大小
    CIGAMCMI.updatesIndicatorOffset = CGPointMake(4, UpdatesIndicatorSize.height);// UpdatesIndicatorOffset : CIGAMBadge 未读红点相对于目标 view 右上角的偏移
    CIGAMCMI.updatesIndicatorOffsetLandscape = UpdatesIndicatorOffset;           // UpdatesIndicatorOffsetLandscape : CIGAMBadge 未读红点在横屏下相对于目标 view 右上角的偏移
    BeginIgnoreDeprecatedWarning
    CIGAMCMI.updatesIndicatorCenterOffset = CGPointMake(14, -10);                // UpdatesIndicatorCenterOffset : CIGAMBadge 未读红点相对于目标 view 中心的偏移
    CIGAMCMI.updatesIndicatorCenterOffsetLandscape = CGPointMake(14, -10);       // UpdatesIndicatorCenterOffsetLandscape : CIGAMBadge 未读红点在横屏下相对于目标 view 中心点的偏移
    EndIgnoreDeprecatedWarning

    #pragma mark - Others

    CIGAMCMI.automaticCustomNavigationBarTransitionStyle = NO;                   // AutomaticCustomNavigationBarTransitionStyle : 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
    CIGAMCMI.supportedOrientationMask = UIInterfaceOrientationMaskAll;           // SupportedOrientationMask : 默认支持的横竖屏方向
    CIGAMCMI.automaticallyRotateDeviceOrientation = NO;                          // AutomaticallyRotateDeviceOrientation : 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕
    CIGAMCMI.statusbarStyleLightInitially = NO;                                  // StatusbarStyleLightInitially : 默认的状态栏内容是否使用白色，默认为 NO，在 iOS 13 下会自动根据是否 Dark Mode 而切换样式，iOS 12 及以前则为黑色。生效范围：处于 CIGAMTabBarController 或 CIGAMNavigationController 内的 vc，或者 CIGAMCommonViewController 及其子类。
    CIGAMCMI.needsBackBarButtonItemTitle = NO;                                  // NeedsBackBarButtonItemTitle : 全局是否需要返回按钮的 title，不需要则只显示一个返回image
    CIGAMCMI.hidesBottomBarWhenPushedInitially = YES;                             // HidesBottomBarWhenPushedInitially : CIGAMCommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
    CIGAMCMI.preventConcurrentNavigationControllerTransitions = YES;             // PreventConcurrentNavigationControllerTransitions : 自动保护 CIGAMNavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
    CIGAMCMI.navigationBarHiddenInitially = NO;                                  // NavigationBarHiddenInitially : CIGAMNavigationControllerDelegate preferredNavigationBarHidden 的初始值，默认为NO
    CIGAMCMI.shouldFixTabBarTransitionBugInIPhoneX = NO;                         // ShouldFixTabBarTransitionBugInIPhoneX : 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
    CIGAMCMI.shouldFixTabBarSafeAreaInsetsBug = NO;                              // ShouldFixTabBarSafeAreaInsetsBug : 是否要对 iOS 11 及以后的版本修复当存在 UITabBar 时，UIScrollView 的 inset.bottom 可能错误的 bug（issue #218 #934），默认为 YES
    CIGAMCMI.shouldFixSearchBarMaskViewLayoutBug = YES;                           // ShouldFixSearchBarMaskViewLayoutBug : 是否自动修复 UISearchController.searchBar 被当作 tableHeaderView 使用时可能出现的布局 bug(issue #950)
    CIGAMCMI.shouldPrintCIGAMWarnLogToConsole = IS_DEBUG;                         // ShouldPrintCIGAMWarnLogToConsole : 是否在出现 CIGAMLogWarn 时自动把这些 log 以 CIGAMConsole 的方式显示到设备屏幕上
    CIGAMCMI.sendAnalyticsToCIGAMTeam = YES;                                      // SendAnalyticsToCIGAMTeam : 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 CIGAM 统计用
    CIGAMCMI.dynamicPreferredValueForIPad = NO;                                  // DynamicPreferredValueForIPad : 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
    if (@available(iOS 13.0, *)) {
        CIGAMCMI.ignoreKVCAccessProhibited = NO;                                     // IgnoreKVCAccessProhibited : 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
        CIGAMCMI.adjustScrollIndicatorInsetsByContentInsetAdjustment = NO;           // AdjustScrollIndicatorInsetsByContentInsetAdjustment : 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。
    }
}

@end
