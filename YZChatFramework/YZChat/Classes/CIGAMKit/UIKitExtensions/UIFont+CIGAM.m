/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIFont+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 15/7/20.
//

#import "UIFont+CIGAM.h"
#import "CIGAMCore.h"

@implementation UIFont (CIGAM)

+ (UIFont *)cigam_lightSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
}

+ (UIFont *)cigam_systemFontOfSize:(CGFloat)size weight:(CIGAMFontWeight)weight italic:(BOOL)italic {
    UIFont *font = nil;
    font = [UIFont systemFontOfSize:size weight:weight == CIGAMFontWeightLight ? UIFontWeightLight : (weight == CIGAMFontWeightBold ? UIFontWeightSemibold : UIFontWeightRegular)];
    if (!italic) {
        return font;
    }
    
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits trait = fontDescriptor.symbolicTraits;
    trait |= UIFontDescriptorTraitItalic;
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:trait];
    font = [UIFont fontWithDescriptor:fontDescriptor size:0];
    return font;
}

+ (UIFont *)cigam_dynamicSystemFontOfSize:(CGFloat)size weight:(CIGAMFontWeight)weight italic:(BOOL)italic {
    return [self cigam_dynamicSystemFontOfSize:size upperLimitSize:size + 5 lowerLimitSize:0 weight:weight italic:italic];
}

+ (UIFont *)cigam_dynamicSystemFontOfSize:(CGFloat)pointSize
                          upperLimitSize:(CGFloat)upperLimitSize
                          lowerLimitSize:(CGFloat)lowerLimitSize
                                  weight:(CIGAMFontWeight)weight
                                  italic:(BOOL)italic {
    
    // 计算出 body 类型比默认的大小要变化了多少，然后在 pointSize 的基础上叠加这个变化
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat offsetPointSize = font.pointSize - 17;// default UIFontTextStyleBody fontSize is 17
    CGFloat finalPointSize = pointSize + offsetPointSize;
    finalPointSize = MAX(MIN(finalPointSize, upperLimitSize), lowerLimitSize);
    font = [UIFont cigam_systemFontOfSize:finalPointSize weight:weight italic:NO];
    
    return font;
}

@end
