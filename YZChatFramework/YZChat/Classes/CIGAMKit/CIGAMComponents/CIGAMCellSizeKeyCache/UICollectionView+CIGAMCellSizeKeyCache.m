/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UICollectionView+CIGAMCellSizeKeyCache.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/3/14.
//

#import "UICollectionView+CIGAMCellSizeKeyCache.h"
#import "CIGAMCore.h"
#import "CIGAMCellSizeKeyCache.h"
#import "UIScrollView+CIGAM.h"
#import "CIGAMMultipleDelegates.h"

//@interface UICollectionViewCell (CIGAMCellSizeKeyCache)
//
//@property(nonatomic, weak) UICollectionView *cigam_collectionView;
//@end
//
//@implementation UICollectionViewCell (CIGAMCellSizeKeyCache)
//
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        ExchangeImplementations(self.class, @selector(preferredLayoutAttributesFittingAttributes:), @selector(cigam_preferredLayoutAttributesFittingAttributes:));
//        ExchangeImplementations(self.class, @selector(didMoveToSuperview), @selector(cigam_didMoveToSuperview));
//    });
//}
//
//static char kAssociatedObjectKey_collectionView;
//- (void)setCigam_collectionView:(UICollectionView *)cigam_collectionView {
//    objc_setAssociatedObject(self, &kAssociatedObjectKey_collectionView, cigam_collectionView, OBJC_ASSOCIATION_ASSIGN);
//}
//
//- (UICollectionView *)cigam_collectionView {
//    return (UICollectionView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_collectionView);
//}
//
//- (void)cigam_didMoveToSuperview {
//    [self cigam_didMoveToSuperview];
//    if ([self.superview isKindOfClass:[UICollectionView class]]) {
//        __weak UICollectionView *weakCollectionView = (UICollectionView *)self.superview;
//        self.cigam_collectionView = weakCollectionView;
//    } else {
//        self.cigam_collectionView = nil;
//    }
//}
//
//- (UICollectionViewLayoutAttributes *)cigam_preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    if (self.cigam_collectionView.cigam_cacheCellSizeByKeyAutomatically) {
//        id<NSCopying> key = [((id<CIGAMCellSizeKeyCache_UICollectionViewDelegate>)self.cigam_collectionView.delegate) cigam_collectionView:self.cigam_collectionView cacheKeyForItemAtIndexPath:layoutAttributes.indexPath];
//        if ([self.cigam_collectionView.cigam_currentCellSizeKeyCache existsSizeForKey:key]) {
//            CGSize cachedSize = [self.cigam_collectionView.cigam_currentCellSizeKeyCache sizeForKey:key];
//            layoutAttributes.size = cachedSize;
//            return layoutAttributes;
//        }
//    }
//    return [self cigam_preferredLayoutAttributesFittingAttributes:layoutAttributes];
//}
//
//@end

@interface UICollectionView ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, CIGAMCellSizeKeyCache *> *cigam_allKeyCaches;
@end

@implementation UICollectionView (CIGAMCellSizeKeyCache)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UICollectionView class], @selector(setDelegate:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UICollectionView *selfObject, id<UICollectionViewDelegate> firstArgv) {
                
                [selfObject replaceMethodForDelegateIfNeeded:firstArgv];
                
                // call super
                void (*originSelectorIMP)(id, SEL, id<UICollectionViewDelegate>);
                originSelectorIMP = (void (*)(id, SEL, id<UICollectionViewDelegate>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

static char kAssociatedObjectKey_cigamCacheCellSizeByKeyAutomatically;
- (void)setCigam_cacheCellSizeByKeyAutomatically:(BOOL)cigam_cacheCellSizeByKeyAutomatically {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cigamCacheCellSizeByKeyAutomatically, @(cigam_cacheCellSizeByKeyAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (cigam_cacheCellSizeByKeyAutomatically) {
        NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"CIGAMCellSizeKeyCache 只支持 UICollectionViewFlowLayout");
        
        [self replaceMethodForDelegateIfNeeded:self.delegate];
        
        // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。与 UITableView 不同，UICollectionView 不管哪个 iOS 版本都要先置为 nil 再重新设置才能让 delegate 方法替换立即生效
        id <UICollectionViewDelegate> tempDelegate = self.delegate;
        self.delegate = nil;
        self.delegate = tempDelegate;
    }
}

- (BOOL)cigam_cacheCellSizeByKeyAutomatically {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamCacheCellSizeByKeyAutomatically)) boolValue];
}

static char kAssociatedObjectKey_cigamAllKeyCaches;
- (void)setCigam_allKeyCaches:(NSMutableDictionary<NSNumber *,CIGAMCellSizeKeyCache *> *)cigam_allKeyCaches {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cigamAllKeyCaches, cigam_allKeyCaches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSNumber *, CIGAMCellSizeKeyCache *> *)cigam_allKeyCaches {
    if (!objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamAllKeyCaches)) {
        self.cigam_allKeyCaches = [NSMutableDictionary dictionary];
    }
    return (NSMutableDictionary<NSNumber *, CIGAMCellSizeKeyCache *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamAllKeyCaches);
}

- (CIGAMCellSizeKeyCache *)cigam_currentCellSizeKeyCache {
    CGFloat width = [self widthForCacheKey];
    if (width <= 0) {
        return nil;
    }
    CIGAMCellSizeKeyCache *cache = self.cigam_allKeyCaches[@(width)];
    if (!cache) {
        cache = [[CIGAMCellSizeKeyCache alloc] init];
        self.cigam_allKeyCaches[@(width)] = cache;
    }
    return cache;
}

// 当 collectionView 水平滚动时，则认为垂直方向的内容区域会影响 cell 的 size 计算。而当 collectionView 垂直滚动时，则认为水平方向的内容区域会影响 cell 的 size 计算。
- (CGFloat)widthForCacheKey {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat height = CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.cigam_contentInset) - UIEdgeInsetsGetVerticalValue(layout.sectionInset);
        return height;
    }
    CGFloat width = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.cigam_contentInset) - UIEdgeInsetsGetHorizontalValue(((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset);
    return width;
}

- (void)cigam_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView cigam_collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    if (collectionView.cigam_cacheCellSizeByKeyAutomatically) {
        if (![collectionView.delegate respondsToSelector:@selector(cigam_collectionView:cacheKeyForItemAtIndexPath:)]) {
            NSAssert(NO, @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", collectionView.delegate, NSStringFromSelector(@selector(cigam_collectionView:cacheKeyForItemAtIndexPath:)));
        }
        id<NSCopying> cachedKey = [((id<CIGAMCellSizeKeyCache_UICollectionViewDelegate>)self) cigam_collectionView:collectionView cacheKeyForItemAtIndexPath:indexPath];
        [collectionView.cigam_currentCellSizeKeyCache cacheSize:cell.frame.size forKey:cachedKey];
    }
}

//- (CGSize)cigam_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (collectionView.cigam_cacheCellSizeByKeyAutomatically) {
//        if (![collectionView.delegate respondsToSelector:@selector(cigam_collectionView:cacheKeyForItemAtIndexPath:)]) {
//            NSAssert(NO, @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", collectionView.delegate, NSStringFromSelector(@selector(cigam_collectionView:cacheKeyForItemAtIndexPath:)));
//        }
//        id<NSCopying> cachedKey = [((id<CIGAMCellSizeKeyCache_UICollectionViewDelegate>)self) cigam_collectionView:collectionView cacheKeyForItemAtIndexPath:indexPath];
//        if ([collectionView.cigam_currentCellSizeKeyCache existsSizeForKey:cachedKey]) {
//            return [collectionView.cigam_currentCellSizeKeyCache sizeForKey:cachedKey];
//        }
//    } else {
//        // 对于开启过 cigam_cacheCellSizeByKeyAutomatically 然后又关闭的 class 就会走到这里，此时已经无法调用回之前被替换的方法的实现，所以直接使用 collecionView.itemSize
//        // TODO: molice 最好应该在 replaceMethodForDelegateIfNeeded: 里判断在替换方法之前 delegate 是否已经有实现 sizeForItem，如果有，则在这里调用回它自己的实现，如果没有，再使用 collecionView.itemSize，不然现在的做法会导致 delegate 里关闭了自动缓存的情况下就算实现了 sizeForItem，也无法被调用。
//        return collectionViewLayout.estimatedItemSize;
//    }
//
//    // 由于 CIGAMCellSizeKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
//    return collectionViewLayout.estimatedItemSize;
//}

- (void)replaceMethodForDelegateIfNeeded:(id<UICollectionViewDelegate>)delegate {
//    if (self.cigam_cacheCellSizeByKeyAutomatically && delegate) {
//        void (^addSelectorBlock)(id<UICollectionViewDelegate>) = ^void(id<UICollectionViewDelegate> aDelegate) {
//            [CIGAMHelper executeBlock:^{
//            } oncePerIdentifier:[NSString stringWithFormat:@"CIGAMCellHeightKeyCache collectionView %@", NSStringFromClass(aDelegate.class)]];
//        };
//        
//        if ([delegate isKindOfClass:[CIGAMMultipleDelegates class]]) {
//            NSPointerArray *delegates = [((CIGAMMultipleDelegates *)delegate).delegates copy];
//            for (id d in delegates) {
//                if ([d conformsToProtocol:@protocol(UICollectionViewDelegate)]) {
//                    addSelectorBlock((id<UICollectionViewDelegate>)d);
//                }
//            }
//        } else {
//            addSelectorBlock((id<UICollectionViewDelegate>)delegate);
//        }
//    }
}

@end
