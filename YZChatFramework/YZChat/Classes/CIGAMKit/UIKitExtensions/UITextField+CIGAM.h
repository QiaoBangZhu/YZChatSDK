/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITextField+CIGAM.h
//  cigam
//
//  Created by CIGAM Team on 2017/3/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (CIGAM)

/// UITextField只有selectedTextRange属性（在<UITextInput>协议里定义），这里拓展了一个方法可以将UITextRange类型的selectedTextRange转换为NSRange类型的selectedRange
@property(nonatomic, assign, readonly) NSRange cigam_selectedRange;

/// 输入框右边的 clearButton，在 UITextField 初始化后就存在
@property(nullable, nonatomic, weak, readonly) UIButton *cigam_clearButton;

/// 自定义 clearButton 的图片，设置成nil，恢复到系统默认的图片
@property(nullable, nonatomic, strong) UIImage *cigam_clearButtonImage UI_APPEARANCE_SELECTOR;

/**
 *  convert UITextRange to NSRange, for example, [self cigam_convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)cigam_convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  convert NSRange to UITextRange
 *  @return return nil if range is invalidate.
 */
- (nullable UITextRange *)cigam_convertUITextRangeFromNSRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
