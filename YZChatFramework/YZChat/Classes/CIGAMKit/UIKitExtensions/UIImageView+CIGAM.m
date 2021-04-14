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

@property(nonatomic, strong) CALayer *qimgv_animatedImageLayer;
@property(nonatomic, strong) CADisplayLink *qimgv_displayLink;
@property(nonatomic, strong) UIImage *qimgv_animatedImage;
@property(nonatomic, assign) NSInteger qimgv_currentAnimatedImageIndex;
@end

@implementation UIImageView (CIGAM)

CIGAMSynthesizeIdStrongProperty(qimgv_animatedImageLayer, setQimgv_animatedImageLayer)
CIGAMSynthesizeIdStrongProperty(qimgv_displayLink, setQimgv_displayLink)
CIGAMSynthesizeIdStrongProperty(qimgv_animatedImage, setQimgv_animatedImage)
CIGAMSynthesizeNSIntegerProperty(qimgv_currentAnimatedImageIndex, setQimgv_currentAnimatedImageIndex)

- (void)qimgv_swizzleMethods {
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
                    if (image != selfObject.qimgv_animatedImage) {
                        callSuperBlock(nil);
                        selfObject.qimgv_animatedImage = image;
                        [selfObject qimgv_requestToStartAnimation];
                    }
                } else {
                    selfObject.qimgv_animatedImage = nil;
                    [selfObject qimgv_stopAnimating];
                    callSuperBlock(image);
                }
            };
        });
        
        OverrideImplementation([UIImageView class], @selector(image), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UIImageView *selfObject) {
                if (selfObject.qimgv_animatedImage) {
                    return selfObject.qimgv_animatedImage;
                }
                
                // call super
                UIImage *(*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIImage *(*)(id, SEL))originalIMPProvider();
                UIImage *result = originSelectorIMP(selfObject, originCMD);
                
                return result;
            };
        });

        ExtendImplementationOfVoidMethodWithoutArguments([UIImageView class], @selector(layoutSubviews), ^(UIImageView *selfObject) {
            if (selfObject.qimgv_animatedImageLayer) {
                selfObject.qimgv_animatedImageLayer.frame = selfObject.bounds;
            }
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UIImageView class], @selector(didMoveToWindow), ^(UIImageView *selfObject) {
            [selfObject qimgv_updateAnimationStateAutomatically];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setHidden:), BOOL, ^(UIImageView *selfObject, BOOL hidden) {
            [selfObject qimgv_updateAnimationStateAutomatically];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setAlpha:), CGFloat, ^(UIImageView *selfObject, CGFloat alpha) {
            [selfObject qimgv_updateAnimationStateAutomatically];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setFrame:), CGRect, ^(UIImageView *selfObject, CGRect frame) {
            [selfObject qimgv_updateAnimationStateAutomatically];
        });
        
        OverrideImplementation([UIImageView class], @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UIImageView *selfObject, CGSize size) {
                
                if (selfObject.qimgv_animatedImage) {
                    return selfObject.qimgv_animatedImage.size;
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, size);
                return result;
            };
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIImageView class], @selector(setContentMode:), UIViewContentMode, ^(UIImageView *selfObject, UIViewContentMode firstArgv) {
            if (selfObject.qimgv_animatedImageLayer) {
                selfObject.qimgv_animatedImageLayer.contentsGravity = [CIGAMHelper layerContentsGravityWithContentMode:firstArgv];
            }
        });
    } oncePerIdentifier:@"UIImageView (CIGAM) smoothAnimation"];
}

- (BOOL)qimgv_requestToStartAnimation {
    if (![self qimgv_canStartAnimation]) return NO;
    
    if (!self.qimgv_animatedImageLayer) {
        self.qimgv_animatedImageLayer = [CALayer layer];
        self.qimgv_animatedImageLayer.contentsGravity = [CIGAMHelper layerContentsGravityWithContentMode:self.contentMode];
        [self.layer addSublayer:self.qimgv_animatedImageLayer];
    }
    
    if (!self.qimgv_displayLink) {
        self.qimgv_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [self.qimgv_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        NSInteger preferredFramesPerSecond = self.qimgv_animatedImage.images.count / self.qimgv_animatedImage.duration;
        self.qimgv_displayLink.preferredFramesPerSecond = preferredFramesPerSecond;
        self.qimgv_currentAnimatedImageIndex = -1;
        self.qimgv_animatedImageLayer.contents = (__bridge id)self.qimgv_animatedImage.images.firstObject.CGImage;// 对于那种一开始就 pause 的图，displayLayer: 不会被调用，所以看不到图，为了避免这种情况，手动先把第一帧显示出来
    }
    
    self.qimgv_displayLink.paused = self.cigam_pause;
    
    return YES;
}

- (void)qimgv_stopAnimating {
    if (self.qimgv_displayLink) {
        [self.qimgv_displayLink invalidate];
        self.qimgv_displayLink = nil;
    }
    if (self.qimgv_animatedImageLayer) {
        [self.qimgv_animatedImageLayer removeFromSuperlayer];
        self.qimgv_animatedImageLayer = nil;
    }
}

- (void)qimgv_updateAnimationStateAutomatically {
    if (self.qimgv_animatedImage) {
        if (![self qimgv_requestToStartAnimation]) {
            [self qimgv_stopAnimating];
        }
    }
}

- (BOOL)qimgv_canStartAnimation {
    return self.cigam_visible && !CGRectIsEmpty(self.frame);
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    self.qimgv_currentAnimatedImageIndex = self.qimgv_currentAnimatedImageIndex < self.qimgv_animatedImage.images.count - 1 ? (self.qimgv_currentAnimatedImageIndex + 1) : 0;
    self.qimgv_animatedImageLayer.contents = (__bridge id)self.qimgv_animatedImage.images[self.qimgv_currentAnimatedImageIndex].CGImage;
}

static char kAssociatedObjectKey_smoothAnimation;
- (void)setCigam_smoothAnimation:(BOOL)cigam_smoothAnimation {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_smoothAnimation, @(cigam_smoothAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cigam_smoothAnimation) {
        [self qimgv_swizzleMethods];
    }
    if (cigam_smoothAnimation && self.image.images && self.image != self.qimgv_animatedImage) {
        self.image = self.image;// 重新设置图片，触发动画
    } else if (!cigam_smoothAnimation && self.qimgv_animatedImage) {
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
        self.qimgv_animatedImageLayer.cigam_pause = cigam_pause;
    }
    if (self.qimgv_displayLink) {
        self.qimgv_displayLink.paused = cigam_pause;
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
