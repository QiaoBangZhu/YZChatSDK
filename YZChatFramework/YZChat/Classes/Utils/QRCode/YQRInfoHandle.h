//
//  YQRInfoHandle.h
//  YChat
//
//  Created by magic on 2020/11/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommonConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface YQRInfoHandle : NSObject
AS_SINGLETON(YQRInfoHandle);

- (void)identifyQRCode:(NSString *)info base:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
