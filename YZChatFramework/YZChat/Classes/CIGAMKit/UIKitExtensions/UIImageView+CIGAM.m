/**
 * Tencent is pleased to support the open source community by making CIGAM_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIImageView+CIGAM.m
//  cigam
//
//  Created by CIGAM Team on 16/8/9.
//

#import "UIImageView+CIGAM.h"
#import "CIGAMCore.h"
#import "CALayer+CIGAM.h"
#import "UIView+CIGAM.h"

@interface UIImageView ()

@property(nonatomic, strong) CALayer *cigamv_animatedImageLayer;
@property(nonatomic, strong) CADisplayLink *cigamv_displayLink;
@property(nonatomic, strong) UIImage *cigamv_animatedImage;
@property(nonatomic, assign) NSInteger cigamv_currentAnimatedImageIndex;
@end

@implementation UIImageView (CIGAM)

CIGAMSynthesizeIdStrongProperty(cigamv_animatedImageLayer, setCigamv_animatedImageLayer)
CIGAMSynthesizeIdStrongProperty(cigamv_displayLink, setCigamv_displayLink)
CIGAMSynthesizeIdStrongProperty(cigamv_animatedImage, setCigamv_animatedImage)
CIGAMSynthesizeNSIntegerProperty(cigamv_currentAnimatedImageIndex, setCigamv_currentAnimatedImageIndex)

- (void)cigamv_swizzleMethods {
    [CIGAMHelper executeBlock:^{
        OverrideImplementation([UIImageView class], @selector(setImage:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIImageView *selfObject, UIImage *image) {
                
                // call super
                void (^callSuperBlock)(UIImage *) = ^void(UIImage *aImage) {
                    void (*originSelectorIMP)(id, SEL, UIImage *);
                    originSelectorIMP = (void (*)(id, SEL, UIImage *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, aImage);
                };
                
                if (selfObject.cigam_smoothAnimation && image.images) {
                    if (image != selfObject.cigamv_animatedImage) {
                        callSuperBlock(nil);
                        selfObject.cigamv_animatedImage = image;
                        [selfObject cigamv_requestToStartAnimation];
                    }
                } else {
                    selfObject.cigamv_animatedImage = nil;
                    [selfObject cigamv_stopAnimating];
                    callSuperBlock(image);
                }
            };
        });
        
        OverrideImplementation([UIImageView class], @selector(image), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UIImageView *selfObject) {
                if (selfObject.cigamv_animatedImage) {
                    return selfObject.cigamv_animatedImage;
                }
                
                // call super
                UIImage *(*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIImage *(*)(id, SEL))originalIMPProvider();
                UIImage *result = originSelectorIMP(selfObject, originCMD);
                
                return result;
            };
        });

        ExtendImplementationOfVoidMethodWithoutArguments([UIImageView class], @selector(layoutSubviews), ^(UIImageView *selfObject) {
            if (selfObject.cigamv_animatedImageLayer) {
                selfObject.cigamv_animatedImageLayer.frame = selfObject.bounds;
            }
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UIImageView class], @selector(didMoveToWindow), ^(UIImageView *selfObject) {
            [selfObject cigamv_updateAnimationStateAutomatically];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setHidden:), BOOL, ^(UIImageView *selfObject, BOOL hidden) {
            [selfObject cigamv_updateAnimationStateAutomatically];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setAlpha:), CGFloat, ^(UIImageView *selfObject, CGFloat alpha) {
            [selfObject cigamv_updateAnimationStateAutomatically];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setFrame:), CGRect, ^(UIImageView *selfObject, CGRect frame) {
            [selfObject cigamv_updateAnimationStateAutomatically];
        });
        
        OverrideImplementation([UIImageView class], @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UIImageView *selfObject, CGSize size) {
                
                if (selfObject.cigamv_animatedImage) {
                    return selfObject.cigamv_animatedImage.size;
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, size);
                return result;
            };
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setContentMode:), UIViewContentMode, ^(UIImageView *selfObject, UIViewContentMode firstArgv) {
            if (selfObject.cigamv_animatedImageLayer) {
                selfObject.cigamv_animatedImageLayer.contentsGravity = [CIGAMHelper layerContentsGravityWithContentMode:firstArgv];
            }
        });
    } oncePerIdentifier:@"UIImageView (CIGAM) smoothAnimation"];
}

- (BOOL)cigamv_requestToStartAnimation {
    if (![self cigamv_canStartAnimation]) return NO;
    
    if (!self.cigamv_animatedImageLayer) {
        self.cigamv_animatedImageLayer = [CALayer layer];
        self.cigamv_animatedImageLayer.contentsGravity = [CIGAMHelper layerContentsGravityWithContentMode:self.contentMode];
        [self.layer addSublayer:self.cigamv_animatedImageLayer];
    }
    
    if (!self.cigamv_displayLink) {
        self.cigamv_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [self.cigamv_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        NSInteger preferredFramesPerSecond = self.cigamv_animatedImage.images.count / self.cigamv_animatedImage.duration;
        self.cigamv_displayLink.preferredFramesPerSecond = preferredFramesPerSecond;
        self.cigamv_currentAnimatedImageIndex = -1;
        self.cigamv_animatedImageLayer.contents = (__bridge id)self.cigamv_animatedImage.images.firstObject.CGImage;// 对于那种一开始就 pause 的图，displayLayer: 不会被调用，所以看不到图，为了避免这种情况，手动先把第一帧显示出来
    }
    
    self.cigamv_displayLink.paused = self.cigam_pause;
    
    return YES;
}

- (void)cigamv_stopAnimating {
    if (self.cigamv_displayLink) {
        [self.cigamv_displayLink invalidate];
        self.cigamv_displayLink = nil;
    }
    if (self.cigamv_animatedImageLayer) {
        [self.cigamv_animatedImageLayer removeFromSuperlayer];
        self.cigamv_animatedImageLayer = nil;
    }
}

- (void)cigamv_updateAnimationStateAutomatically {
    if (self.cigamv_animatedImage) {
        if (![self cigamv_requestToStartAnimation]) {
            [self cigamv_stopAnimating];
        }
    }
}

- (BOOL)cigamv_canStartAnimation {
    return self.cigam_visible && !CGRectIsEmpty(self.frame);
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    self.cigamv_currentAnimatedImageIndex = self.cigamv_currentAnimatedImageIndex < self.cigamv_animatedImage.images.count - 1 ? (self.cigamv_currentAnimatedImageIndex + 1) : 0;
    self.cigamv_animatedImageLayer.contents = (__bridge id)self.cigamv_animatedImage.images[self.cigamv_currentAnimatedImageIndex].CGImage;
}

static char kAssociatedObjectKey_smoothAnimation;
- (void)setCigam_smoothAnimation:(BOOL)cigam_smoothAnimation {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_smoothAnimation, @(cigam_smoothAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_smoothAnimation) {
        [self cigamv_swizzleMethods];
    }
    if (cigam_smoothAnimation && self.image.images && self.image != self.cigamv_animatedImage) {
        self.image = self.image;// 重新设置图片，触发动画
    } else if (!cigam_smoothAnimation && self.cigamv_animatedImage) {
        self.image = self.image;// 交给 setImage 那边把动画清理掉
    }
}

- (BOOL)cigam_smoothAnimation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_smoothAnimation)) boolValue];
}

static char kAssociatedObjectKey_pause;
- (void)setCigam_pause:(BOOL)cigam_pause {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(cigam_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.animationImages || self.image.images) {
        self.cigamv_animatedImageLayer.cigam_pause = cigam_pause;
    }
    if (self.cigamv_displayLink) {
        self.cigamv_displayLink.paused = cigam_pause;
    }
}

- (BOOL)cigam_pause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

- (void)cigam_sizeToFitKeepingImageAspectRatioInSize:(CGSize)limitSize {
    if (!self.image) {
        return;
    }
    CGSize currentSize = self.frame.size;
    if (currentSize.width <= 0) {
        currentSize.width = self.image.size.width;
    }
    if (currentSize.height <= 0) {
        currentSize.height = self.image.size.height;
    }
    CGFloat horizontalRatio = limitSize.width / currentSize.width;
    CGFloat verticalRatio = limitSize.height / currentSize.height;
    CGFloat ratio = fmin(horizontalRatio, verticalRatio);
    CGRect frame = self.frame;
    frame.size.width = flat(currentSize.width * ratio);
    frame.size.height = flat(currentSize.height * ratio);
    self.frame = frame;
}

@end
