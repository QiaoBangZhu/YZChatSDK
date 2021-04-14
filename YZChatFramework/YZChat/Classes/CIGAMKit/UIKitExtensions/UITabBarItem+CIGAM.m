/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITabBarItem+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 15/7/20.
//

#import "UITabBarItem+CIGAM.h"
#import "CIGAMCore.h"
#import "UIBarItem+CIGAM.h"

@implementation UITabBarItem (CIGAM)

CIGAMSynthesizeIdCopyProperty(cigam_doubleTapBlock, setCigam_doubleTapBlock)

- (UIImageView *)cigam_imageView {
    return [self.class cigam_imageViewInTabBarButton:self.cigam_view];
}

+ (UIImageView *)cigam_imageViewInTabBarButton:(UIView *)tabBarButton {
    
    if (!tabBarButton) {
        return nil;
    }
    if (@available(iOS 13.0, *)) {
        return [tabBarButton cigam_valueForKey:@"_imageView"];
    }
    return [tabBarButton cigam_valueForKey:@"_info"];
}

@end
