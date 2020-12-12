//
//  UIImage+Foundation.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Foundation)

- (UIImage *_Nullable)stretchImage;

/**
 Returns a 1x1 image with the single pixel set to the specified color.
 Usage Note: almost all of UIKit will stretch this UIImage when you set
 it as, eg. backgroundImage, hence you often don’t need the size variant.
 */
+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color;

/**
 Returns an image of the requested size filled with the provided color.
 */
+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color size:(CGSize)size;
+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

/**
 Returns a (minimal) resizable image with the requested corner radius and
 filled with the provided color.
 */
+ (UIImage * _Nonnull)resizableImageWithColor:(UIColor * _Nonnull)color cornerRadius:(CGFloat)cornerRadius NS_SWIFT_NAME(init(color:cornerRadius:));

- (UIImage *_Nullable)resizedImageWithMaximumSize:(CGSize)size;

- (UIImage * _Nullable)resizeToSize:(CGSize)newSize contentMode:(UIViewContentMode)contentMode;

+ (UIImage * _Nullable)addImage:(UIImage * _Nonnull)image1 withImage:(UIImage * _Nonnull)image2;

+ (UIImage* _Nullable)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray* _Nonnull)colors andGradientType:(int)gradientType;

+ (UIImage * _Nullable)imageNamed:(NSString* _Nonnull)name ofBundle:(NSString* _Nonnull)bundleName;

- (UIImage *)scaleToSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
