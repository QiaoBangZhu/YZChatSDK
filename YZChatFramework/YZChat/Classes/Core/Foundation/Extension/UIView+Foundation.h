//
//  UIView+Foundation.h
//  EarlyWarning
//
//  Created by peng.li on 2020/3/2.
//  Copyright © 2020 gengxianzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Foundation)

/**
 * Location in viewcontroller
 */
- (UIViewController *)locationInviewController;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;


- (UIImage *)snapshot;

- (UIImage *)snapshotAfterScreenUpdates:(BOOL)afterUpdates;

/**
 * Transfer to UIImage
 */
-(UIImage *)toImage;

- (UIColor *)colorAtPoint:(CGPoint)point;

#pragma mark - frame

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;
/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

// 布局方向
@property (nonatomic, assign, readonly) UIUserInterfaceLayoutDirection layoutDirection;

// 强制把方向改成从左到右排列, 在以色列等语言的适配中使用
- (void)forceLeftToRight;

@end

NS_ASSUME_NONNULL_END
