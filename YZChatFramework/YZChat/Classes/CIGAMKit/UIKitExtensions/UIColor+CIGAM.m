/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIColor+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 15/7/20.
//

#import "UIColor+CIGAM.h"
#import "CIGAMCore.h"
#import "NSString+CIGAM.h"
#import "NSObject+CIGAM.h"
#import "NSArray+CIGAM.h"

@implementation UIColor (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 使用 [UIColor colorWithRed:green:blue:alpha:] 或 [UIColor colorWithHue:saturation:brightness:alpha:] 方法创建的颜色是 UIDeviceRGBColor 类型的而不是 UIColor 类型的
        ExtendImplementationOfNonVoidMethodWithoutArguments([[UIColor colorWithRed:1 green:1 blue:1 alpha:1] class], @selector(description), NSString *, ^NSString *(UIColor *selfObject, NSString *originReturnValue) {
            NSInteger red = selfObject.cigam_red * 255;
            NSInteger green = selfObject.cigam_green * 255;
            NSInteger blue = selfObject.cigam_blue * 255;
            CGFloat alpha = selfObject.cigam_alpha;
            NSString *description = ([NSString stringWithFormat:@"%@, RGBA(%@, %@, %@, %.2f), %@", originReturnValue, @(red), @(green), @(blue), alpha, [selfObject cigam_hexString]]);
            return description;
        });
    });
}

+ (UIColor *)cigam_colorWithHexString:(NSString *)hexString {
    if (hexString.length <= 0) return nil;
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default: {
            NSAssert(NO, @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            return nil;
        }
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (NSString *)cigam_hexString {
    NSInteger alpha = self.cigam_alpha * 255;
    NSInteger red = self.cigam_red * 255;
    NSInteger green = self.cigam_green * 255;
    NSInteger blue = self.cigam_blue * 255;
    return [[NSString stringWithFormat:@"#%@%@%@%@",
            [self alignColorHexStringLength:[NSString cigam_hexStringWithInteger:alpha]],
            [self alignColorHexStringLength:[NSString cigam_hexStringWithInteger:red]],
            [self alignColorHexStringLength:[NSString cigam_hexStringWithInteger:green]],
            [self alignColorHexStringLength:[NSString cigam_hexStringWithInteger:blue]]] lowercaseString];
}

+ (UIColor *)cigam_colorWithRGBAString:(NSString *)rgbaString {
    NSArray<NSString *> *arr = nil;
    NSCharacterSet *characterSet = nil;
    if ([rgbaString containsString:@","]) {
        characterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
    } else {
        characterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    }
    arr = [[rgbaString componentsSeparatedByCharactersInSet:characterSet] cigam_filterWithBlock:^BOOL(NSString * _Nonnull item) {
        return item.cigam_trim.length > 0;
    }];
    if (arr.count < 3 || arr.count > 4) return nil;
    return UIColorMakeWithRGBA(arr[0].integerValue, arr[1].integerValue, arr[2].integerValue, (arr.count == 4 ? arr[3].floatValue : 1.0));
}

- (NSString *)cigam_RGBAString {
    return [NSString stringWithFormat:@"%.0f,%.0f,%.0f,%.2f",
            round(self.cigam_red * 255),
            round(self.cigam_green * 255),
            round(self.cigam_blue * 255),
            self.cigam_alpha];
}

// 对于色值只有单位数的，在前面补一个0，例如“F”会补齐为“0F”
- (NSString *)alignColorHexStringLength:(NSString *)hexString {
    return hexString.length < 2 ? [@"0" stringByAppendingString:hexString] : hexString;
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (CGFloat)cigam_red {
    CGFloat r;
    if ([self getRed:&r green:0 blue:0 alpha:0]) {
        return r;
    }
    return 0;
}

- (CGFloat)cigam_green {
    CGFloat g;
    if ([self getRed:0 green:&g blue:0 alpha:0]) {
        return g;
    }
    return 0;
}

- (CGFloat)cigam_blue {
    CGFloat b;
    if ([self getRed:0 green:0 blue:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (CGFloat)cigam_alpha {
    CGFloat a;
    if ([self getRed:0 green:0 blue:0 alpha:&a]) {
        return a;
    }
    return 0;
}

- (CGFloat)cigam_hue {
    CGFloat h;
    if ([self getHue:&h saturation:0 brightness:0 alpha:0]) {
        return h;
    }
    return 0;
}

- (CGFloat)cigam_saturation {
    CGFloat s;
    if ([self getHue:0 saturation:&s brightness:0 alpha:0]) {
        return s;
    }
    return 0;
}

- (CGFloat)cigam_brightness {
    CGFloat b;
    if ([self getHue:0 saturation:0 brightness:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (UIColor *)cigam_colorWithoutAlpha {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    if ([self getRed:&r green:&g blue:&b alpha:0]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    } else {
        return nil;
    }
}

- (UIColor *)cigam_colorWithAlpha:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor {
    return [UIColor cigam_colorWithBackendColor:backgroundColor frontColor:[self colorWithAlphaComponent:alpha]];
    
}

- (UIColor *)cigam_colorWithAlphaAddedToWhite:(CGFloat)alpha {
    return [self cigam_colorWithAlpha:alpha backgroundColor:UIColorWhite];
}

- (UIColor *)cigam_transitionToColor:(UIColor *)toColor progress:(CGFloat)progress {
    return [UIColor cigam_colorFromColor:self toColor:toColor progress:progress];
}

- (BOOL)cigam_colorIsDark {
    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:0]) {
        float referenceValue = 0.411;
        float colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
        
        return 1.0 - colorDelta > referenceValue;
    }
    return YES;
}

- (UIColor *)cigam_inverseColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}

- (BOOL)cigam_isSystemTintColor {
    return [self isEqual:[UIColor cigam_systemTintColor]];
}

- (CGFloat)cigam_distanceBetweenColor:(UIColor *)color {
    if (!color) return CGFLOAT_MAX;
    
    UIColor *color1 = self;
    UIColor *color2 = color;
    CGFloat R = 100.0;
    CGFloat angle = 30.0;
    CGFloat h = R * cos(angle / 180 * M_PI);
    CGFloat r = R * sin(angle / 180 * M_PI);
    
    CGFloat hue1 = color1.cigam_hue * 360;
    CGFloat saturation1 = color1.cigam_saturation;
    CGFloat brightness1 = color1.cigam_brightness;
    CGFloat hue2 = color2.cigam_hue * 360;
    CGFloat saturation2 = color2.cigam_saturation;
    CGFloat brightness2 = color2.cigam_brightness;
    
    CGFloat x1 = r * brightness1 * saturation1 * cos(hue1 / 180 * M_PI);
    CGFloat y1 = r * brightness1 * saturation1 * sin(hue1 / 180 * M_PI);
    CGFloat z1 = h * (1 - brightness1);
    CGFloat x2 = r * brightness2 * saturation2 * cos(hue2 / 180 * M_PI);
    CGFloat y2 = r * brightness2 * saturation2 * sin(hue2 / 180 * M_PI);
    CGFloat z2 = h * (1 - brightness2);
    CGFloat dx = x1 - x2;
    CGFloat dy = y1 - y2;
    CGFloat dz = z1 - z2;
    return sqrt(dx * dx + dy * dy + dz * dz);
}

+ (UIColor *)cigam_systemTintColor {
    static UIColor *systemTintColor = nil;
    if (!systemTintColor) {
        UIView *view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    }
    return systemTintColor;
}

+ (UIColor *)cigam_colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor {
    CGFloat bgAlpha = [backendColor cigam_alpha];
    CGFloat bgRed = [backendColor cigam_red];
    CGFloat bgGreen = [backendColor cigam_green];
    CGFloat bgBlue = [backendColor cigam_blue];
    
    CGFloat frAlpha = [frontColor cigam_alpha];
    CGFloat frRed = [frontColor cigam_red];
    CGFloat frGreen = [frontColor cigam_green];
    CGFloat frBlue = [frontColor cigam_blue];
    
    CGFloat resultAlpha = frAlpha + bgAlpha * (1 - frAlpha);
    CGFloat resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha;
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

+ (UIColor *)cigam_colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress {
    progress = MIN(progress, 1.0f);
    CGFloat fromRed = fromColor.cigam_red;
    CGFloat fromGreen = fromColor.cigam_green;
    CGFloat fromBlue = fromColor.cigam_blue;
    CGFloat fromAlpha = fromColor.cigam_alpha;
    
    CGFloat toRed = toColor.cigam_red;
    CGFloat toGreen = toColor.cigam_green;
    CGFloat toBlue = toColor.cigam_blue;
    CGFloat toAlpha = toColor.cigam_alpha;
    
    CGFloat finalRed = fromRed + (toRed - fromRed) * progress;
    CGFloat finalGreen = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat finalBlue = fromBlue + (toBlue - fromBlue) * progress;
    CGFloat finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress;
    
    return [UIColor colorWithRed:finalRed green:finalGreen blue:finalBlue alpha:finalAlpha];
}

+ (UIColor *)cigam_randomColor {
    CGFloat red = ( arc4random() % 255 / 255.0 );
    CGFloat green = ( arc4random() % 255 / 255.0 );
    CGFloat blue = ( arc4random() % 255 / 255.0 );
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end


NSString *const CIGAMCGColorOriginalColorBindKey = @"CIGAMCGColorOriginalColorBindKey";

@implementation UIColor (CIGAM_DynamicColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfNonVoidMethodWithoutArguments([UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
                return [UIColor clearColor];
            }].class, @selector(CGColor), CGColorRef, ^CGColorRef(UIColor *selfObject, CGColorRef originReturnValue) {
                if (selfObject.cigam_isDynamicColor) {
                    UIColor *color = [UIColor colorWithCGColor:originReturnValue];
                    originReturnValue = color.CGColor;
                    [(__bridge id)(originReturnValue) cigam_bindObject:selfObject forKey:CIGAMCGColorOriginalColorBindKey];
                }
                return originReturnValue;
            });
        }
    });
}

- (BOOL)cigam_isDynamicColor {
    if ([self respondsToSelector:@selector(_isDynamic)]) {
        return self._isDynamic;
    }
    return NO;
}

- (BOOL)cigam_isCIGAMDynamicColor {
    return NO;
}

- (UIColor *)cigam_rawColor {
    if (self.cigam_isDynamicColor) {
        if (@available(iOS 13.0, *)) {
            if ([self respondsToSelector:@selector(resolvedColorWithTraitCollection:)]) {
                UIColor *color = [self resolvedColorWithTraitCollection:UITraitCollection.currentTraitCollection];
                return color.cigam_rawColor;
            }
        }
    }
    return self;
}

@end
