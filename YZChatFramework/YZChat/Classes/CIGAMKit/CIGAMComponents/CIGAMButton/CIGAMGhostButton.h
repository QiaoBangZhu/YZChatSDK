/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMGhostButton.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import "CIGAMButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CIGAMGhostButtonColor) {
    CIGAMGhostButtonColorBlue,
    CIGAMGhostButtonColorRed,
    CIGAMGhostButtonColorGreen,
    CIGAMGhostButtonColorGray,
    CIGAMGhostButtonColorWhite,
};

/**
 *  “幽灵”按钮，也即背景透明、带圆角边框的按钮
 *
 *  可通过 `CIGAMGhostButtonColor` 设置几种预设的颜色，也可以用 `ghostColor` 设置自定义颜色。
 *
 *  圆角自动保持为按钮高度的一半，可通过 CIGAMButton.cornerRadius 属性修改。
 *
 *  @warning 默认情况下，`ghostColor` 只会修改文字和边框的颜色，如果需要让 image 也跟随 `ghostColor` 的颜色，则可将 `adjustsImageWithGhostColor` 设为 `YES`
 */
@interface CIGAMGhostButton : CIGAMButton

@property(nonatomic, strong, nullable) IBInspectable UIColor *ghostColor;    // 默认为 GhostButtonColorBlue
@property(nonatomic, assign) IBInspectable CGFloat borderWidth UI_APPEARANCE_SELECTOR;    // 默认为 1pt

/**
 *  控制按钮里面的图片是否也要跟随 `ghostColor` 一起变化，默认为 `NO`
 */
@property(nonatomic, assign) IBInspectable BOOL adjustsImageWithGhostColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithGhostType:(CIGAMGhostButtonColor)ghostType;
- (instancetype)initWithGhostColor:(nullable UIColor *)ghostColor;

@end

NS_ASSUME_NONNULL_END
