/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMTableViewProtocols.h
//  cigam
//
//  Created by CIGAM Team on 2016/12/9.
//

#import <UIKit/UIKit.h>

@class CIGAMTableView;

@protocol CIGAMCellHeightCache_UITableViewDataSource

@optional
/// 搭配 CIGAMCellHeightCache 使用，对于 UITableView 而言如果要用 CIGAMCellHeightCache 那套高度计算方式，则必须实现这个方法
- (nullable __kindof UITableViewCell *)cigam_tableView:(nullable UITableView *)tableView cellWithIdentifier:(nonnull NSString *)identifier;

@end

@protocol CIGAMCellHeightKeyCache_UITableViewDelegate <NSObject>

@optional

- (nonnull id<NSCopying>)cigam_tableView:(nonnull UITableView *)tableView cacheKeyForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end

@protocol CIGAMTableViewDelegate <UITableViewDelegate, CIGAMCellHeightKeyCache_UITableViewDelegate>

@optional

/**
 * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
 * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
 */
- (BOOL)tableView:(nonnull CIGAMTableView *)tableView touchesShouldCancelInContentView:(nonnull UIView *)view;

@end


@protocol CIGAMTableViewDataSource <UITableViewDataSource, CIGAMCellHeightCache_UITableViewDataSource>

@end
