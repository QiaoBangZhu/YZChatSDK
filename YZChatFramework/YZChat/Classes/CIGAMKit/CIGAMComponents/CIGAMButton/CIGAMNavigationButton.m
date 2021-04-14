/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  CIGAMNavigationButton.m
//  CIGAMKit
//
//  Created by CIGAM Team on 2018/4/9.
//

#import "CIGAMNavigationButton.h"
#import "CIGAMCore.h"
#import "UIImage+CIGAM.h"
#import "UIColor+CIGAM.h"
#import "UIViewController+CIGAM.h"
#import "CIGAMNavigationController.h"
#import "CIGAMLog.h"
#import "UIControl+CIGAM.h"
#import "UIView+CIGAM.h"
#import "NSString+CIGAM.h"
#import "UINavigationController+CIGAM.h"
#import "UINavigationItem+CIGAM.h"

typedef NS_ENUM(NSInteger, CIGAMNavigationButtonPosition) {
    CIGAMNavigationButtonPositionNone = -1,  // 不处于navigationBar最左（右）边的按钮，则使用None。用None则不会在alignmentRectInsets里调整位置
    CIGAMNavigationButtonPositionLeft,       // 用于leftBarButtonItem，如果用于leftBarButtonItems，则只对最左边的item使用，其他item使用CIGAMNavigationButtonPositionNone
    CIGAMNavigationButtonPositionRight,      // 用于rightBarButtonItem，如果用于rightBarButtonItems，则只对最右边的item使用，其他item使用CIGAMNavigationButtonPositionNone
};

@interface CIGAMNavigationButton()

@property(nonatomic, assign) CIGAMNavigationButtonPosition buttonPosition;
@property(nonatomic, strong) UIImage *defaultHighlightedImage;// 在 set normal image 时自动拿 normal image 加 alpha 作为 highlighted image
@property(nonatomic, strong) UIImage *defaultDisabledImage;// 在 set normal image 时自动拿 normal image 加 alpha 作为 disabled image
@end


@implementation CIGAMNavigationButton

- (instancetype)init {
    return [self initWithType:CIGAMNavigationButtonTypeNormal];
}

- (instancetype)initWithType:(CIGAMNavigationButtonType)type {
    return [self initWithType:type title:nil];
}

- (instancetype)initWithType:(CIGAMNavigationButtonType)type title:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        _type = type;
        self.buttonPosition = CIGAMNavigationButtonPositionNone;
        [self setTitle:title forState:UIControlStateNormal];
        [self renderButtonStyle];
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithType:CIGAMNavigationButtonTypeImage]) {
        [self setImage:image forState:UIControlStateNormal];
        [self sizeToFit];
    }
    return self;
}

- (void)renderButtonStyle {
    UIFont *font = NavBarButtonFont;
    if (font) {
        self.titleLabel.font = font;
    }
    self.titleLabel.backgroundColor = UIColorClear;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.contentMode = UIViewContentModeCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.cigam_automaticallyAdjustTouchHighlightedInScrollView = YES;
    
    // UIBarButtonItem 默认都是跟随 tintColor 的，所以这里让图片也是用 alwaysTemplate 模式
    self.adjustsImageTintColorAutomatically = YES;
    
    if (self.type == CIGAMNavigationButtonTypeImage) {
        if (@available(iOS 11, *)) {
            // 让 iOS 11 及以后也能走到 alignmentRectInsets，iOS 10 及以前的系统就算不置为 NO 也可以走到 alignmentRectInsets，从而保证 image 类型的按钮的布局、间距与系统的保持一致
            self.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    
    // 系统默认对 highlighted 和 disabled 的图片的表现是变身色，但 UIBarButtonItem 是 alpha，为了与 UIBarButtonItem  表现一致，这里禁用了 UIButton 默认的行为，然后通过重写 setImage:forState:，自动将 normal image 处理为对应的 highlighted image 和 disabled image
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    
    switch (self.type) {
        case CIGAMNavigationButtonTypeNormal:
            break;
        case CIGAMNavigationButtonTypeImage:
            // 拓展宽度，以保证用 leftBarButtonItems/rightBarButtonItems 时，按钮与按钮之间间距与系统的保持一致
            self.contentEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
            break;
        case CIGAMNavigationButtonTypeBold: {
            font = NavBarButtonFontBold;
            if (font) {
                self.titleLabel.font = font;
            }
        }
            break;
        case CIGAMNavigationButtonTypeBack: {
            UIImage *backIndicatorImage = UINavigationBar.cigam_appearanceConfigured.backIndicatorImage;
            if (!backIndicatorImage) {
                // 配置表没有自定义的图片，则按照系统的返回按钮图片样式创建一张，颜色按照 tintColor 来
                UIColor *tintColor = CIGAMCMIActivated ? NavBarTintColor : UIColor.cigam_systemTintColor;
                backIndicatorImage = [UIImage cigam_imageWithShape:CIGAMImageShapeNavBack size:CGSizeMake(13, 23) lineWidth:3 tintColor:tintColor];
            }
            [self setImage:backIndicatorImage forState:UIControlStateNormal];
            [self setImage:[backIndicatorImage cigam_imageWithAlpha:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
            [self setImage:[backIndicatorImage cigam_imageWithAlpha:NavBarDisabledAlpha] forState:UIControlStateDisabled];
            
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            // @warning 这些数值都是每个iOS版本核对过没问题的，如果修改则要检查要每个版本里与系统UIBarButtonItem的布局是否一致
            UIOffset titleOffsetBaseOnSystem = UIOffsetMake(IOS_VERSION >= 11.0 ? 6 : 7, 0);// 经过这些数值的调整后，自定义返回按钮的位置才能和系统默认返回按钮的位置对准，而配置表里设置的值是在这个调整的基础上再调整
            UIOffset configurationOffset = NavBarBarBackButtonTitlePositionAdjustment;
            self.titleEdgeInsets = UIEdgeInsetsMake(titleOffsetBaseOnSystem.vertical + configurationOffset.vertical, titleOffsetBaseOnSystem.horizontal + configurationOffset.horizontal, -titleOffsetBaseOnSystem.vertical - configurationOffset.vertical, -titleOffsetBaseOnSystem.horizontal - configurationOffset.horizontal);
            self.contentEdgeInsets = UIEdgeInsetsMake(IOS_VERSION < 11.0 ? 1 : 0,// iOS 11 以前，y 值偏移一点
                                                      0,
                                                      0,
                                                      self.titleEdgeInsets.left);
        }
            break;
            
        default:
            break;
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (image && self.adjustsImageTintColorAutomatically) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if (image && [self imageForState:state] != image) {
        if (state == UIControlStateNormal) {
            // 将 normal image 处理成对应的 highlighted image 和 disabled image
            self.defaultHighlightedImage = [[image cigam_imageWithAlpha:NavBarHighlightedAlpha] imageWithRenderingMode:image.renderingMode];
            [self setImage:self.defaultHighlightedImage forState:UIControlStateHighlighted];
            
            self.defaultDisabledImage = [[image cigam_imageWithAlpha:NavBarDisabledAlpha] imageWithRenderingMode:image.renderingMode];
            [self setImage:self.defaultDisabledImage forState:UIControlStateDisabled];
        } else {
            // 如果业务主动设置了非 normal 状态的 image，则把之前 CIGAM 自动加上的两个 image 去掉，相当于认为业务希望完全控制这个按钮在所有 state 下的图片
            if (image != self.defaultHighlightedImage && image != self.defaultDisabledImage) {
                if ([self imageForState:UIControlStateHighlighted] == self.defaultHighlightedImage && state != UIControlStateHighlighted) {
                    [self setImage:nil forState:UIControlStateHighlighted];
                }
                if ([self imageForState:UIControlStateDisabled] == self.defaultDisabledImage && state != UIControlStateDisabled) {
                    [self setImage:nil forState:UIControlStateDisabled];
                }
            }
        }
    }
    
    [super setImage:image forState:state];
}

- (void)setAdjustsImageTintColorAutomatically:(BOOL)adjustsImageTintColorAutomatically {
    BOOL valueDifference = _adjustsImageTintColorAutomatically != adjustsImageTintColorAutomatically;
    _adjustsImageTintColorAutomatically = adjustsImageTintColorAutomatically;
    
    if (valueDifference) {
        [self updateImageRenderingModeIfNeeded];
    }
}

- (void)updateImageRenderingModeIfNeeded {
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected), @(UIControlStateSelected|UIControlStateHighlighted), @(UIControlStateDisabled)];
        
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:number.unsignedIntegerValue];
            if (!image) {
                return;
            }
            
            if (self.adjustsImageTintColorAutomatically) {
                // 这里的 setImage: 操作不需要使用 renderingMode 对 image 重新处理，而是放到重写的 setImage:forState 里去做就行了
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用 template 的模式渲染，并且之前是使用 template 的，则把 renderingMode 改回 original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

// 自定义nav按钮，需要根据这个来修改title的三态颜色。
- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self setTitleColor:[self.tintColor colorWithAlphaComponent:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
    [self setTitleColor:[self.tintColor colorWithAlphaComponent:NavBarDisabledAlpha] forState:UIControlStateDisabled];
}

// 对按钮内容添加偏移，让UIBarButtonItem适配最新设备的系统行为，统一位置。注意 iOS 11 及以后，只有 image 类型的才会走进来
- (UIEdgeInsets)alignmentRectInsets {
    
    UIEdgeInsets insets = [super alignmentRectInsets];
    
    if (self.type == CIGAMNavigationButtonTypeNormal || self.type == CIGAMNavigationButtonTypeBold) {
        // 对于奇数大小的字号，不同 iOS 版本的偏移策略不同，统一一下
        if (self.titleLabel.font.pointSize / 2.0 > 0) {
            insets.top = -PixelOne;
            insets.bottom = PixelOne;
        }
    } else if (self.type == CIGAMNavigationButtonTypeImage) {
        // 图片类型的按钮，分别对最左、最右那个按钮调整 inset（这里与 UINavigationItem(CIGAMNavigationButton) 里的 position 赋值配合使用）
        if (self.buttonPosition == CIGAMNavigationButtonPositionLeft) {
            insets.left = 11;
        } else if (self.buttonPosition == CIGAMNavigationButtonPositionRight) {
            insets.right = 11;
        }
        
        insets.top = 1;
    } else if (self.type == CIGAMNavigationButtonTypeBack) {
        insets.top = PixelOne;
        if (@available(iOS 11, *)) {
        } else {
            insets.left = 8;
        }
    }
    
    return insets;
}

@end

@implementation UIBarButtonItem (CIGAMNavigationButton)

+ (instancetype)cigam_itemWithButton:(CIGAMNavigationButton *)button target:(nullable id)target action:(nullable SEL)action {
    if (!button) return nil;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:button];
}

+ (instancetype)cigam_itemWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    if (!image) return nil;
    return [[self alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)cigam_itemWithTitle:(NSString *)title target:(nullable id)target action:(nullable SEL)action {
    if (!title) return nil;
    return [[self alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)cigam_itemWithBoldTitle:(NSString *)title target:(nullable id)target action:(nullable SEL)action {
    if (!title) return nil;
    return [[self alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:target action:action];
}

+ (instancetype)cigam_backItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action {
    CIGAMNavigationButton *button = [[CIGAMNavigationButton alloc] initWithType:CIGAMNavigationButtonTypeBack title:title];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[self alloc] initWithCustomView:button];
    return barButtonItem;
}

+ (instancetype)cigam_backItemWithTarget:(nullable id)target action:(nullable SEL)action {
    NSString *backTitle = nil;
    if (NeedsBackBarButtonItemTitle) {
        backTitle = @"返回"; // 默认文字用返回
        if ([target isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)target;
            UIViewController *previousViewController = viewController.cigam_previousViewController;
            if (previousViewController.navigationItem.backBarButtonItem) {
                // 如果前一个界面有主动设置返回按钮的文字，则取这个文字
                backTitle = previousViewController.navigationItem.backBarButtonItem.title;
            } else if ([viewController respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
                // 否则看是否有通过 CIGAM 提供的接口来设置返回按钮的文字，有就用它的值
                backTitle = [((UIViewController<CIGAMNavigationControllerAppearanceDelegate> *)viewController) backBarButtonItemTitleWithPreviousViewController:previousViewController];
            } else if (previousViewController.title) {
                // 否则取上一个界面的标题
                backTitle = previousViewController.title;
            }
        }
    } else {
        backTitle = @" ";
    }
    
    return [self cigam_backItemWithTitle:backTitle target:target action:action];
}

+ (instancetype)cigam_closeItemWithTarget:(nullable id)target action:(nullable SEL)action {
    UIBarButtonItem *closeItem = [[self alloc] initWithImage:NavBarCloseButtonImage style:UIBarButtonItemStylePlain target:target action:action];
    closeItem.accessibilityLabel = @"关闭";
    return closeItem;
}

+ (instancetype)cigam_fixedSpaceItemWithWidth:(CGFloat)width {
    UIBarButtonItem *item = [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    item.width = width;
    return item;
}

+ (instancetype)cigam_flexibleSpaceItem {
    return [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
}

@end

@interface UIBarButtonItem (CIGAMNavigationButton_Private)

/// 判断当前的 UIBarButtonItem 是否是 CIGAMNavigationButton
@property(nonatomic, assign, readonly) BOOL cigam_isCustomizedBarButtonItem;

/// 判断当前的 UIBarButtonItem 是否是用 CIGAMNavigationButton 自定义返回按钮生成的
@property(nonatomic, assign, readonly) BOOL cigam_isCustomizedBackBarButtonItem;

/// 获取内部的 CIGAMNavigationButton（如果有的话）
@property(nonatomic, strong, readonly) CIGAMNavigationButton *cigam_navigationButton;
@end

@interface UINavigationItem (CIGAMNavigationButton)

@property(nonatomic, copy) NSArray<UIBarButtonItem *> *tempLeftBarButtonItems;
@property(nonatomic, copy) NSArray<UIBarButtonItem *> *tempRightBarButtonItems;
@end

@interface UIViewController (CIGAMNavigationButton)

@end

@interface UINavigationBar (CIGAMNavigationButton)

/// 判断当前的 UINavigationBar 的返回按钮是不是自定义的
@property(nonatomic, readonly) BOOL cigam_customizingBackBarButtonItem;
@end

@implementation UIBarButtonItem (CIGAMNavigationButton_Private)

- (BOOL)cigam_isCustomizedBarButtonItem {
    if (!self.customView) {
        return NO;
    }
    return [self.customView isKindOfClass:[CIGAMNavigationButton class]];
}

- (BOOL)cigam_isCustomizedBackBarButtonItem {
    return self.cigam_isCustomizedBarButtonItem && ((CIGAMNavigationButton *)self.customView).type == CIGAMNavigationButtonTypeBack;
}

- (CIGAMNavigationButton *)cigam_navigationButton {
    if ([self.customView isKindOfClass:[CIGAMNavigationButton class]]) {
        return (CIGAMNavigationButton *)self.customView;
    }
    return nil;
}

@end

@implementation UINavigationItem (CIGAMNavigationButton)

CIGAMSynthesizeIdCopyProperty(tempLeftBarButtonItems, setTempLeftBarButtonItems)
CIGAMSynthesizeIdCopyProperty(tempRightBarButtonItems, setTempRightBarButtonItems)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setLeftBarButtonItem:animated:),
            @selector(setLeftBarButtonItems:animated:),
            @selector(setRightBarButtonItem:animated:),
            @selector(setRightBarButtonItems:animated:),
            
            // 如果被拦截，则 getter 也要返回被缓存的 item，否则会出现这个 bug：https://github.com/Tencent/CIGAM_iOS/issues/362
            @selector(leftBarButtonItem),
            @selector(leftBarButtonItems),
            @selector(rightBarButtonItem),
            @selector(rightBarButtonItems)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"cigam_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

// 监控是否在 iOS 10 及以下，手势返回的过程中，手势返回背后的那个界面修改了 navigationItem，这可能导致 bug：https://github.com/Tencent/CIGAM_iOS/issues/302
- (BOOL)detectSetItemsWhenPopping {
    if (@available(iOS 11, *)) {
    } else {
        if (self.cigam_navigationBar && [self.cigam_navigationBar.delegate isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)self.cigam_navigationBar.delegate;
            
//            CIGAMLog(@"UINavigationItem (CIGAMNavigationButton)", @"navigationController is %@, topViewController is %@, viewControllers is %@, willAppearByInteractivePopGestureRecognizer is %@, navigationControllerPopGestureRecognizerChanging is %@", navController, navController.topViewController, navController.viewControllers, StringFromBOOL(navController.topViewController.cigam_willAppearByInteractivePopGestureRecognizer), StringFromBOOL(navController.topViewController.cigam_navigationControllerPopGestureRecognizerChanging));

            // 判断是否当前处于手势返回的过程中，且背后的控制器的 viewWillAppear: 已经被执行过。
            // 注意，判断条件里的 cigam_navigationControllerPopGestureRecognizerChanging 关键在于，它是在 viewWillAppear: 执行后才被置为 YES，而 CIGAMCommonViewController 是在 viewWillAppear: 里调用 setNavigationItems:，所以刚好过滤了这种场景。因为测试过，在 viewWillAppear: 里操作 items 是没问题的，但在那之后的操作就会有问题。
            BOOL isPopGestureRecognizerChanging = navController.topViewController.cigam_willAppearByInteractivePopGestureRecognizer && navController.topViewController.cigam_navigationControllerPopGestureRecognizerChanging;
            
            // 侧滑松手后，如果因为距离不够放弃返回，在还原位置还原的过程中去修改 navigationItem 也会导致布局错误，cigam_willAppearByInteractivePopGestureRecognizer 在 viewDidAppear: 才会被置为 YES，而在松手后 state 会被置为 UIGestureRecognizerStatePossible， navController.topViewController.view.superview.frame < 0 可以作为松手后放弃返回的判断条件（成功返回则等于 0）
            BOOL isPopGestureRecognizerCanceled = navController.topViewController.cigam_willAppearByInteractivePopGestureRecognizer && navController.interactivePopGestureRecognizer.state == UIGestureRecognizerStatePossible && CGRectGetMinX(navController.topViewController.view.superview.frame) < 0;
            
            if (isPopGestureRecognizerChanging || isPopGestureRecognizerCanceled) {
                CIGAMLog(@"UINavigationItem (CIGAMNavigationButton)", @"拦截了一次可能产生顶部按钮混乱的操作");
                return YES;
            }
        }
    }
    return NO;
}

- (void)cigam_setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempLeftBarButtonItems = item ? @[item] : nil;
        return;
    }
    
    [self cigam_setLeftBarButtonItem:item animated:animated];
    
    // 自动给 position 赋值
    item.cigam_navigationButton.buttonPosition = CIGAMNavigationButtonPositionLeft;
}

- (void)cigam_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)items animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempLeftBarButtonItems = items;
        return;
    }
    
    [self cigam_setLeftBarButtonItems:items animated:animated];
    
    // 自动给 position 赋值
    for (NSInteger i = 0; i < items.count; i++) {
        if (i == 0) {
            items[i].cigam_navigationButton.buttonPosition = CIGAMNavigationButtonPositionLeft;
        } else {
            items[i].cigam_navigationButton.buttonPosition = CIGAMNavigationButtonPositionNone;
        }
    }
}

- (void)cigam_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempRightBarButtonItems = item ? @[item] : nil;
        return;
    }
    
    [self cigam_setRightBarButtonItem:item animated:animated];
    
    // 自动给 position 赋值
    item.cigam_navigationButton.buttonPosition = CIGAMNavigationButtonPositionRight;
}

- (void)cigam_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)items animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempRightBarButtonItems = items;
        return;
    }
    
    [self cigam_setRightBarButtonItems:items animated:animated];
    
    // 自动给 position 赋值
    for (NSInteger i = 0; i < items.count; i++) {
        if (i == 0) {
            items[i].cigam_navigationButton.buttonPosition = CIGAMNavigationButtonPositionRight;
        } else {
            items[i].cigam_navigationButton.buttonPosition = CIGAMNavigationButtonPositionNone;
        }
    }
}

- (UIBarButtonItem *)cigam_leftBarButtonItem {
    if (self.tempLeftBarButtonItems) {
        return self.tempLeftBarButtonItems.firstObject;
    }
    return [self cigam_leftBarButtonItem];
}

- (NSArray<UIBarButtonItem *> *)cigam_leftBarButtonItems {
    if (self.tempLeftBarButtonItems) {
        return self.tempLeftBarButtonItems;
    }
    return [self cigam_leftBarButtonItems];
}

- (UIBarButtonItem *)cigam_rightBarButtonItem {
    if (self.tempRightBarButtonItems) {
        return self.tempRightBarButtonItems.firstObject;
    }
    return [self cigam_rightBarButtonItem];
}

- (NSArray<UIBarButtonItem *> *)cigam_rightBarButtonItems {
    if (self.tempRightBarButtonItems) {
        return self.tempRightBarButtonItems;
    }
    return [self cigam_rightBarButtonItems];
}

@end

@implementation UIViewController (CIGAMNavigationButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            if (selfObject.navigationItem.tempLeftBarButtonItems) {
                selfObject.navigationItem.leftBarButtonItems = selfObject.navigationItem.tempLeftBarButtonItems;
                selfObject.navigationItem.tempLeftBarButtonItems = nil;
            }
            if (selfObject.navigationItem.tempRightBarButtonItems) {
                selfObject.navigationItem.rightBarButtonItems = selfObject.navigationItem.tempRightBarButtonItems;
                selfObject.navigationItem.tempRightBarButtonItems = nil;
            }
        });
        
        // 当使用自定义返回按钮时，无法使用 VoiceOver 或者 iOS 13.4 新增的 Full Keyboard Access 返回
        OverrideImplementation([UIViewController class], @selector(accessibilityPerformEscape), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIViewController *selfObject) {
                
                if (selfObject.navigationItem.leftBarButtonItem.cigam_isCustomizedBackBarButtonItem
                    && ((CIGAMNavigationButton *)selfObject.navigationItem.leftBarButtonItem.customView).enabled
                    && selfObject.navigationController.cigam_rootViewController != selfObject
                    && selfObject.navigationController.interactivePopGestureRecognizer.enabled
                    && !UIApplication.sharedApplication.ignoringInteractionEvents) {
                    [selfObject.navigationController popViewControllerAnimated:YES];
                    return YES;
                }
                
                // call super
                BOOL (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                BOOL result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
    });
}

@end

@implementation UINavigationBar (CIGAMNavigationButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 强制修改 contentView 的 directionalLayoutMargins.leading，在使用自定义返回按钮时减小 8
        // Xcode11 beta2 修改私有 view 的 directionalLayoutMargins 会 crash，换个方式
        if (@available(iOS 11, *)) {
            
            NSString *barContentViewString = [NSString cigam_stringByConcat:@"_", @"UINavigationBar", @"ContentView", nil];
            
            OverrideImplementation(NSClassFromString(barContentViewString), @selector(directionalLayoutMargins), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^NSDirectionalEdgeInsets(UIView *selfObject) {
                    
                    // call super
                    NSDirectionalEdgeInsets (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (NSDirectionalEdgeInsets (*)(id, SEL))originalIMPProvider();
                    NSDirectionalEdgeInsets originResult = originSelectorIMP(selfObject, originCMD);
                    
                    // get navbar
                    UINavigationBar *navBar = nil;
                    if ([NSStringFromClass([selfObject class]) isEqualToString:barContentViewString] &&
                        [selfObject.superview isKindOfClass:[UINavigationBar class]]) {
                        navBar = (UINavigationBar *)selfObject.superview;
                    }
                    
                    // change insets
                    if (navBar) {
                        NSDirectionalEdgeInsets value = originResult;
                        value.leading -= (navBar.cigam_customizingBackBarButtonItem ? 8 : 0);
                        return value;
                    }
                    
                    return originResult;
                };
            });
        }
        
    });
}

- (BOOL)cigam_customizingBackBarButtonItem {
    if (self.topItem.leftBarButtonItem) {
        return self.topItem.leftBarButtonItem.cigam_isCustomizedBackBarButtonItem;
    }
    return NO;
}

@end
