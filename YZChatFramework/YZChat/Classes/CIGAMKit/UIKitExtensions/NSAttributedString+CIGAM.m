/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSAttributedString+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 16/9/23.
//

#import "NSAttributedString+CIGAM.h"
#import "CIGAMCore.h"
#import "NSString+CIGAM.h"

@implementation NSAttributedString (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        OverrideImplementation([[[NSAttributedString alloc] initWithString:@""] class], @selector(initWithString:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSAttributedString *(NSAttributedString *selfObject, NSString *str) {
                
                str = str ?: @"";
                
                // call super
                NSAttributedString *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (NSAttributedString * (*)(id, SEL, NSString *))originalIMPProvider();
                NSAttributedString * result = originSelectorIMP(selfObject, originCMD, str);
                
                return result;
            };
        });
        
        OverrideImplementation([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSAttributedString *(NSAttributedString *selfObject, NSString *str, NSDictionary<NSString *,id> *attrs) {
                str = str ?: @"";
                
                // call super
                NSAttributedString *(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *,id> *);
                originSelectorIMP = (NSAttributedString *(*)(id, SEL, NSString *, NSDictionary<NSString *,id> *))originalIMPProvider();
                NSAttributedString *result = originSelectorIMP(selfObject, originCMD, str, attrs);
                
                return result;
            };
        });
    });
}

- (NSUInteger)cigam_lengthWhenCountingNonASCIICharacterAsTwo {
    return self.string.cigam_lengthWhenCountingNonASCIICharacterAsTwo;
}

+ (instancetype)cigam_attributedStringWithImage:(UIImage *)image {
    return [self cigam_attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+ (instancetype)cigam_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self cigam_attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self cigam_attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
}

+ (instancetype)cigam_attributedStringWithFixedSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self cigam_attributedStringWithImage:image];
}

@end

@implementation NSMutableAttributedString (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        OverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@""] class], @selector(initWithString:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSMutableAttributedString *(NSMutableAttributedString *selfObject, NSString *str) {
                
                str = str ?: @"";
                
                // call super
                NSMutableAttributedString *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (NSMutableAttributedString *(*)(id, SEL, NSString *))originalIMPProvider();
                NSMutableAttributedString *result = originSelectorIMP(selfObject, originCMD, str);
                
                return result;
            };
        });
        
        OverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSMutableAttributedString *(NSMutableAttributedString *selfObject, NSString *str, NSDictionary<NSString *,id> *attrs) {
                str = str ?: @"";
                
                // call super
                NSMutableAttributedString *(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *,id> *);
                originSelectorIMP = (NSMutableAttributedString *(*)(id, SEL, NSString *, NSDictionary<NSString *,id> *))originalIMPProvider();
                NSMutableAttributedString *result = originSelectorIMP(selfObject, originCMD, str, attrs);
                
                return result;
            };
        });
    });
}

@end
