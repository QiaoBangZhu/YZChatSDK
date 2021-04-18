//
//  YBaseViewController.h
//  YChat
//
//  Created by magic on 2020/10/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CIGAMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzCommonViewController : CIGAMCommonViewController
@property (nonatomic, copy)NSString *titleName;
@property (nonatomic, assign)BOOL isFromOtherApp;
@end

NS_ASSUME_NONNULL_END