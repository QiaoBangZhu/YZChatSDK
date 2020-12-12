//
//  UIImage+YChatExtension.h
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#define ROUNDEDRECT_PERCENTAGE 10
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface UIImage (YChatExtension)

// 圆角
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;
+ (id)createRoundedRectImage:(UIImage*)image radius:(NSInteger)r;

// 缩放尺寸最终大小是newSize
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

// 裁剪图片
- (UIImage *) imageCroppedToRect:(CGRect)rect;
// 裁减正方形区域
- (UIImage *) squareImage;

// 按size的宽高比例截取
- (UIImage *) ImageFitInSize:(CGSize)size;

// 画水印
// 图片水印
- (UIImage *) imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

// 蒙板
- (void) drawInRect:(CGRect)rect withImageMask:(UIImage*)mask;
- (void) drawMaskedColorInRect:(CGRect)rect withColor:(UIColor*)color;

// 保存图像文件
- (BOOL) writeImageToFileAtPath:(NSString*)aPath;
// 缩放尺寸最终大小是rect.size
-(UIImage *)resizeImage:(CGRect)rect;
// 缩放尺寸最终大小比例缩放
- (UIImage *) imageReSize:(CGSize)size;

- (UIImage *)imageScaleTo:(CGFloat)scale;

// 图像旋转(角度)
- (UIImage *) imageRotatedByDegrees:(CGFloat)degrees;
// 旋转+缩放
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees withScale:(CGFloat)scale;

// 黑白
- (UIImage *)convertToGrayScale;    // 有黑底
- (UIImage *)imageWithBlackWhite;

+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (UIImage *)imageWithUrl:(NSString*)url;
@end


@interface UIImage (Border)

- (UIImage *) imageWithColoredBorder:(NSUInteger)borderThickness borderColor:(UIColor *)color withShadow:(BOOL)withShadow;
- (UIImage *) imageWithTransparentBorder:(NSUInteger)thickness;

@end

// https://github.com/mustangostang/UIImage-Resize
@interface UIImage (Resize)

- (UIImage *) resizedImageByWidth:  (NSUInteger) width;
- (UIImage *) resizedImageByHeight: (NSUInteger) height;
- (UIImage *) resizedImageWithMaximumSize: (CGSize) size;
- (UIImage *) resizedImageWithMinimumSize: (CGSize) size;


/*
 * Stretchable image
 */
- (UIImage *)stretchableImage;
- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets;

/**
 *  返回一个已经拉伸好的图片
 *
 *  @param name      图片名
 *  @param topScale  顶部需要保留的比例 0 - 1
 *  @param leftScale 左边需要保留的比例 0 - 1
 *
 *  @return 拉伸好的图片
 */
+ (UIImage *)imageWithName: (NSString *)name topScale: (CGFloat)topScale leftScale: (CGFloat)leftScale;

/**
 *  返回一个可拉伸图片，拉伸位置为正中间
 */
- (UIImage *)resizableImage;

/**
 *  返回一个圆形裁剪图片
 * @param name  图片名字
 *  @param borderWidth  边框宽度
 *  @param borderColor 边框颜色
 */
+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;


@end

@interface UIImage (MGProportionalFill)

typedef enum {
    MGImageResizeCrop,    // analogous to UIViewContentModeScaleAspectFill, i.e. "best fit" with no space around.
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale    // analogous to UIViewContentModeScaleAspectFit, i.e. scale down to fit, leaving space around if necessary.
} MGImageResizingMethod;

//按比例缩放,size 是你要把图显示到 多大区域
+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
- (UIImage *)imageToFitSize:(CGSize)size method:(MGImageResizingMethod)resizeMethod;
- (UIImage *)imageCroppedToFitSize:(CGSize)size; // uses MGImageResizeCrop
- (UIImage *)imageScaledToFitSize:(CGSize)size; // uses MGImageResizeScale
- (UIImage*)stretchImage;
@end



@interface UIImage (BlurGlass)

/*
 1.白色,参数:
 透明度 0~1,  0为白,   1为深灰色
 半径:默认30,推荐值 3   半径值越大越模糊 ,值越小越清楚
 色彩饱和度(浓度)因子:  0是黑白灰, 9是浓彩色, 1是原色  默认1.8
 “彩度”，英文是称Saturation，即饱和度。将无彩色的黑白灰定为0，最鲜艳定为9s，这样大致分成十阶段，让数值和人的感官直觉一致。
 */
- (UIImage *)imgWithLightAlpha:(CGFloat)alpha radius:(CGFloat)radius colorSaturationFactor:(CGFloat)colorSaturationFactor;
/*
 添加水印、图层叠加
 */
+ (UIImage *)createNewImageWithBg:(UIImage *)bgImage iconImage:(UIImage *)iconImage iconImageSize:(CGFloat)iconImageSize;
// 剪裁圆形图片
+ (instancetype)createCircularImage:(UIImage *)iconImage;
- (UIImage *)imgWithBlur;

@end

NS_ASSUME_NONNULL_END
