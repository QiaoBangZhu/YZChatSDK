//
//  ZNavigationBar.h
//  YChat
//
//  Created by magic on 2020/9/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#define ZStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define ZNavigationBarHeight (44.f + ZStatusBarHeight)
#define ZBarButtonLabelFontSize 12.f

#import <UIKit/UIKit.h>

@interface ZNavigationBar : UIView

/**
 *  标题文字
 */
@property(nonatomic, strong) NSString *title;

/**
 *  副标题文字
 */
@property(nonatomic, copy) NSString *subTitle;

/**
 *  titleview
 */
@property(nonatomic, strong) UIView *titleView;

/**
 *  标题的 label
 */
@property(nonatomic, readonly) UILabel *titleLabel;

/**
 *  左侧按钮
 */
@property(nonatomic, strong) UIButton *leftBarButton;

/**
 *  第二个侧按钮
 */
@property(nonatomic, strong) UIButton *secondLeftBarButton;

/**
 *  右侧按钮
 */
@property(nonatomic, strong) UIButton *rightBarButton;

/**
 *  右侧第二个按钮
 */
@property(nonatomic, strong) UIButton *secondRightBarButton;


/**
 *  放置内容的 view，不包含状态栏
 */
@property(nonatomic, strong) UIView *containerView;

/**
 *  导航栏扩容顶部view
 */
@property(nonatomic, strong) UIView *topView;


@property (nonatomic, strong) UIImageView* imageView;

/**
 *  默认字色
 */
@property (nonatomic, strong) UIColor *barButtonTitleColor;
@property (nonatomic, strong) UIColor *barButtonDisabledTitleColor;
@property (nonatomic, strong) UIColor *barButtonHighlightedTitleColor;
@property (nonatomic, strong) UIColor *titleColor;

@end
