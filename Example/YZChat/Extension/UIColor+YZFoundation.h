//
//  UIColor+YZFoundation.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ZJColorWithRGB(r,g,b) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f];
#define kColorRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (YZFoundation)

+ (UIColor *)random;
+ (UIColor *)colorWithHex:(int)hex;
+ (UIColor *)colorWithHex:(int)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(float)alpha;
+ (UIColor *)colorWithHexRGBAString:(NSString *)hexRGBAString;

@end

NS_ASSUME_NONNULL_END
