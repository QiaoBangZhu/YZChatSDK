/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CIGAMThemePrivate.h
//  CIGAMKit
//
//  Created by MoLice on 2019/J/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+CIGAM.h"
#import "UIImage+CIGAMTheme.h"
#import "UIVisualEffect+CIGAMTheme.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CIGAMTheme_Private)

// 某些 view class 在遇到 cigam_registerThemeColorProperties: 无法满足 theme 变化时的刷新需求时，可以重写这个方法来做自己的逻辑
- (void)_cigam_themeDidChangeByManager:(nullable CIGAMThemeManager *)manager identifier:(nullable __kindof NSObject<NSCopying> *)identifier theme:(nullable __kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews;

/// 记录当前 view 总共有哪些 property 需要在 theme 变化时重新设置
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *cigamTheme_themeColorProperties;

- (BOOL)_cigam_visible;

@end

/// @warning 由于支持 NSCopying，增加属性时必须在 copyWithZone: 里复制一次
@interface CIGAMThemeColor : UIColor <CIGAMDynamicColorProtocol>

@property(nonatomic, copy) NSObject<NSCopying> *managerName;
@property(nonatomic, copy) UIColor *(^themeProvider)(__kindof CIGAMThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end

@interface CIGAMThemeImage : UIImage <CIGAMDynamicImageProtocol, NSCopying>

@property(nonatomic, copy) NSObject<NSCopying> *managerName;
@property(nonatomic, copy) UIImage *(^themeProvider)(__kindof CIGAMThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end

/// @warning 由于支持 NSCopying，增加属性时必须在 copyWithZone: 里复制一次
@interface CIGAMThemeVisualEffect : NSObject <CIGAMDynamicEffectProtocol>

@property(nonatomic, copy) NSObject<NSCopying> *managerName;
@property(nonatomic, copy) __kindof UIVisualEffect *(^themeProvider)(__kindof CIGAMThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end

NS_ASSUME_NONNULL_END
