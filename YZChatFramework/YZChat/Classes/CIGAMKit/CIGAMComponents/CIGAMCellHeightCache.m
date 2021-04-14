/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMCellHeightCache.m
//  cigam
//
//  Created by CIGAM Team on 15/12/23.
//

#import "CIGAMCellHeightCache.h"
#import "CIGAMTableViewProtocols.h"
#import "CIGAMCore.h"
#import "UIScrollView+CIGAM.h"
#import "UITableView+CIGAM.h"
#import "UIView+CIGAM.h"
#import "NSNumber+CIGAM.h"

const CGFloat kCIGAMCellHeightInvalidCache = -1;

@interface CIGAMCellHeightCache ()

@property(nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *cachedHeights;
@end

@implementation CIGAMCellHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachedHeights = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.cachedHeights[key];
    return number && ![number isEqualToNumber:@(kCIGAMCellHeightInvalidCache)];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    self.cachedHeights[key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key {
    return self.cachedHeights[key].cigam_CGFloatValue;
}

- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [self.cachedHeights removeObjectForKey:key];
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights removeAllObjects];
}

@end

@interface CIGAMCellHeightIndexPathCache ()

@property(nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *cachedHeights;
@end

@implementation CIGAMCellHeightIndexPathCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyInvalidateEnabled = YES;
        self.cachedHeights = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.cachedHeights[indexPath.section][indexPath.row];
    return number && ![number isEqualToNumber:@(kCIGAMCellHeightInvalidCache)];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.cachedHeights[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    return self.cachedHeights[indexPath.section][indexPath.row].cigam_CGFloatValue;
}

- (void)invalidateHeightInSection:(NSInteger)section {
    [self buildSectionsIfNeeded:section];
    [self.cachedHeights[section] removeAllObjects];
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.cachedHeights[indexPath.section][indexPath.row] = @(kCIGAMCellHeightInvalidCache);
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights enumerateObjectsUsingBlock:^(NSMutableArray<NSNumber *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    for (NSInteger section = 0; section <= targetSection; ++section) {
        if (section >= self.cachedHeights.count) {
            [self.cachedHeights addObject:[[NSMutableArray alloc] init]];
        }
    }
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    NSMutableArray<NSNumber *> *heightsInSection = self.cachedHeights[section];
    for (NSInteger row = 0; row <= targetRow; ++row) {
        if (row >= heightsInSection.count) {
            [heightsInSection addObject:@(kCIGAMCellHeightInvalidCache)];
        }
    }
}

@end

#pragma mark - UITableView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@interface UITableView ()

/// key 为 tableView 的内容宽度，value 为该宽度下对应的缓存容器，从而保证 tableView 宽度变化时缓存也会跟着刷新
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, CIGAMCellHeightCache *> *cigamTableCache_allKeyedHeightCaches;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, CIGAMCellHeightIndexPathCache *> *cigamTableCache_allIndexPathHeightCaches;
@end

@implementation UITableView (CIGAMKeyedHeightCache)

CIGAMSynthesizeIdStrongProperty(cigamTableCache_allKeyedHeightCaches, setCigamTableCache_allKeyedHeightCaches)

- (CIGAMCellHeightCache *)cigam_keyedHeightCache {
    if (!self.cigamTableCache_allKeyedHeightCaches) {
        self.cigamTableCache_allKeyedHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGFloat contentWidth = self.cigam_validContentWidth;
    CIGAMCellHeightCache *cache = self.cigamTableCache_allKeyedHeightCaches[@(contentWidth)];
    if (!cache) {
        cache = [[CIGAMCellHeightCache alloc] init];
        self.cigamTableCache_allKeyedHeightCaches[@(contentWidth)] = cache;
    }
    return cache;
}

- (void)cigam_invalidateHeightForKey:(id<NSCopying>)aKey {
    [self.cigamTableCache_allKeyedHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:aKey];
    }];
}

@end

@implementation UITableView (CIGAMCellHeightIndexPathCache)

CIGAMSynthesizeIdStrongProperty(cigamTableCache_allIndexPathHeightCaches, setCigamTableCache_allIndexPathHeightCaches)
CIGAMSynthesizeBOOLProperty(cigam_invalidateIndexPathHeightCachedAutomatically, setCigam_invalidateIndexPathHeightCachedAutomatically)

- (CIGAMCellHeightIndexPathCache *)cigam_indexPathHeightCache {
    if (!self.cigamTableCache_allIndexPathHeightCaches) {
        self.cigamTableCache_allIndexPathHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGFloat contentWidth = self.cigam_validContentWidth;
    CIGAMCellHeightIndexPathCache *cache = self.cigamTableCache_allIndexPathHeightCaches[@(contentWidth)];
    if (!cache) {
        cache = [[CIGAMCellHeightIndexPathCache alloc] init];
        self.cigamTableCache_allIndexPathHeightCaches[@(contentWidth)] = cache;
    }
    return cache;
}

- (void)cigam_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightAtIndexPath:indexPath];
    }];
}

@end

@implementation UITableView (CIGAMIndexPathHeightCacheInvalidation)

- (void)cigam_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self cigamTableCache_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:style:),
            @selector(initWithCoder:),
            @selector(reloadData),
            @selector(insertSections:withRowAnimation:),
            @selector(deleteSections:withRowAnimation:),
            @selector(reloadSections:withRowAnimation:),
            @selector(moveSection:toSection:),
            @selector(insertRowsAtIndexPaths:withRowAnimation:),
            @selector(deleteRowsAtIndexPaths:withRowAnimation:),
            @selector(reloadRowsAtIndexPaths:withRowAnimation:),
            @selector(moveRowAtIndexPath:toIndexPath:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"cigamTableCache_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)cigamTableCache_initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    [self cigamTableCache_initWithFrame:frame style:style];
    [self cigamTableCache_didInitialize];
    return self;
}

- (instancetype)cigamTableCache_initWithCoder:(NSCoder *)aDecoder {
    [self cigamTableCache_initWithCoder:aDecoder];
    [self cigamTableCache_didInitialize];
    return self;
}

- (void)cigamTableCache_didInitialize {
    self.cigam_invalidateIndexPathHeightCachedAutomatically = YES;
}

- (void)cigamTableCache_reloadData {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamTableCache_allIndexPathHeightCaches removeAllObjects];
    }
    [self cigamTableCache_reloadData];
}

- (void)cigamTableCache_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights insertObject:[[NSMutableArray alloc] init] atIndex:section];
            }];
        }];
    }
    [self cigamTableCache_insertSections:sections withRowAnimation:animation];
}

- (void)cigamTableCache_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights removeObjectAtIndex:section];
            }];
        }];
    }
    [self cigamTableCache_deleteSections:sections withRowAnimation:animation];
}

- (void)cigamTableCache_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj invalidateHeightInSection:section];
            }];
        }];
    }
    [self cigamTableCache_reloadSections:sections withRowAnimation:animation];
}

- (void)cigamTableCache_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildSectionsIfNeeded:section];
            [obj buildSectionsIfNeeded:newSection];
            [obj.cachedHeights exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self cigamTableCache_moveSection:section toSection:newSection];
}

- (void)cigamTableCache_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                [heightsInSection insertObject:@(kCIGAMCellHeightInvalidCache) atIndex:indexPath.row];
            }];
        }];
    }
    [self cigamTableCache_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)cigamTableCache_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
                if (!mutableIndexSet) {
                    mutableIndexSet = [NSMutableIndexSet indexSet];
                    mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
                }
                [mutableIndexSet addIndex:indexPath.row];
            }];
            [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *aKey, NSIndexSet *indexSet, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[aKey.integerValue];
                [heightsInSection removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self cigamTableCache_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)cigamTableCache_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                heightsInSection[indexPath.row] = @(kCIGAMCellHeightInvalidCache);
            }];
        }];
    }
    [self cigamTableCache_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)cigamTableCache_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
            if (obj.cachedHeights.count > 0 && obj.cachedHeights.count > sourceIndexPath.section && obj.cachedHeights.count > destinationIndexPath.section) {
                NSMutableArray<NSNumber *> *sourceHeightsInSection = obj.cachedHeights[sourceIndexPath.section];
                NSMutableArray<NSNumber *> *destinationHeightsInSection = obj.cachedHeights[destinationIndexPath.section];
                NSNumber *sourceHeight = sourceHeightsInSection[sourceIndexPath.row];
                NSNumber *destinationHeight = destinationHeightsInSection[destinationIndexPath.row];
                sourceHeightsInSection[sourceIndexPath.row] = destinationHeight;
                destinationHeightsInSection[destinationIndexPath.row] = sourceHeight;
            }
        }];
    }
    [self cigamTableCache_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UITableView (CIGAMLayoutCell)

- (__kindof UITableViewCell *)templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        // 是否有通过dataSource返回的cell
        if ([self.dataSource respondsToSelector:@selector(cigam_tableView:cellWithIdentifier:)] ) {
            id <CIGAMCellHeightCache_UITableViewDataSource>dataSource = (id<CIGAMCellHeightCache_UITableViewDataSource>)self.dataSource;
            templateCell = [dataSource cigam_tableView:self cellWithIdentifier:identifier];
        }
        // 没有的话，则需要通过register来注册一个cell，否则会crash
        if (!templateCell) {
            templateCell = [self dequeueReusableCellWithIdentifier:identifier];
            NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        }
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    return templateCell;
}

- (CGFloat)cigam_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(__kindof UITableViewCell *))configuration {
    CGFloat contentWidth = self.cigam_validContentWidth;
    if (!identifier || contentWidth <= 0) {
        return 0;
    }
    UITableViewCell *cell = [self templateCellForReuseIdentifier:identifier];
    [cell prepareForReuse];
    if (configuration) configuration(cell);
    CGSize fitSize = CGSizeZero;
    if (cell && contentWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    }
    return flat(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)cigam_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !indexPath || self.cigam_validContentWidth <= 0) {
        return 0;
    }
    if ([self.cigam_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.cigam_indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self cigam_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.cigam_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)cigam_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !key || self.cigam_validContentWidth <= 0) {
        return 0;
    }
    if ([self.cigam_keyedHeightCache existsHeightForKey:key]) {
        return [self.cigam_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self cigam_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.cigam_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

- (void)cigam_invalidateAllHeight {
    [self.cigamTableCache_allKeyedHeightCaches removeAllObjects];
    [self.cigamTableCache_allIndexPathHeightCaches removeAllObjects];
}

@end

#pragma mark - UICollectionView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@interface UICollectionView ()

/// key 为 UICollectionView 的内容大小（包裹着 CGSize），value 为该大小下对应的缓存容器，从而保证 UICollectionView 大小变化时缓存也会跟着刷新
@property(nonatomic, strong) NSMutableDictionary<NSValue *, CIGAMCellHeightCache *> *cigamCollectionCache_allKeyedHeightCaches;
@property(nonatomic, strong) NSMutableDictionary<NSValue *, CIGAMCellHeightIndexPathCache *> *cigamCollectionCache_allIndexPathHeightCaches;
@end

@implementation UICollectionView (CIGAMKeyedHeightCache)

CIGAMSynthesizeIdStrongProperty(cigamCollectionCache_allKeyedHeightCaches, setCigamCollectionCache_allKeyedHeightCaches)

- (CIGAMCellHeightCache *)cigam_keyedHeightCache {
    if (!self.cigamCollectionCache_allKeyedHeightCaches) {
        self.cigamCollectionCache_allKeyedHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGSize collectionViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.cigam_safeAreaInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.cigam_safeAreaInsets));
    CIGAMCellHeightCache *cache = self.cigamCollectionCache_allKeyedHeightCaches[[NSValue valueWithCGSize:collectionViewSize]];
    if (!cache) {
        cache = [[CIGAMCellHeightCache alloc] init];
        self.cigamCollectionCache_allKeyedHeightCaches[[NSValue valueWithCGSize:collectionViewSize]] = cache;
    }
    return cache;
}

- (void)cigam_invalidateHeightForKey:(id<NSCopying>)aKey {
    [self.cigamCollectionCache_allKeyedHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:aKey];
    }];
}

@end

@implementation UICollectionView (CIGAMCellHeightIndexPathCache)

CIGAMSynthesizeBOOLProperty(cigam_invalidateIndexPathHeightCachedAutomatically, setCigam_invalidateIndexPathHeightCachedAutomatically)
CIGAMSynthesizeIdStrongProperty(cigamCollectionCache_allIndexPathHeightCaches, setCigamCollectionCache_allIndexPathHeightCaches)

- (CIGAMCellHeightIndexPathCache *)cigam_indexPathHeightCache {
    if (!self.cigamCollectionCache_allIndexPathHeightCaches) {
        self.cigamCollectionCache_allIndexPathHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGSize collectionViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.cigam_safeAreaInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.cigam_safeAreaInsets));
    CIGAMCellHeightIndexPathCache *cache = self.cigamCollectionCache_allIndexPathHeightCaches[[NSValue valueWithCGSize:collectionViewSize]];
    if (!cache) {
        cache = [[CIGAMCellHeightIndexPathCache alloc] init];
        self.cigamCollectionCache_allIndexPathHeightCaches[[NSValue valueWithCGSize:collectionViewSize]] = cache;
    }
    return cache;
}

- (void)cigam_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightAtIndexPath:indexPath];
    }];
}

@end

@implementation UICollectionView (CIGAMIndexPathHeightCacheInvalidation)

- (void)cigam_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self cigamCollectionCache_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:collectionViewLayout:),
            @selector(initWithCoder:),
            @selector(reloadData),
            @selector(insertSections:),
            @selector(deleteSections:),
            @selector(reloadSections:),
            @selector(moveSection:toSection:),
            @selector(insertItemsAtIndexPaths:),
            @selector(deleteItemsAtIndexPaths:),
            @selector(reloadItemsAtIndexPaths:),
            @selector(moveItemAtIndexPath:toIndexPath:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"cigamCollectionCache_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)cigamCollectionCache_initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    [self cigamCollectionCache_initWithFrame:frame collectionViewLayout:layout];
    [self cigamCollectionCache_didInitialize];
    return self;
}

- (instancetype)cigamCollectionCache_initWithCoder:(NSCoder *)aDecoder {
    [self cigamCollectionCache_initWithCoder:aDecoder];
    [self cigamCollectionCache_didInitialize];
    return self;
}

- (void)cigamCollectionCache_didInitialize {
    self.cigam_invalidateIndexPathHeightCachedAutomatically = YES;
}

- (void)cigamCollectionCache_reloadData {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches removeAllObjects];
    }
    [self cigamCollectionCache_reloadData];
}

- (void)cigamCollectionCache_insertSections:(NSIndexSet *)sections {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights insertObject:[[NSMutableArray alloc] init] atIndex:section];
            }];
        }];
    }
    [self cigamCollectionCache_insertSections:sections];
}

- (void)cigamCollectionCache_deleteSections:(NSIndexSet *)sections {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights removeObjectAtIndex:section];
            }];
        }];
    }
    [self cigamCollectionCache_deleteSections:sections];
}

- (void)cigamCollectionCache_reloadSections:(NSIndexSet *)sections {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights[section] removeAllObjects];
            }];
        }];
    }
    [self cigamCollectionCache_reloadSections:sections];
}

- (void)cigamCollectionCache_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildSectionsIfNeeded:section];
            [obj buildSectionsIfNeeded:newSection];
            [obj.cachedHeights exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self cigamCollectionCache_moveSection:section toSection:newSection];
}

- (void)cigamCollectionCache_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                [heightsInSection insertObject:@(kCIGAMCellHeightInvalidCache) atIndex:indexPath.item];
            }];
        }];
    }
    [self cigamCollectionCache_insertItemsAtIndexPaths:indexPaths];
}

- (void)cigamCollectionCache_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
                if (!mutableIndexSet) {
                    mutableIndexSet = [NSMutableIndexSet indexSet];
                    mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
                }
                [mutableIndexSet addIndex:indexPath.item];
            }];
            [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *aKey, NSIndexSet *indexSet, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[aKey.integerValue];
                [heightsInSection removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self cigamCollectionCache_deleteItemsAtIndexPaths:indexPaths];
}

- (void)cigamCollectionCache_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                heightsInSection[indexPath.item] = @(kCIGAMCellHeightInvalidCache);
            }];
        }];
    }
    [self cigamCollectionCache_reloadItemsAtIndexPaths:indexPaths];
}

- (void)cigamCollectionCache_moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.cigam_invalidateIndexPathHeightCachedAutomatically) {
        [self.cigamCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, CIGAMCellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
            if (obj.cachedHeights.count > 0 && obj.cachedHeights.count > sourceIndexPath.section && obj.cachedHeights.count > destinationIndexPath.section) {
                NSMutableArray<NSNumber *> *sourceHeightsInSection = obj.cachedHeights[sourceIndexPath.section];
                NSMutableArray<NSNumber *> *destinationHeightsInSection = obj.cachedHeights[destinationIndexPath.section];
                NSNumber *sourceHeight = sourceHeightsInSection[sourceIndexPath.item];
                NSNumber *destinationHeight = destinationHeightsInSection[destinationIndexPath.item];
                sourceHeightsInSection[sourceIndexPath.item] = destinationHeight;
                destinationHeightsInSection[destinationIndexPath.item] = sourceHeight;
            }
        }];
    }
    [self cigamCollectionCache_moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UICollectionView (CIGAMLayoutCell)

- (__kindof UICollectionViewCell *)templateCellForReuseIdentifier:(NSString *)identifier cellClass:(Class)cellClass {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"only flow layout accept");
    NSAssert([cellClass isSubclassOfClass:[UICollectionViewCell class]], @"must be uicollection view cell");
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UICollectionViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        // CollecionView 跟 TableView 不太一样，无法通过 dequeueReusableCellWithReuseIdentifier:forIndexPath: 来拿到cell（如果这样做，首先indexPath不知道传什么值，其次是这样做会已知crash，说数组越界），所以只能通过传一个class来通过init方法初始化一个cell，但是也有缓存来复用cell。
        // templateCell = [self dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        templateCell = [[cellClass alloc] initWithFrame:CGRectZero];
        NSAssert(templateCell != nil, @"Cell must be registered to collection view for identifier - %@", identifier);
    }
    templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    templateCellsByIdentifiers[identifier] = templateCell;
    return templateCell;
}

- (CGFloat)cigam_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    UICollectionViewCell *cell = [self templateCellForReuseIdentifier:identifier cellClass:cellClass];
    [cell prepareForReuse];
    if (configuration) configuration(cell);
    CGSize fitSize = CGSizeZero;
    if (cell && itemWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(itemWidth, CGFLOAT_MAX)];
    }
    return ceil(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)cigam_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !indexPath || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.cigam_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.cigam_indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self cigam_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.cigam_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)cigam_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !key || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.cigam_keyedHeightCache existsHeightForKey:key]) {
        return [self.cigam_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self cigam_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.cigam_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

- (void)cigam_invalidateAllHeight {
    [self.cigamCollectionCache_allKeyedHeightCaches removeAllObjects];
    [self.cigamCollectionCache_allIndexPathHeightCaches removeAllObjects];
}

@end
