//
//  UIViewController+NavigationBar.h
//  YChat
//
//  Created by magic on 2020/10/21.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZNavigationBar.h"

typedef NS_ENUM(NSUInteger, ZNavigationBarStyle) {
    ZNavigationBarStyleDefault,
    ZNavigationBarStyleLight,
    ZNavigationBarStyleClear,
};


NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (NavigationBar)

/**
 *  当前vc是否在展示
 */
@property (nonatomic, assign) BOOL isVisible;

/**
 *  当前vc是否隐藏自定义的navibar
 */
@property (nonatomic, assign) BOOL hiddenCustomNavi;

/**
 *  自定义的navigationBar
 */
@property (nonatomic, strong) ZNavigationBar * _Nullable navigationBar;

/**
 除去当前导航栏的区域后的view的区域
 */
@property (nonatomic, assign) CGRect viewBounds;

/**
 导航栏的样式，目前提供白色和默认（深色）两种，必须在初始化时修改生效
 */
@property (nonatomic, assign) ZNavigationBarStyle navigationBarStyle;

/**
 *  添加 navigationbar，子类重载
 */
- (void)addNavigationBar;

/**
 创建一个ZNavigationBar的实例，并加入vc，子类可以重载这个方法返回定制后的ZNavigationBar
 
 @return ZNavigationBar的实例
 */
- (__kindof ZNavigationBar *_Nullable)createNavigationBar;


/**
 *  pop 当前的 ViewController，子类可以重载
 */
- (void)back;

/**
 *  在导航栏增加一个默认的黑色返回按钮，点击时pop或者dismiss当前vc
 */
- (void)addDefaultBackButton;

/**
 *  在导航栏增加一个默认的返回按钮，点击时pop或者dismiss当前vc
 *
 *  @param image 返回按钮的图片
 */
- (void)addBackButtonWithImage:(UIImage *)image;

/**
 *  在导航栏增加左侧按钮
 *
 *  @param image   按钮的图片
 *  @param handler 按钮的点击事件
 */
- (void)addLeftButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler;
- (void)addSecondLeftButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler;

- (void)addCustomLeftButtonWithImage:(UIImage *)image handler:(void(^)(id sender))handler;

/**
 *  在导航栏增加右侧按钮
 *
 *  @param image   按钮的图片
 *  @param handler 按钮的点击事件
 */
- (void)addRightButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler;
- (void)addSecondRightButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler;

/**
 *  在导航栏增加一个文字按钮
 *
 *  @param title   按钮的文字
 *  @param handler 按钮的点击事件
 */
- (void)addRightButtonWithTitle:(NSString *)title handler:(void (^)(id sender))handler;
- (void)addLeftButtonWithTitle:(NSString *)title handler:(void (^)(id sender))handler;
- (void)addSecondLeftButtonWithTitle:(NSString *)title handler:(void (^)(id sender))handler;

/**
 *  当前vc是否隐藏返回主页按钮
 */
@property (nonatomic, assign) BOOL  hiddenGobackHomeBtn;

@property (nonatomic, assign) BOOL isLandscape;

@end

NS_ASSUME_NONNULL_END
