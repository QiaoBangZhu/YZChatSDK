/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UICollectionView+CIGAMCellSizeKeyCache.h
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/3/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CIGAMCellSizeKeyCache;

@protocol CIGAMCellSizeKeyCache_UICollectionViewDelegate <NSObject>

@optional
- (nonnull id<NSCopying>)cigam_collectionView:(nonnull UICollectionView *)collectionView cacheKeyForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end

/// 注意，这个类的功能暂无法使用
@interface UICollectionView (CIGAMCellSizeKeyCache)

/// 控制是否要自动缓存 cell 的高度，默认为 NO
@property(nonatomic, assign) BOOL cigam_cacheCellSizeByKeyAutomatically;

/// 获取当前的缓存容器。tableView 的宽度和 contentInset 发生变化时，这个数组也会跟着变，但当 tableView 宽度小于 0 时会返回 nil。
@property(nonatomic, weak, readonly, nullable) CIGAMCellSizeKeyCache *cigam_currentCellSizeKeyCache;

@end
