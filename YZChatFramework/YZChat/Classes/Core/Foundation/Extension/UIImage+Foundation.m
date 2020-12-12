//
//  UIImage+Foundation.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "UIImage+Foundation.h"

static NSCache *imageCache;

@implementation UIImage (Foundation)

- (UIImage *)stretchImage {
    return [self stretchableImageWithLeftCapWidth:floorf(self.size.width / 2) topCapHeight:floorf(self.size.height / 2)];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
    });
    
    UIImage *image = [imageCache objectForKey:color];
    if (image) {
        return image;
    }
    
    image = [self imageWithColor:color size:CGSizeMake(1,1)];
    [imageCache setObject:image forKey:color];
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


+ (UIImage *)resizableImageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    CGFloat minEdgeSize = cornerRadius * 2 + 1;
    CGRect rect = CGRectMake(0, 0, minEdgeSize, minEdgeSize);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

- (CGImageRef)CGImageWithCorrectOrientation {
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, 90 * M_PI/ 180);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM(context, -90 * M_PI/ 180);
    } else if (self.imageOrientation == UIImageOrientationUp) {
        CGContextRotateCTM(context, 180 * M_PI/ 180);
    }
    
    [self drawAtPoint:CGPointMake(0, 0)];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return cgImage;
}

- (UIImage *)drawImageInBounds:(CGRect)bounds {
    UIGraphicsBeginImageContext(bounds.size);
    [self drawInRect:bounds];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)resizedImageWithMaximumSize:(CGSize)size {
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio < height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds:CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

- (UIImage * _Nullable)resizeToSize:(CGSize)newSize contentMode:(UIViewContentMode)contentMode {
    if (CGSizeEqualToSize(newSize, CGSizeZero)) {
        return nil;
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat contextWidth = newSize.width * screenScale;
    CGFloat contextHeight = newSize.height * screenScale;
    
    switch (contentMode) {
        case UIViewContentModeCenter:
        {
            x = (newSize.width - width) / 2;
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeTop:
        {
            x = (newSize.width - width) / 2;
            y = (newSize.height - height);
        }
            break;
        case UIViewContentModeBottom:
        {
            x = (newSize.width - width) / 2;
        }
            break;
        case UIViewContentModeLeft:
        {
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeRight:
        {
            x = (newSize.width - width);
            y = (newSize.height - height) / 2;;
        }
            break;
        case UIViewContentModeTopLeft:
        {
            y = (newSize.height - height);
        }
            break;
        case UIViewContentModeTopRight:
        {
            x = (newSize.width - width);
            y = (newSize.height - height);
        }
            break;
        case UIViewContentModeBottomLeft:
            break;
        case UIViewContentModeBottomRight:
        {
            x = (newSize.width - width);
        }
            break;
        case UIViewContentModeScaleAspectFit:
        {
            CGFloat widthRatio = newSize.width / width;
            CGFloat heightRatio = newSize.height / height;
            CGFloat ratio = MIN(widthRatio, heightRatio);
            
            width = width * ratio;
            height = height * ratio;
            x = (newSize.width - width) / 2;
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeScaleAspectFill:
        {
            CGFloat widthRatio = newSize.width / width;
            CGFloat heightRatio = newSize.height / height;
            CGFloat ratio = MAX(widthRatio, heightRatio);
            
            width = width * ratio;
            height = height * ratio;
            x = (newSize.width - width) / 2;
            y = (newSize.height - height) / 2;
        }
            break;
        case UIViewContentModeScaleToFill:
        default:
        {
            width = newSize.width;
            height = newSize.height;
        }
            break;
    }
    
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    
    //这里 context 大小为像素大小
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, contextWidth, contextHeight, 8, 0, colourSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShouldAntialias(bitmapContext, true);
    CGContextSetAllowsAntialiasing(bitmapContext, true);
    CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationHigh);
    
    //之前计算都是用 pt，绘制时要转成 px
    CGContextDrawImage(bitmapContext, CGRectMake(x * screenScale, y * screenScale, width * screenScale, height * screenScale), self.CGImage);
    
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *resizedImage = [UIImage imageWithCGImage:scaledImageRef scale:screenScale orientation:self.imageOrientation];
    
    CGImageRelease(scaledImageRef);
    CGContextRelease(bitmapContext);
    
    return resizedImage;
}


+ (UIImage * _Nullable)addImage:(UIImage *)image1 withImage:(UIImage *)image2 {
    
    UIGraphicsBeginImageContext(image1.size);
    
    [image1 drawInRect:CGRectMake(0, 0, image2.size.width, image1.size.height)];
    
    [image2 drawInRect:CGRectMake(0,0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

/**
 *  获取矩形的渐变色的UIImage(此函数还不够完善)
 *
 *  @param bounds       UIImage的bounds
 *  @param colors       渐变色数组，可以设置两种颜色
 *  @param gradientType 渐变的方式：0--->从上到下   1--->从左到右
 *
 *  @return 渐变色的UIImage
 */
+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors andGradientType:(int)gradientType{
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(0.0, 0.0);
    
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, bounds.size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(bounds.size.width, 0.0);
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageNamed:(NSString*)name ofBundle:(NSString*)bundleName {
    UIImage *image = nil;

    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];

    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];

    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];;

    image = [[UIImage alloc] initWithContentsOfFile:image_path];

    return image;
}

- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
