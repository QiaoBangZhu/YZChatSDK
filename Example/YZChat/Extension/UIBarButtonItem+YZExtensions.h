//
//  UIBarButtonItem+YZExtensions.h
//  YChat
//
//  Created by magic on 2020/10/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (YZExtensions)
- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image clickImage:(UIImage *)clickImage target:(id)target action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
