/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UICollectionView+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 15/7/20.
//

#import "UICollectionView+CIGAM.h"
#import "CIGAMCore.h"
#import "CIGAMLog.h"

@implementation UICollectionView (CIGAM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 防止 release 版本滚动到不合法的 indexPath 会 crash
        OverrideImplementation([UICollectionView class], @selector(scrollToItemAtIndexPath:atScrollPosition:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UICollectionView *selfObject, NSIndexPath *indexPath, UICollectionViewScrollPosition scrollPosition, BOOL animated) {
                BOOL isIndexPathLegal = YES;
                NSInteger numberOfSections = [selfObject numberOfSections];
                if (indexPath.section >= numberOfSections) {
                    isIndexPathLegal = NO;
                } else {
                    NSInteger items = [selfObject numberOfItemsInSection:indexPath.section];
                    if (indexPath.item >= items) {
                        isIndexPathLegal = NO;
                    }
                }
                if (!isIndexPathLegal) {
                    CIGAMLogWarn(@"UICollectionView (CIGAM)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", selfObject, indexPath, [NSThread callStackSymbols]);
                    if (CIGAMCMIActivated && !ShouldPrintCIGAMWarnLogToConsole) {
                        NSAssert(NO, @"出现不合法的indexPath");
                    }
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSIndexPath *, UICollectionViewScrollPosition, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSIndexPath *, UICollectionViewScrollPosition, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, indexPath, scrollPosition, animated);
            };
        });
    });
}

- (void)cigam_clearsSelection {
    NSArray *selectedItemIndexPaths = [self indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in selectedItemIndexPaths) {
        [self deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (void)cigam_reloadDataKeepingSelection {
    NSArray *selectedIndexPaths = [self indexPathsForSelectedItems];
    [self reloadData];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

/// 递归找到view在哪个cell里，不存在则返回nil
- (UICollectionViewCell *)parentCellForView:(UIView *)view {
    if (!view.superview) {
        return nil;
    }
    
    if ([view.superview isKindOfClass:[UICollectionViewCell class]]) {
        return (UICollectionViewCell *)view.superview;
    }
    
    return [self parentCellForView:view.superview];
}

- (NSIndexPath *)cigam_indexPathForItemAtView:(id)sender {
    if (sender && [sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)sender;
        UICollectionViewCell *parentCell = [self parentCellForView:view];
        if (parentCell) {
            return [self indexPathForCell:parentCell];
        }
    }
    
    return nil;
}

- (BOOL)cigam_itemVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visibleItemIndexPaths = self.indexPathsForVisibleItems;
    for (NSIndexPath *visibleIndexPath in visibleItemIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<NSIndexPath *> *)cigam_indexPathsForVisibleItems {
    NSArray<NSIndexPath *> *visibleItems = [self indexPathsForVisibleItems];
    NSSortDescriptor *sectionSorter = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    NSSortDescriptor *rowSorter = [[NSSortDescriptor alloc] initWithKey:@"item" ascending:YES];
    visibleItems = [visibleItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sectionSorter, rowSorter, nil]];
    return visibleItems;
}

- (NSIndexPath *)cigam_indexPathForFirstVisibleCell {
    NSArray *visibleIndexPaths = [self cigam_indexPathsForVisibleItems];
    if (!visibleIndexPaths || visibleIndexPaths.count <= 0) {
        return nil;
    }
    
    return visibleIndexPaths.firstObject;
}

@end
