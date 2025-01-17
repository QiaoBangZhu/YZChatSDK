/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITextField+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 2017/3/29.
//

#import "UITextField+CIGAM.h"
#import "NSObject+CIGAM.h"
#import "CIGAMCore.h"
#import "UIImage+CIGAM.h"

@implementation UITextField (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 12 及以下版本需要重写该方法才能替换
        if (@available(iOS 13.0, *)) {
        } else {
            OverrideImplementation([UITextField class], NSSelectorFromString(@"_clearButtonImageForState:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UITextField *selfObject, UIControlState firstArgv) {
                    
                    if (selfObject.cigam_clearButtonImage) {
                        if (firstArgv & UIControlStateHighlighted) {
                            return [selfObject.cigam_clearButtonImage cigam_imageWithAlpha:UIControlHighlightedAlpha];
                        }
                        return selfObject.cigam_clearButtonImage;
                    }
                    
                    // call super
                    UIImage *(*originSelectorIMP)(id, SEL, UIControlState);
                    originSelectorIMP = (UIImage *(*)(id, SEL, UIControlState))originalIMPProvider();
                    UIImage *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    return result;
                };
            });
        }
    });
}

- (NSRange)cigam_selectedRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

- (UIButton *)cigam_clearButton {
    return [self cigam_valueForKey:@"clearButton"];
}

// - (id) _clearButtonImageForState:(unsigned long)arg1;
static char kAssociatedObjectKey_clearButtonImage;
- (void)setCigam_clearButtonImage:(UIImage *)cigam_clearButtonImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage, cigam_clearButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.cigam_clearButton setImage:cigam_clearButtonImage forState:UIControlStateNormal];
    // 如果当前 clearButton 正在显示的时候把自定义图片去掉，需要重新 layout 一次才能让系统默认图片显示出来
    if (!cigam_clearButtonImage) {
        [self setNeedsLayout];
    }
}

- (UIImage *)cigam_clearButtonImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage);
}

- (NSRange)cigam_convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (UITextRange *)cigam_convertUITextRangeFromNSRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) > self.text.length) {
        return nil;
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    return [self textRangeFromPosition:startPosition toPosition:endPosition];
}

@end
