/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableView+CIGAMCellHeightKeyCache.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/3/14.
//

#import "UITableView+CIGAMCellHeightKeyCache.h"
#import "CIGAMCore.h"
#import "CIGAMCellHeightKeyCache.h"
#import "UIView+CIGAM.h"
#import "UIScrollView+CIGAM.h"
#import "UITableView+CIGAM.h"
#import "CIGAMTableViewProtocols.h"
#import "CIGAMMultipleDelegates.h"

@interface UITableView ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, CIGAMCellHeightKeyCache *> *cigam_allKeyCaches;
@end

@implementation UITableView (CIGAMCellHeightKeyCache)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UITableView class], @selector(setDelegate:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, id<CIGAMTableViewDelegate> firstArgv) {
                
                [selfObject replaceMethodForDelegateIfNeeded:firstArgv];
                
                // call super
                void (*originSelectorIMP)(id, SEL, id<CIGAMTableViewDelegate>);
                originSelectorIMP = (void (*)(id, SEL, id<CIGAMTableViewDelegate>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

static char kAssociatedObjectKey_cigamCacheCellHeightByKeyAutomatically;
- (void)setCigam_cacheCellHeightByKeyAutomatically:(BOOL)cigam_cacheCellHeightByKeyAutomatically {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cigamCacheCellHeightByKeyAutomatically, @(cigam_cacheCellHeightByKeyAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (cigam_cacheCellHeightByKeyAutomatically) {
        
        NSAssert(!self.delegate || [self.delegate respondsToSelector:@selector(cigam_tableView:cacheKeyForRowAtIndexPath:)], @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", self.delegate, NSStringFromSelector(@selector(cigam_tableView:cacheKeyForRowAtIndexPath:)));
        NSAssert(self.estimatedRowHeight != 0 || [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)], @"必须为 estimatedRowHeight 赋一个不为0的值，或者实现 tableView:estimatedHeightForRowAtIndexPath: 方法，否则无法开启 self-sizing cells 功能");
        
        [self replaceMethodForDelegateIfNeeded:(id<CIGAMTableViewDelegate>)self.delegate];
        
        // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。
        self.delegate = self.delegate;
    }
}

- (BOOL)cigam_cacheCellHeightByKeyAutomatically {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamCacheCellHeightByKeyAutomatically)) boolValue];
}

static char kAssociatedObjectKey_cigamAllKeyCaches;
- (void)setCigam_allKeyCaches:(NSMutableDictionary<NSNumber *,CIGAMCellHeightKeyCache *> *)cigam_allKeyCaches {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cigamAllKeyCaches, cigam_allKeyCaches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSNumber *, CIGAMCellHeightKeyCache *> *)cigam_allKeyCaches {
    if (!objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamAllKeyCaches)) {
        self.cigam_allKeyCaches = [NSMutableDictionary dictionary];
    }
    return (NSMutableDictionary<NSNumber *, CIGAMCellHeightKeyCache *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cigamAllKeyCaches);
}

- (CIGAMCellHeightKeyCache *)cigam_currentCellHeightKeyCache {
    CGFloat width = self.cigam_validContentWidth;
    if (width <= 0) {
        return nil;
    }
    CIGAMCellHeightKeyCache *cache = self.cigam_allKeyCaches[@(width)];
    if (!cache) {
        cache = [[CIGAMCellHeightKeyCache alloc] init];
        self.cigam_allKeyCaches[@(width)] = cache;
    }
    return cache;
}

- (void)cigam_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.cigam_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<CIGAMTableViewDelegate>)tableView.delegate) cigam_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        [tableView.cigam_currentCellHeightKeyCache cacheHeight:CGRectGetHeight(cell.frame) forKey:cachedKey];
    }
}

- (CGFloat)cigam_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.cigam_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<CIGAMTableViewDelegate>)tableView.delegate) cigam_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        if ([tableView.cigam_currentCellHeightKeyCache existsHeightForKey:cachedKey]) {
            return [tableView.cigam_currentCellHeightKeyCache heightForKey:cachedKey];
        }
        // 由于 CIGAMCellHeightKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
        return UITableViewAutomaticDimension;
    } else {
        // 对于开启过 cigam_cacheCellHeightByKeyAutomatically 然后又关闭的 class 就会走到这里，做个保护而已。理论上走到这个分支本身就是没有意义的。
        return tableView.rowHeight;
    }
}

- (CGFloat)cigam_tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.cigam_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<CIGAMTableViewDelegate>)tableView.delegate) cigam_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        if ([tableView.cigam_currentCellHeightKeyCache existsHeightForKey:cachedKey]) {
            return [tableView.cigam_currentCellHeightKeyCache heightForKey:cachedKey];
        }
    }
    return UITableViewAutomaticDimension;// 表示 CIGAMCellHeightKeyCache 无法决定一个合适的高度，交给业务，或者交给系统默认值决定。
}

- (void)replaceMethodForDelegateIfNeeded:(id<CIGAMTableViewDelegate>)delegate {
    if (self.cigam_cacheCellHeightByKeyAutomatically && delegate) {
        
        void (^addSelectorBlock)(id<CIGAMTableViewDelegate>) = ^void(id<CIGAMTableViewDelegate> aDelegate) {
            [CIGAMHelper executeBlock:^{
                [self handleWillDisplayCellMethodForDelegate:aDelegate];
                [self handleHeightForRowMethodForDelegate:aDelegate];
                [self handleEstimatedHeightForRowMethodForDelegate:aDelegate];
            } oncePerIdentifier:[NSString stringWithFormat:@"CIGAMCellHeightKeyCache %@", NSStringFromClass(aDelegate.class)]];
        };
        
        if ([delegate isKindOfClass:[CIGAMMultipleDelegates class]]) {
            NSPointerArray *delegates = [((CIGAMMultipleDelegates *)delegate).delegates copy];
            for (id d in delegates) {
                if ([d conformsToProtocol:@protocol(CIGAMTableViewDelegate)]) {
                    addSelectorBlock((id<CIGAMTableViewDelegate>)d);
                }
            }
        } else {
            addSelectorBlock((id<CIGAMTableViewDelegate>)delegate);
        }
    }
}

- (void)handleWillDisplayCellMethodForDelegate:(id<CIGAMTableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:willDisplayCell:forRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，则在调用完 delegate 自身的实现后，再调用我们自己的实现去存储计算后的 cell 高度
    SEL willDisplayCellSelector = @selector(tableView:willDisplayCell:forRowAtIndexPath:);
    Method willDisplayCellMethod = class_getInstanceMethod([self class], @selector(cigam_tableView:willDisplayCell:forRowAtIndexPath:));
    IMP willDisplayCellIMP = method_getImplementation(willDisplayCellMethod);
    void (*willDisplayCellFunction)(id<CIGAMTableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *);
    willDisplayCellFunction = (void (*)(id<CIGAMTableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *))willDisplayCellIMP;
    
    BOOL addedSuccessfully = class_addMethod(delegate.class, willDisplayCellSelector, willDisplayCellIMP, method_getTypeEncoding(willDisplayCellMethod));
    if (!addedSuccessfully) {
        OverrideImplementation([delegate class], willDisplayCellSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(id<CIGAMTableViewDelegate> delegateSelf, UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath) {
                
                // call super
                void (*originSelectorIMP)(id<CIGAMTableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *);
                originSelectorIMP = (void (*)(id<CIGAMTableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *))originalIMPProvider();
                originSelectorIMP(delegateSelf, originCMD, tableView, cell, indexPath);
                
                // call CIGAM
                willDisplayCellFunction(delegateSelf, willDisplayCellSelector, tableView, cell, indexPath);
            };
        });
    }
}

- (void)handleHeightForRowMethodForDelegate:(id<CIGAMTableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:heightForRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，则优先拿它的实现的值来 return，如果它的值小于0（例如-1），则认为它想用 CIGAMCellHeightKeyCache 的计算，此时再 return 我们自己的计算结果
    SEL heightForRowSelector = @selector(tableView:heightForRowAtIndexPath:);
    Method heightForRowMethod = class_getInstanceMethod([self class], @selector(cigam_tableView:heightForRowAtIndexPath:));
    IMP heightForRowIMP = method_getImplementation(heightForRowMethod);
    CGFloat (*heightForRowFunction)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *);
    heightForRowFunction = (CGFloat (*)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *))heightForRowIMP;
    
    BOOL addedSuccessfully = class_addMethod([delegate class], heightForRowSelector, heightForRowIMP, method_getTypeEncoding(heightForRowMethod));
    if (!addedSuccessfully) {
        OverrideImplementation([delegate class], heightForRowSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGFloat(id<CIGAMTableViewDelegate> delegateSelf, UITableView *tableView, NSIndexPath *indexPath) {
                
                // call super
                CGFloat (*originSelectorIMP)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *);
                originSelectorIMP = (CGFloat (*)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *))originalIMPProvider();
                CGFloat result = originSelectorIMP(delegateSelf, originCMD, tableView, indexPath);
                
                if (result >= 0) {
                    return result;
                }
                
                // call CIGAM
                return heightForRowFunction(delegateSelf, heightForRowSelector, tableView, indexPath);
            };
        });
    }
}

- (void)handleEstimatedHeightForRowMethodForDelegate:(id<CIGAMTableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:estimatedHeightForRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，会优先拿 CIGAMCellHeightKeyCache 的结果，如果 CIGAMCellHeightKeyCache 在 cache 里找不到值，才会返回业务在 tableView:estimatedHeightForRowAtIndexPath: 里的返回值
    SEL heightForRowSelector = @selector(tableView:estimatedHeightForRowAtIndexPath:);
    Method heightForRowMethod = class_getInstanceMethod([self class], @selector(cigam_tableView:estimatedHeightForRowAtIndexPath:));
    IMP heightForRowIMP = method_getImplementation(heightForRowMethod);
    CGFloat (*heightForRowFunction)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *);
    heightForRowFunction = (CGFloat (*)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *))heightForRowIMP;
    
    BOOL addedSuccessfully = class_addMethod([delegate class], heightForRowSelector, heightForRowIMP, method_getTypeEncoding(heightForRowMethod));
    if (!addedSuccessfully) {
        OverrideImplementation([delegate class], heightForRowSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGFloat(id<CIGAMTableViewDelegate> delegateSelf, UITableView *tableView, NSIndexPath *indexPath) {
                
                CGFloat result = heightForRowFunction(delegateSelf, heightForRowSelector, tableView, indexPath);
                if (result != UITableViewAutomaticDimension) {
                    return result;
                }
                
                // call super
                CGFloat (*originSelectorIMP)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *);
                originSelectorIMP = (CGFloat (*)(id<CIGAMTableViewDelegate>, SEL, UITableView *, NSIndexPath *))originalIMPProvider();
                result = originSelectorIMP(delegateSelf, originCMD, tableView, indexPath);
                return result;
            };
        });
    }
}

- (void)cigam_invalidateCellHeightCachedForKey:(id<NSCopying>)key {
    [self.cigam_allKeyCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull widthKey, CIGAMCellHeightKeyCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:key];
    }];
}

- (void)cigam_invalidateAllCellHeightKeyCache {
    [self.cigam_allKeyCaches removeAllObjects];
}

@end
