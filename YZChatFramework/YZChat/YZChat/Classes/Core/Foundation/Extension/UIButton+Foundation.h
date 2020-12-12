//
//  UIButton+Foundation.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Foundation)

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

- (CAShapeLayer*)addLineDashPattern:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
