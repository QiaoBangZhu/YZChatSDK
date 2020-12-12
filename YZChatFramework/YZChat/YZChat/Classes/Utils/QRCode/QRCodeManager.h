//
//  QRCodeManager.h
//  YChat
//
//  Created by magic on 2020/11/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeManager : NSObject

+ (UIImage *)getQRCodeImage:(NSString *)content;

+ (NSString *)decodeQRCodeImage:(UIImage *)image;

/**
 校验是否有相机权限

 @param permissionGranted 获取相机权限回调
 */
+ (void)rcd_checkCameraAuthorizationStatusWithGrand:(void (^)(BOOL granted))permissionGranted;

/**
 校验是否有相册权限

 @param permissionGranted 获取相机权限回调
 */
+ (void)rcd_checkAlbumAuthorizationStatusWithGrand:(void (^)(BOOL granted))permissionGranted;

/**
 手电筒开关
 @param on YES:打开 NO:关闭
 */
+ (void)rcd_FlashlightOn:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
