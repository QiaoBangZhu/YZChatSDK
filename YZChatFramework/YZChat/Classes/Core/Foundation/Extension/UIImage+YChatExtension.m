//
//  UIImage+YChatExtension.m
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "UIImage+YChatExtension.h"
#import <Accelerate/Accelerate.h>
#import "UIImageView+WebCache.h"


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;

    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;

    CGContextMoveToPoint(context, fw, fh / 2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1); // Back to lower right

    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


@implementation UIImage (YChatExtension)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size

{
    
    @autoreleasepool {
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context,
                                       
                                       color.CGColor);
        
        CGContextFillRect(context, rect);
        
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        
        
        return img;
        
    }
}

+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithUrl:(NSString*)url {
    __block UIImage* iconImage = nil;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
//    if (![manager cachedImageExistsForURL:[NSURL URLWithString:url]]) {
//        [manager downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            if (image && finished) {
//                iconImage = image;
//            }
//        }];
//    }else{
//        return [manager.imageCache imageFromDiskCacheForKey:url];
//    }
    return iconImage;
}

// 圆角
+ (id)createRoundedRectImage:(UIImage *)image size:(CGSize)size radius:(NSInteger)r {
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;

    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);

    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);

    return img;
}

+ (id)createRoundedRectImage:(UIImage *)image radius:(NSInteger)r {
    // the size of CGContextRef
    int w = image.size.width;
    int h = image.size.height;

    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);

    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);

    return img;
}

// 裁剪图片
- (UIImage *)imageCroppedToRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

// 裁减正方形区域
- (UIImage *)squareImage {
    CGFloat min = self.size.width <= self.size.height ? self.size.width : self.size.height;
    return [self imageCroppedToRect:CGRectMake(0, 0, min, min)];
}

// 按size的宽高比例截取
- (UIImage *)ImageFitInSize:(CGSize)size {
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;

    if (self.size.width <= self.size.height) {
        CGFloat scale = self.size.width / size.width;

        x = 0;
        y = (self.size.height - size.height * scale) / 2;

        width = self.size.width;
        height = size.height * scale;
    }
    else {
        CGFloat scale = self.size.height / size.height;

        x = (self.size.width - size.width * scale) / 2;
        y = 0;

        width = size.width * scale;
        height = self.size.width;
    }

    return [self imageCroppedToRect:CGRectMake(x, y, width, height)];
}

- (UIImage *)imageReSize:(CGSize)size {
    CGFloat width;
    CGFloat height;

    if (self.size.width >= self.size.height) {
        CGFloat scale = size.width / self.size.width;

        width = self.size.width * scale;
        height = self.size.height * scale;
    }
    else {
        CGFloat scale = size.height / self.size.height;

        width = self.size.width * scale;
        height = self.size.width * scale;
    }

    return [self resizeImage:CGRectMake(0, 0, width, height)];
}

// 画水印
- (UIImage *)imageWithWaterMask:(UIImage *)mask inRect:(CGRect)rect {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([self size]);
    }
#endif

    //原图
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //水印图
    [mask drawInRect:rect];

    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newPic;
}

- (void)drawInRect:(CGRect)rect withImageMask:(UIImage *)mask {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);

    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    rect.origin.y = rect.origin.y * -1;

    CGContextClipToMask(context, rect, mask.CGImage);
    CGContextDrawImage(context, rect, self.CGImage);

    CGContextRestoreGState(context);
}

- (void)drawMaskedColorInRect:(CGRect)rect withColor:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetFillColorWithColor(context, color.CGColor);

    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    rect.origin.y = rect.origin.y * -1;

    CGContextClipToMask(context, rect, self.CGImage);
    CGContextFillRect(context, rect);

    CGContextRestoreGState(context);
}

- (BOOL)writeImageToFileAtPath:(NSString *)aPath {
    if ((aPath == nil) || ([aPath isEqualToString:@""])) {
        return NO;
    }

    @try {
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        if ([ext isEqualToString:@"png"]) {
            imageData = UIImagePNGRepresentation(self);
        }
        else {
            // the rest, we write to jpeg
            // 0. best, 1. lost. about compress.
            imageData = UIImageJPEGRepresentation(self, 0);
        }

        if ((imageData == nil) || ([imageData length] <= 0)) {
            return NO;
        }

        [imageData writeToFile:aPath atomically:YES];

        return YES;
    }
    @catch (NSException *e) {
        //NSLog(@"create thumbnail exception.");
    }

    return NO;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);

    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

    // Get the new image from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    // End the context
    UIGraphicsEndImageContext();

    // Return the new image.
    return newImage;
}

- (UIImage *)resizeImage:(CGRect)rect {
    //根据size大小创建一个基于位图的图形上下文
    //UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 2);
    
    //获取当前quartz 2d绘图环境
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置当前绘图环境到矩形框
    CGContextClipToRect(currentContext, rect);
    [self drawInRect:rect];
    //获得图片
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();

    //从当前堆栈中删除quartz 2d绘图环境
    UIGraphicsEndImageContext();

    return cropped;
}

CGFloat KHDegreesToRadians(CGFloat degrees);

CGFloat KHRadiansToDegrees(CGFloat radians);


CGFloat KHDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
};

CGFloat KHRadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};

- (UIImage *)imageScaleTo:(CGFloat)scale
{
    if (scale > 0.99f) {
        return self;
    }
    // calculate the size of the rotated view's containing box for our drawing space
    UIView              *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width * scale, self.size.height * scale)];
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 2);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, scale, -scale);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    __unused size_t imageSize = CGImageGetBytesPerRow(newImage.CGImage) * CGImageGetHeight(newImage.CGImage);
    return newImage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(KHDegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    //    [rotatedViewBox release];

    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    //   // Rotate the image context
    CGContextRotateCTM(bitmap, KHDegreesToRadians(degrees));

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees withScale:(CGFloat)scale
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView              *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGAffineTransform   t = CGAffineTransformMakeRotation(KHDegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    //   rotatedViewBox.transform = CGAffineTransformScale(t, scale, scale);
    //   transform = CGAffineTransformMakeScale(-1.0, 1.0);
    //   transform = CGAffineTransformRotate(transform, M_PI / 2.0);
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, self.scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    //   // Rotate the image context
    CGContextRotateCTM(bitmap, KHDegreesToRadians(degrees));

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, scale, -scale);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)convertToGrayScale {
    /* const UInt8 luminance = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722); // Good luminance value */
    /// Create a gray bitmap context
    const size_t width = (size_t) self.size.width;
    const size_t height = (size_t) self.size.height;

    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, width * 3, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (!bmContext)
        return nil;

    /// Image quality
    CGContextSetShouldAntialias(bmContext, false);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);

    /// Draw the image in the bitmap context
    CGContextDrawImage(bmContext, imageRect, self.CGImage);

    /// Create an image object from the context
    CGImageRef grayscaledImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage *grayscaled = [UIImage imageWithCGImage:grayscaledImageRef scale:self.scale orientation:self.imageOrientation];

    /// Cleanup
    CGImageRelease(grayscaledImageRef);
    CGContextRelease(bmContext);

    return grayscaled;
}

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;


- (UIImage *)imageWithBlackWhite {
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;

    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));

    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);

    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);


    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];

            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }

    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);

    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);

    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];

    // we're done with image now too
    CGImageRelease(image);

    return resultUIImage;
}

@end


static CGImageRef CreateMask(CGSize size, NSUInteger thickness) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
            size.width,
            size.height,
            8,
            size.width * 32,
            colorSpace,
            kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    if (bitmapContext == NULL) {
        //NSLog(@"create mask bitmap context failed");
        CGColorSpaceRelease(colorSpace);
        return nil;
    }

    // fill the black color in whole size, anything in black area will be transparent.
    CGContextSetFillColorWithColor(bitmapContext, [UIColor blackColor].CGColor);
    CGContextFillRect(bitmapContext, CGRectMake(0, 0, size.width, size.height));

    // fill the white color in whole size, anything in white area will keep.
    CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(bitmapContext, CGRectMake(thickness, thickness, size.width - thickness * 2, size.height - thickness * 2));

    // acquire the mask
    CGImageRef maskImageRef = CGBitmapContextCreateImage(bitmapContext);

    // clean up
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);

    return maskImageRef;
}

@implementation UIImage (Border)

- (UIImage *)imageWithColoredBorder:(NSUInteger)borderThickness borderColor:(UIColor *)color withShadow:(BOOL)withShadow {
    size_t shadowThickness = 0;
    if (withShadow) {
        shadowThickness = 2;
    }

    size_t newWidth = self.size.width + 2 * borderThickness + 2 * shadowThickness;
    size_t newHeight = self.size.height + 2 * borderThickness + 2 * shadowThickness;
    CGRect imageRect = CGRectMake(borderThickness + shadowThickness, borderThickness + shadowThickness, self.size.width, self.size.height);

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetShadow(ctx, CGSizeZero, 4.5f);
    [color setFill];
    CGContextFillRect(ctx, CGRectMake(shadowThickness, shadowThickness, newWidth - 2 * shadowThickness, newHeight - 2 * shadowThickness));
    CGContextRestoreGState(ctx);
    [self drawInRect:imageRect];
    //CGContextDrawImage(ctx, imageRect, self.CGImage); //if use this method, image will be filp vertically
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}

- (UIImage *)imageWithTransparentBorder:(NSUInteger)thickness {
    size_t newWidth = self.size.width + 2 * thickness;
    size_t newHeight = self.size.height + 2 * thickness;

    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = bitsPerPixel * newWidth;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        //NSLog(@"create color space failed");
        return nil;
    }

    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
            newWidth,
            newHeight,
            bitsPerComponent,
            bytesPerRow,
            colorSpace,
            kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    if (bitmapContext == NULL) {
        //NSLog(@"create bitmap context failed");
        CGColorSpaceRelease(colorSpace);
        return nil;
    }

    // acquire image with opaque border
    CGRect imageRect = CGRectMake(thickness, thickness, self.size.width, self.size.height);
    CGContextDrawImage(bitmapContext, imageRect, self.CGImage);
    CGImageRef opaqueBorderImageRef = CGBitmapContextCreateImage(bitmapContext);

    // acquire image with transparent border
    CGImageRef maskImageRef = CreateMask(CGSizeMake(newWidth, newHeight), thickness);
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(opaqueBorderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];

    // clean up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
    CGImageRelease(opaqueBorderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);

    return transparentBorderImage;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    return [self imageRotatedByDegrees:KHRadiansToDegrees(radians)];
}


@end


@implementation UIImage (Resize)

- (CGImageRef)CGImageWithCorrectOrientation {
//    if (self.imageOrientation == UIImageOrientationDown) {
//        return [self CGImage];
//    }
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


- (UIImage *)resizedImageByWidth:(NSUInteger)width {
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat ratio = width / original_width;
    CGImageRelease(imgRef);
    return [self drawImageInBounds:CGRectMake(0, 0, width, round(original_height * ratio))];
}

- (UIImage *)resizedImageByHeight:(NSUInteger)height {
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat ratio = height / original_height;
    CGImageRelease(imgRef);
    return [self drawImageInBounds:CGRectMake(0, 0, round(original_width * ratio), height)];
}

- (UIImage *)resizedImageWithMinimumSize:(CGSize)size {
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds:CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
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

- (UIImage *)drawImageInBounds:(CGRect)bounds {
    UIGraphicsBeginImageContext(bounds.size);
    [self drawInRect:bounds];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)croppedImageWithRect:(CGRect)rect {

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self drawInRect:drawRect];
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return subImage;
}

//拉伸图片
- (UIImage *)stretchableImage {
    CGFloat semiHeight = floor(self.size.height/2.0);
    if (semiHeight<1.0) semiHeight = 1.0;
    
    CGFloat semiWidth = floor(self.size.width/2.0);
    if (semiWidth<1.0) semiWidth = 1.0;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(semiHeight-1.0, semiWidth-1.0, semiHeight-1.0, semiWidth-1.0);
    return [self stretchableImageWithCapInsets:edgeInsets];
}

- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets {
   
    return [self resizableImageWithCapInsets:capInsets];
}

+ (UIImage *)imageWithName:(NSString *)name topScale:(CGFloat)topScale leftScale:(CGFloat)leftScale
{
    UIImage *normal = [UIImage imageNamed:name];
    
    CGFloat top = normal.size.height * topScale;
    CGFloat left = normal.size.width * leftScale;
    CGFloat bottom = normal.size.height * (1 - topScale) - 1;
    CGFloat right = normal.size.width * (1 - leftScale) - 1;
    
    return  [normal resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

#pragma mark 返回可拉伸图片
- (UIImage *)resizableImage
{
    CGFloat top = self.size.height * 0.5;
    CGFloat left = self.size.width * 0.5;
    CGFloat bottom = self.size.height * 0.5-1;
    CGFloat right = self.size.width * 0.5-1;
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 1.加载原图
    UIImage *oldImage = [UIImage imageNamed:name];
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIImage (MGProportionalFill)

//按比例缩放,size 是你要把图显示到 多大区域
+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
            
        }
        else{
            
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageToFitSize:(CGSize)fitSize method:(MGImageResizingMethod)resizeMethod {
    float imageScaleFactor = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if ([self respondsToSelector:@selector(scale)]) {
        imageScaleFactor = [self scale];
    }
#endif

    float sourceWidth = [self size].width * imageScaleFactor;
    float sourceHeight = [self size].height * imageScaleFactor;
    float targetWidth = fitSize.width;
    float targetHeight = fitSize.height;
    BOOL cropping = !(resizeMethod == MGImageResizeScale);

    // Calculate aspect ratios
    float sourceRatio = sourceWidth / sourceHeight;
    float targetRatio = targetWidth / targetHeight;

    // Determine what side of the source image to use for proportional scaling
    BOOL scaleWidth = (sourceRatio <= targetRatio);
    // Deal with the case of just scaling proportionally to fit, without cropping
    scaleWidth = (cropping) ? scaleWidth : !scaleWidth;

    // Proportionally scale source image
    float scalingFactor, scaledWidth, scaledHeight;
    if (scaleWidth) {
        scalingFactor = 1.0 / sourceRatio;
        scaledWidth = targetWidth;
        scaledHeight = round(targetWidth * scalingFactor);
    } else {
        scalingFactor = sourceRatio;
        scaledWidth = round(targetHeight * scalingFactor);
        scaledHeight = targetHeight;
    }
    float scaleFactor = scaledHeight / sourceHeight;

    // Calculate compositing rectangles
    CGRect sourceRect, destRect;
    if (cropping) {
        destRect = CGRectMake(0, 0, targetWidth, targetHeight);
        float destX = 0.0f, destY = 0.0f;
        if (resizeMethod == MGImageResizeCrop) {
            // Crop center
            destX = round((scaledWidth - targetWidth) / 2.0);
            destY = round((scaledHeight - targetHeight) / 2.0);
        } else if (resizeMethod == MGImageResizeCropStart) {
            // Crop top or left (prefer top)
            if (scaleWidth) {
                // Crop top
                destX = 0.0;
                destY = 0.0;
            } else {
                // Crop left
                destX = 0.0;
                destY = round((scaledHeight - targetHeight) / 2.0);
            }
        } else if (resizeMethod == MGImageResizeCropEnd) {
            // Crop bottom or right
            if (scaleWidth) {
                // Crop bottom
                destX = round((scaledWidth - targetWidth) / 2.0);
                destY = round(scaledHeight - targetHeight);
            } else {
                // Crop right
                destX = round(scaledWidth - targetWidth);
                destY = round((scaledHeight - targetHeight) / 2.0);
            }
        }
        sourceRect = CGRectMake(destX / scaleFactor, destY / scaleFactor,
                targetWidth / scaleFactor, targetHeight / scaleFactor);
    } else {
        sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
        destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
    }

    // Create appropriately modified image.
    UIImage *image = nil;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    CGImageRef sourceImg = nil;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(destRect.size, NO, 0.f); // 0.f for scale means "scale for device's main screen".
        sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
        image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation]; // create cropped UIImage.

    } else {
        UIGraphicsBeginImageContext(destRect.size);
        sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
        image = [UIImage imageWithCGImage:sourceImg]; // create cropped UIImage.
    }

    CGImageRelease(sourceImg);
    [image drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif

    if (!image) {
        // Try older method.
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, 8, (scaledWidth * 4),
                colorSpace, kCGImageAlphaPremultipliedLast);
        CGImageRef sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect);
        CGContextDrawImage(context, destRect, sourceImg);
        CGImageRelease(sourceImg);
        CGImageRef finalImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        image = [UIImage imageWithCGImage:finalImage];
        CGImageRelease(finalImage);
    }

    return image;
}


- (UIImage *)imageCroppedToFitSize:(CGSize)fitSize {
    return [self imageToFitSize:fitSize method:MGImageResizeCrop];
}


- (UIImage *)imageScaledToFitSize:(CGSize)fitSize {
    return [self imageToFitSize:fitSize method:MGImageResizeScale];
}


- (UIImage *)stretchImage {
    return [self stretchableImageWithLeftCapWidth:floorf(self.size.width / 2) topCapHeight:floorf(self.size.height / 2)];
}

@end


@implementation UIImage (BlurGlass)

- (UIImage *)imgWithBlur
{
    return [self imgWithLightAlpha:0.01 radius:10 colorSaturationFactor:1];
}

- (UIImage *)imgWithLightAlpha:(CGFloat)alpha radius:(CGFloat)radius colorSaturationFactor:(CGFloat)colorSaturationFactor
{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:alpha];
    return [self imgBluredWithRadius:radius tintColor:tintColor saturationDeltaFactor:colorSaturationFactor maskImage:nil];
}

// 绘制图片
+ (UIImage *)createNewImageWithBg:(UIImage *)bgImage iconImage:(UIImage *)iconImage iconImageSize:(CGFloat)iconImageSize {
    // 1.开启图片上下文
    UIGraphicsBeginImageContext(bgImage.size);
    
    // 2.绘制背景
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    // 3.绘制图标
    CGFloat imageW = iconImageSize;
    CGFloat imageH = iconImageSize;
    CGFloat imageX = (bgImage.size.width - imageW) * 0.5;
    CGFloat imageY = (bgImage.size.height - imageH) * 0.5;
    [iconImage drawInRect:CGRectMake(imageX, imageY, imageW, imageH)];
    
    // 4.取出绘制好的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 5.关闭上下文
    UIGraphicsEndImageContext();
    // 6.返回生成好得图片
    return newImage;
}

// 剪裁圆形图片
+ (instancetype)createCircularImage:(UIImage *)iconImage{
    // 1. 创建一个bitmap类型图形上下文（空白的UiImage）
    // NO 将来创建的透明的UiImage
    // YES 不透明
    UIGraphicsBeginImageContextWithOptions(iconImage.size, NO, 0);
    
    // 2. 指定可用范围
    // 2.1 获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 2.2 画圆
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, iconImage.size.width, iconImage.size.height));
    // 2.3 裁剪，指定将来可以画图的可用范围
    CGContextClip(ctx);
    
    // 3. 绘制图片
    [iconImage drawInRect:CGRectMake(0, 0, iconImage.size.width, iconImage.size.height)];
    
    // 4. 取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.1 关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}

// 内部方法,核心代码,封装了毛玻璃效果 参数:半径,颜色,色彩饱和度
- (UIImage *)imgBluredWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (int)radius, (int)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (int)radius, (int)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (int)radius, (int)radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // 开启上下文 用于输出图像
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // 开始画底图
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // 开始画模糊效果
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // 添加颜色渲染
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // 输出成品,并关闭上下文
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
