/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMTableViewHeaderFooterView.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2017/12/7.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CIGAMTableViewHeaderFooterViewType) {
    CIGAMTableViewHeaderFooterViewTypeUnknow,
    CIGAMTableViewHeaderFooterViewTypeHeader,
    CIGAMTableViewHeaderFooterViewTypeFooter
};

/**
 *  适用于 UITableView 的 sectionHeaderFooterView，提供的特性包括：
 *  1. 支持单个 UILabel，该 label 支持多行文字。
 *  2. 支持右边添加一个 accessoryView（注意，设置 accessoryView 之前请先保证自身大小正确）。
 *  3. 支持调整 headerFooterView 的 padding。
 *  4. 支持应用配置表的样式。
 *
 *  使用方式：
 *  基本与系统的 UITableViewHeaderFooterView 使用方式一致，额外需要做的事情有：
 *  1. 如果要支持高度自动根据内容变化，则按系统的 self-sizing 方式，用 UITableViewAutomaticDimension 指定。或者重写 tableView:heightForHeaderInSection:、tableView:heightForFooterInSection:，在里面调用 headerFooterView 的 sizeThatFits:。
 *  2. 如果要应用配置表样式，则设置 parentTableView 和 type 这两个属性即可。特别的，CIGAMCommonTableViewController 里默认已经处理好 parentTableView 和 type，子类无需操作。
 */
@interface CIGAMTableViewHeaderFooterView : UITableViewHeaderFooterView

@property(nonatomic, weak) UITableView *parentTableView;
@property(nonatomic, assign) CIGAMTableViewHeaderFooterViewType type;

@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong) UIView *accessoryView;

@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets accessoryViewMargins;
@end

@interface CIGAMTableViewHeaderFooterView (UISubclassingHooks)

/// 子类重写，用于修改样式，会在 parentTableView、type 属性发生变化的时候被调用
- (void)updateAppearance;

@end
