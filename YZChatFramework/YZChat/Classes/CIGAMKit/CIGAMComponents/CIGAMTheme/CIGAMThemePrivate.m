/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CIGAMThemePrivate.m
//  CIGAMKit
//
//  Created by MoLice on 2019/J/26.
//

#import "CIGAMThemePrivate.h"
#import "CIGAMCore.h"
#import "UIColor+CIGAM.h"
#import "UIVisualEffect+CIGAMTheme.h"
#import "UIView+CIGAMTheme.h"
#import "UIView+CIGAM.h"
#import "UISearchBar+CIGAM.h"
#import "UITableViewCell+CIGAM.h"
#import "CALayer+CIGAM.h"
#import "UIVisualEffectView+CIGAM.h"
#import "UIBarItem+CIGAM.h"
#import "UITabBar+CIGAM.h"
#import "UITabBarItem+CIGAM.h"

// CIGAM classes
#import "CIGAMImagePickerCollectionViewCell.h"
#import "CIGAMAlertController.h"
#import "CIGAMButton.h"
#import "CIGAMFillButton.h"
#import "CIGAMGhostButton.h"
#import "CIGAMLinkButton.h"
#import "CIGAMConsole.h"
#import "CIGAMEmotionView.h"
#import "CIGAMEmptyView.h"
#import "CIGAMGridView.h"
#import "CIGAMImagePreviewView.h"
#import "CIGAMLabel.h"
#import "CIGAMPopupContainerView.h"
#import "CIGAMPopupMenuButtonItem.h"
#import "CIGAMPopupMenuView.h"
#import "CIGAMSlider.h"
#import "CIGAMTextField.h"
#import "CIGAMTextView.h"
#import "CIGAMVisualEffectView.h"
#import "CIGAMToastBackgroundView.h"
#import "CIGAMBadgeProtocol.h"

@interface CIGAMThemePropertiesRegister : NSObject

@end

@implementation CIGAMThemePropertiesRegister

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            ({
                static NSDictionary<NSString *, NSArray<NSString *> *> *classRegisters = nil;
                if (!classRegisters) {
                    classRegisters = @{
                                       NSStringFromClass(UISlider.class):                   @[NSStringFromSelector(@selector(minimumTrackTintColor)),
                                                                                              NSStringFromSelector(@selector(maximumTrackTintColor)),
                                                                                              NSStringFromSelector(@selector(thumbTintColor))],
                                       NSStringFromClass(UISwitch.class):                   @[NSStringFromSelector(@selector(onTintColor)),
                                                                                              NSStringFromSelector(@selector(thumbTintColor)),],
                                       NSStringFromClass(UIActivityIndicatorView.class):    @[NSStringFromSelector(@selector(color)),],
                                       NSStringFromClass(UIProgressView.class):             @[NSStringFromSelector(@selector(progressTintColor)),
                                                                                              NSStringFromSelector(@selector(trackTintColor)),],
                                       NSStringFromClass(UIPageControl.class):              @[NSStringFromSelector(@selector(pageIndicatorTintColor)),
                                                                                              NSStringFromSelector(@selector(currentPageIndicatorTintColor)),],
                                       NSStringFromClass(UITableView.class):                @[NSStringFromSelector(@selector(backgroundColor)),
                                                                                              NSStringFromSelector(@selector(sectionIndexColor)),
                                                                                              NSStringFromSelector(@selector(sectionIndexBackgroundColor)),
                                                                                              NSStringFromSelector(@selector(sectionIndexTrackingBackgroundColor)),
                                                                                              NSStringFromSelector(@selector(separatorColor)),],
                                       NSStringFromClass(UITableViewCell.class):            @[NSStringFromSelector(@selector(cigam_selectedBackgroundColor)),],
                                       NSStringFromClass(UICollectionViewCell.class):            @[NSStringFromSelector(@selector(cigam_selectedBackgroundColor)),],
                                       NSStringFromClass(UINavigationBar.class):            @[NSStringFromSelector(@selector(barTintColor)),],
                                       NSStringFromClass(UIToolbar.class):                  @[NSStringFromSelector(@selector(barTintColor)),],
                                       NSStringFromClass(UITabBar.class):                   ({
                                           NSMutableArray<NSString *> *result = @[
                                               NSStringFromSelector(@selector(cigam_effect)),
                                               NSStringFromSelector(@selector(cigam_effectForegroundColor)),
                                           ].mutableCopy;
                                           if (@available(iOS 13.0, *)) {
                                               // iOS 13 在 UITabBar (CIGAM) 里对所有旧版接口都映射到 standardAppearance，所以重新设置一次 standardAppearance 就可以更新所有样式
                                               [result addObject:NSStringFromSelector(@selector(standardAppearance))];
                                           } else {
                                               [result addObjectsFromArray:@[NSStringFromSelector(@selector(barTintColor)),
                                                                             NSStringFromSelector(@selector(unselectedItemTintColor)),
                                                                             NSStringFromSelector(@selector(selectedImageTintColor)),]];
                                           }
                                           result.copy;
                                       }),
                                       NSStringFromClass(UISearchBar.class):                        @[NSStringFromSelector(@selector(barTintColor)),
                                                                                                      NSStringFromSelector(@selector(cigam_placeholderColor)),
                                                                                                      NSStringFromSelector(@selector(cigam_textColor)),],
                                       NSStringFromClass(UIView.class):                             @[NSStringFromSelector(@selector(tintColor)),
                                                                                                      NSStringFromSelector(@selector(backgroundColor)),
                                                                                                      NSStringFromSelector(@selector(cigam_borderColor)),
                                                                                                      NSStringFromSelector(@selector(cigam_badgeBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(cigam_badgeTextColor)),
                                                                                                      NSStringFromSelector(@selector(cigam_updatesIndicatorColor)),],
                                       NSStringFromClass(UIVisualEffectView.class):                 @[NSStringFromSelector(@selector(effect)),
                                                                                                      NSStringFromSelector(@selector(cigam_foregroundColor))],
                                       NSStringFromClass(UIImageView.class):                        @[NSStringFromSelector(@selector(image))],
                                       
                                       // CIGAM classes
                                       NSStringFromClass(CIGAMImagePickerCollectionViewCell.class):  @[NSStringFromSelector(@selector(videoDurationLabelTextColor)),],
                                       NSStringFromClass(CIGAMButton.class):                         @[NSStringFromSelector(@selector(tintColorAdjustsTitleAndImage)),
                                                                                                      NSStringFromSelector(@selector(highlightedBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(highlightedBorderColor)),],
                                       NSStringFromClass(CIGAMFillButton.class):                     @[NSStringFromSelector(@selector(fillColor)),
                                                                                                      NSStringFromSelector(@selector(titleTextColor)),],
                                       NSStringFromClass(CIGAMGhostButton.class):                    @[NSStringFromSelector(@selector(ghostColor)),],
                                       NSStringFromClass(CIGAMLinkButton.class):                     @[NSStringFromSelector(@selector(underlineColor)),],
                                       NSStringFromClass(CIGAMConsole.class):                        @[NSStringFromSelector(@selector(searchResultHighlightedBackgroundColor)),],
                                       NSStringFromClass(CIGAMEmotionView.class):                    @[NSStringFromSelector(@selector(sendButtonBackgroundColor)),],
                                       NSStringFromClass(CIGAMEmptyView.class):                      @[NSStringFromSelector(@selector(textLabelTextColor)),
                                                                                                      NSStringFromSelector(@selector(detailTextLabelTextColor)),
                                                                                                      NSStringFromSelector(@selector(actionButtonTitleColor))],
                                       NSStringFromClass(CIGAMGridView.class):                       @[NSStringFromSelector(@selector(separatorColor)),],
                                       NSStringFromClass(CIGAMImagePreviewView.class):               @[NSStringFromSelector(@selector(loadingColor)),],
                                       NSStringFromClass(CIGAMLabel.class):                          @[NSStringFromSelector(@selector(highlightedBackgroundColor)),],
                                       NSStringFromClass(CIGAMPopupContainerView.class):             @[NSStringFromSelector(@selector(highlightedBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(maskViewBackgroundColor)),
                                                                                                      NSStringFromSelector(@selector(shadowColor)),
                                                                                                      NSStringFromSelector(@selector(borderColor)),
                                                                                                      NSStringFromSelector(@selector(arrowImage)),],
                                       NSStringFromClass(CIGAMPopupMenuButtonItem.class):            @[NSStringFromSelector(@selector(highlightedBackgroundColor)),],
                                       NSStringFromClass(CIGAMPopupMenuView.class):                  @[NSStringFromSelector(@selector(itemSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(sectionSeparatorColor)),
                                                                                                      NSStringFromSelector(@selector(itemTitleColor))],
                                       NSStringFromClass(CIGAMSlider.class):                         @[NSStringFromSelector(@selector(thumbColor)),
                                                                                                      NSStringFromSelector(@selector(thumbShadowColor)),],
                                       NSStringFromClass(CIGAMTextField.class):                      @[NSStringFromSelector(@selector(placeholderColor)),],
                                       NSStringFromClass(CIGAMTextView.class):                       @[NSStringFromSelector(@selector(placeholderColor)),],
                                       NSStringFromClass(CIGAMVisualEffectView.class):               @[NSStringFromSelector(@selector(foregroundColor)),],
                                       NSStringFromClass(CIGAMToastBackgroundView.class):            @[NSStringFromSelector(@selector(styleColor)),],
                                       
                                       // UITextField 支持富文本，因此不能重新设置 textColor 那些属性，会令原有的富文本信息丢失，所以这里直接把文字重新赋值进去即可
                                       // 注意，UITextField 在未聚焦时，切换主题时系统能自动刷新文字颜色，但在聚焦时系统不会自动刷新颜色，所以需要在这里手动刷新
//                                       NSStringFromClass(UITextField.class):                        @[NSStringFromSelector(@selector(attributedText)),],
                                       
                                       // 以下的 class 的更新依赖于 UIView (CIGAMTheme) 内的 setNeedsDisplay，这里不专门调用 setter
//                                       NSStringFromClass(UILabel.class):                            @[NSStringFromSelector(@selector(textColor)),
//                                                                                                      NSStringFromSelector(@selector(shadowColor)),
//                                                                                                      NSStringFromSelector(@selector(highlightedTextColor)),],
//                                       NSStringFromClass(UITextView.class):                         @[NSStringFromSelector(@selector(attributedText)),],

                                       };
                }
                [classRegisters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classString, NSArray<NSString *> * _Nonnull getters, BOOL * _Nonnull stop) {
                    if ([selfObject isKindOfClass:NSClassFromString(classString)]) {
                        [selfObject cigam_registerThemeColorProperties:getters];
                    }
                }];
            });
            return originReturnValue;
        });
    });
}

+ (void)registerToClass:(Class)class byBlock:(void (^)(UIView *view))block withView:(UIView *)view {
    if ([view isKindOfClass:class]) {
        block(view);
    }
}

@end

@implementation UIView (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
        } else {
            OverrideImplementation([UIView class], @selector(setTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, UIColor *tintColor) {
                    
                    // iOS 12 及以下，-[UIView setTintColor:] 被调用时，如果参数的 tintColor 与当前的 tintColor 指针相同，则不会触发 tintColorDidChange，但这对于 dynamic color 而言是不满足需求的（同一个 dynamic color 实例在任何时候返回的 rawColor 都有可能发生变化），所以这里主动为其做一次 copy 操作，规避指针地址判断的问题
                    if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.tintColor) tintColor = tintColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, tintColor);
                };
            });
        }
        
        OverrideImplementation([UIView class], @selector(setBackgroundColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UIView *selfObject, UIColor *color) {
                
                if (selfObject.backgroundColor.cigam_isCIGAMDynamicColor || color.cigam_isCIGAMDynamicColor) {
                    // -[UIView setBackgroundColor:] 会同步修改 layer 的 backgroundColor，但它内部又有一个判断条件即：如果参入传入的 color.CGColor 和当前的 self.layr.backgroundColor 一样，就不会重新设置，而如果 layer.backgroundColor 如果关联了 CIGAM 的动态色，忽略这个设置，就会导致前后不一致的问题，这里要强制把 layer.backgroundColor 清空，让每次都调用 -[CALayer setBackgroundColor:] 方法
                    selfObject.layer.backgroundColor = nil;
                }
                
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
                
            };
        });
        
        // iOS 12 及以下的版本，[UIView setBackgroundColor:] 并不会保存传进来的 color，所以要自己用个变量保存起来，不然 CIGAMThemeColor 对象就会被丢弃
        if (@available(iOS 13.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setBackgroundColor:), UIColor *, ^(UIView *selfObject, UIColor *color) {
                [selfObject cigam_bindObject:color forKey:@"UIView(CIGAMThemeCompatibility).backgroundColor"];
            });
            ExtendImplementationOfNonVoidMethodWithoutArguments([UIView class], @selector(backgroundColor), UIColor *, ^UIColor *(UIView *selfObject, UIColor *originReturnValue) {
                UIColor *color = [selfObject cigam_getBoundObjectForKey:@"UIView(CIGAMThemeCompatibility).backgroundColor"];
                return color ?: originReturnValue;
            });
        }
    });
}

@end

@implementation UISwitch (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这里反而是 iOS 13 才需要用 copy 的方式强制触发更新，否则如果某个 UISwitch 处于 off 的状态，此时去更新它的 onTintColor 不会立即生效，而是要等切换到 on 时，才会看到旧的 onTintColor 一闪而过变成新的 onTintColor，所以这里加个强制刷新
        if (@available(iOS 13.0, *)) {
            OverrideImplementation([UISwitch class], @selector(setOnTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISwitch *selfObject, UIColor *tintColor) {
                    
                    if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.onTintColor) tintColor = tintColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, tintColor);
                };
            });
            
            OverrideImplementation([UISwitch class], @selector(setThumbTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISwitch *selfObject, UIColor *tintColor) {
                    
                    if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.thumbTintColor) tintColor = tintColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, tintColor);
                };
            });
        }

    });
}


@end

@implementation UISlider (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UISlider class], @selector(setMinimumTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.minimumTrackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setMaximumTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.maximumTrackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setThumbTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, UIColor *tintColor) {
                
                if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.thumbTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
    });
}

@end

@implementation UIProgressView (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIProgressView class], @selector(setProgressTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIProgressView *selfObject, UIColor *tintColor) {
                
                if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.progressTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
        
        OverrideImplementation([UIProgressView class], @selector(setTrackTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIProgressView *selfObject, UIColor *tintColor) {
                
                if (tintColor.cigam_isCIGAMDynamicColor && tintColor == selfObject.trackTintColor) tintColor = tintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, tintColor);
            };
        });
    });
}

@end

@implementation UITabBarItem (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UITabBarItem.image 会一直保存原始的 image（例如 CIGAMThemeImage），但 selectedImage 只会返回 rawImage，这导致了将一个 CIGAMThemeImage 设置给 selectedImage 后，主题切换后 selectedImage 无法刷新（因为 UITabBarItem 并没有保存它，保存的是它的 rawImage），所以这里自己保存 image 的引用。
        // https://github.com/Tencent/CIGAM_iOS/issues/1122
        OverrideImplementation([UITabBarItem class], @selector(setSelectedImage:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITabBarItem *selfObject, UIImage *selectedImage) {
                
                // 必须先保存起来再执行 super，因为 setter 的 super 里会触发 getter，如果不先保存，就会导致走到 getter 时拿到的 boundObject 还是旧值
                // https://github.com/Tencent/CIGAM_iOS/issues/1218
                [selfObject cigam_bindObject:selectedImage.cigam_isDynamicImage ? selectedImage : nil forKey:@"UITabBarItem(CIGAMThemeCompatibility).selectedImage"];
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIImage *);
                originSelectorIMP = (void (*)(id, SEL, UIImage *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, selectedImage);
            };
        });
        
        OverrideImplementation([UITabBarItem class], @selector(selectedImage), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UITabBarItem *selfObject) {
                
                // call super
                UIImage * (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIImage * (*)(id, SEL))originalIMPProvider();
                UIImage *result = originSelectorIMP(selfObject, originCMD);
                
                UIImage *selectedImage = [selfObject cigam_getBoundObjectForKey:@"UITabBarItem(CIGAMThemeCompatibility).selectedImage"];
                if (selectedImage) {
                    return selectedImage;
                }
                
                return result;
            };
        });
    });
}

@end

@implementation UITableViewCell (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
        } else {
            //  iOS 12 及以下，-[UITableViewCell setBackgroundColor:] 被调用时，如果参数的 backgroundColor 与当前的 backgroundColor 指针相同，则不会真正去执行颜色设置的逻辑，但这对于 dynamic color 而言是不满足需求的（同一个 dynamic color 实例在任何时候返回的 rawColor 都有可能发生变化），所以这里主动为其做一次 copy 操作，规避指针地址判断的问题
            OverrideImplementation([UITableViewCell class], @selector(setBackgroundColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITableViewCell *selfObject, UIColor *backgroundColor) {
                     if (backgroundColor.cigam_isCIGAMDynamicColor && backgroundColor == selfObject.backgroundColor) backgroundColor = backgroundColor.copy;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, backgroundColor);
                };
            });
        }
    });
}

@end

@implementation UIVisualEffectView (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIVisualEffectView class], @selector(setEffect:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIVisualEffectView *selfObject, UIVisualEffect *effect) {
                
                if (effect.cigam_isDynamicEffect && effect == selfObject.effect) effect = effect.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIVisualEffect *);
                originSelectorIMP = (void (*)(id, SEL, UIVisualEffect *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, effect);
            };
        });
    });
}

@end

@implementation UILabel (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // iOS 10-11 里，UILabel.attributedText 如果整个字符串都是同个颜色，则调用 -[UILabel setNeedsDisplay] 无法刷新文字样式，但如果字符串中存在不同 range 有不同颜色，就可以刷新。iOS 9、12-13 都没这个问题，所以这里做了兼容，给 UIView (CIGAMTheme) 那边刷新 UILabel 用。
        if (@available(iOS 12.0, *)) {
        } else {
            OverrideImplementation([UILabel class], NSSelectorFromString(@"_needsContentsFormatUpdate"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UILabel *selfObject) {
                    
                    __block BOOL attributedTextContainsDynamicColor = NO;
                    if (selfObject.attributedText) {
                        [selfObject.attributedText enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, selfObject.attributedText.length) options:0 usingBlock:^(UIColor *color, NSRange range, BOOL * _Nonnull stop) {
                            if (color.cigam_isCIGAMDynamicColor) {
                                attributedTextContainsDynamicColor = YES;
                                *stop = YES;
                            }
                        }];
                    }
                    if (attributedTextContainsDynamicColor) return YES;
                    
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    return originSelectorIMP(selfObject, originCMD);
                };
            });
        }
    });
}

@end

@implementation UITextField (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 当 UITextField 没聚焦时系统会自动更新文字颜色（即便不手动调用 setNeedsDisplay），但聚焦的时候调用 setNeedsDisplay 也无法自动更新，因此做了这个兼容
        // https://github.com/Tencent/CIGAM_iOS/issues/777
        ExtendImplementationOfVoidMethodWithoutArguments([UITextField class], @selector(setNeedsDisplay), ^(UITextView *selfObject) {
            if (selfObject.isFirstResponder) {
                UIView *fieldEditor = [selfObject cigam_valueForKey:@"_fieldEditor"];
                if (fieldEditor) {
                    UIView *contentView = [fieldEditor cigam_valueForKey:@"_contentView"];
                    if (contentView) {
                        [contentView setNeedsDisplay];
                    }
                }
            }
        });
    });
}

@end

@implementation UITextView (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // UITextView 在 iOS 12 及以上重写了 -[UIView setNeedsDisplay]，在里面会去刷新文字样式，但 iOS 11 及以下没有重写，所以这里对此作了兼容，从而保证 CIGAMTheme 那边遇到 UITextView 时能使用 setNeedsDisplay 刷新文字样式。至于实现思路是参考 iOS 13 系统原生实现。
        if (@available(iOS 12.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments([UITextView class], @selector(setNeedsDisplay), ^(UITextView *selfObject) {
                UIView *textContainerView = [selfObject cigam_valueForKey:@"_containerView"];
                if (textContainerView) [textContainerView setNeedsDisplay];
            });
        }
    });
}

@end

@interface CALayer ()

@property(nonatomic, strong) UIColor *qcl_originalBackgroundColor;
@property(nonatomic, strong) UIColor *qcl_originalBorderColor;
@property(nonatomic, strong) UIColor *qcl_originalShadowColor;

@end

@implementation CALayer (CIGAMThemeCompatibility)

CIGAMSynthesizeIdStrongProperty(qcl_originalBackgroundColor, setQcl_originalBackgroundColor)
CIGAMSynthesizeIdStrongProperty(qcl_originalBorderColor, setQcl_originalBorderColor)
CIGAMSynthesizeIdStrongProperty(qcl_originalShadowColor, setQcl_originalShadowColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CALayer class], @selector(setBackgroundColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGColorRef color) {
                
                // iOS 13 的 UIDynamicProviderColor，以及 CIGAMThemeColor 在获取 CGColor 时会将自身绑定到 CGColorRef 上，这里把原始的 color 重新获取出来存到 property 里，以备样式更新时调用
                UIColor *originalColor = [(__bridge id)(color) cigam_getBoundObjectForKey:CIGAMCGColorOriginalColorBindKey];
                selfObject.qcl_originalBackgroundColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        OverrideImplementation([CALayer class], @selector(setBorderColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) cigam_getBoundObjectForKey:CIGAMCGColorOriginalColorBindKey];
                selfObject.qcl_originalBorderColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        OverrideImplementation([CALayer class], @selector(setShadowColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) cigam_getBoundObjectForKey:CIGAMCGColorOriginalColorBindKey];
                selfObject.qcl_originalShadowColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        // iOS 13 下，如果系统的主题发生变化，会自动调用每个 view 的 layoutSubviews，所以我们在这里面自动更新样式
        // 如果是 CIGAMThemeManager 引发的主题变化，会在 theme 那边主动调用 cigam_setNeedsUpdateDynamicStyle，就不依赖这里
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
                [selfObject.layer cigam_setNeedsUpdateDynamicStyle];
            });
        }
    });
}

- (void)cigam_setNeedsUpdateDynamicStyle {
    if (self.qcl_originalBackgroundColor) {
        UIColor *originalColor = self.qcl_originalBackgroundColor;
        self.backgroundColor = originalColor.CGColor;
    }
    if (self.qcl_originalBorderColor) {
        self.borderColor = self.qcl_originalBorderColor.CGColor;
    }
    if (self.qcl_originalShadowColor) {
        self.shadowColor = self.qcl_originalShadowColor.CGColor;
    }
    
    [self.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull sublayer, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!sublayer.cigam_isRootLayerOfView) {// 如果是 UIView 的 rootLayer，它会依赖 UIView 树自己的 layoutSubviews 去逐个触发，不需要手动遍历到，这里只需要遍历那些额外添加到 layer 上的 sublayer 即可
            [sublayer cigam_setNeedsUpdateDynamicStyle];
        }
    }];
}

@end

@interface UISearchBar ()

@property(nonatomic, readonly) NSMutableDictionary <NSString * ,NSInvocation *>*cigamTheme_invocations;

@end

@implementation UISearchBar (CIGAMThemeCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        OverrideImplementation([UISearchBar class], @selector(setSearchFieldBackgroundImage:forState:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            
            NSMethodSignature *methodSignature = [originClass instanceMethodSignatureForSelector:originCMD];
            
            return ^(UISearchBar *selfObject, UIImage *image, UIControlState state) {
                
                void (*originSelectorIMP)(id, SEL, UIImage *, UIControlState);
                originSelectorIMP = (void (*)(id, SEL, UIImage *, UIControlState))originalIMPProvider();
                
                UIImage *previousImage = [selfObject searchFieldBackgroundImageForState:state];
                if (previousImage.cigam_isDynamicImage || image.cigam_isDynamicImage) {
                    // setSearchFieldBackgroundImage:forState: 的内部实现原理:
                    // 执行后将 image 先存起来，在 layout 时会调用 -[UITextFieldBorderView setImage:] 该方法内部有一个判断：
                    // if (UITextFieldBorderView._image == image) return
                    // 由于 CIGAMDynamicImage 随时可能发生图片的改变，这里要绕过这个判断：必须先清空一下 image，并马上调用 layoutIfNeeded 触发 -[UITextFieldBorderView setImage:] 使得 UITextFieldBorderView 内部的 image 清空，这样再设置新的才会生效。
                    originSelectorIMP(selfObject, originCMD, UIImage.new, state);
                    [selfObject.cigam_textField setNeedsLayout];
                    [selfObject.cigam_textField layoutIfNeeded];
                }
                originSelectorIMP(selfObject, originCMD, image, state);
                
                NSInvocation *invocation = nil;
                NSString *invocationActionKey = [NSString stringWithFormat:@"%@-%zd", NSStringFromSelector(originCMD), state];
                if (image.cigam_isDynamicImage) {
                    invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    [invocation setSelector:originCMD];
                    [invocation setArgument:&image atIndex:2];
                    [invocation setArgument:&state atIndex:3];
                    [invocation retainArguments];
                }
                selfObject.cigamTheme_invocations[invocationActionKey] = invocation;
            };
        });
        
        OverrideImplementation([UISearchBar class], @selector(setBarTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, UIColor *barTintColor) {
                
                if (barTintColor.cigam_isCIGAMDynamicColor && barTintColor == selfObject.barTintColor) barTintColor = barTintColor.copy;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIColor *);
                originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, barTintColor);
            };
        });
    });
}

- (void)_cigam_themeDidChangeByManager:(CIGAMThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews {
    [super _cigam_themeDidChangeByManager:manager identifier:identifier theme:theme shouldEnumeratorSubviews:shouldEnumeratorSubviews];
    [self cigamTheme_performUpdateInvocations];
}

- (void)cigamTheme_performUpdateInvocations {
    [[self.cigamTheme_invocations allValues] enumerateObjectsUsingBlock:^(NSInvocation * _Nonnull invocation, NSUInteger idx, BOOL * _Nonnull stop) {
        [invocation setTarget:self];
        [invocation invoke];
    }];
}


- (NSMutableDictionary *)cigamTheme_invocations {
    NSMutableDictionary *cigamTheme_invocations = objc_getAssociatedObject(self, _cmd);
    if (!cigamTheme_invocations) {
        cigamTheme_invocations = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cigamTheme_invocations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cigamTheme_invocations;
}

@end
