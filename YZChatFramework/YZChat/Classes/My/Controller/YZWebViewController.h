//
//  YZWebViewController.h
//  YChat
//
//  Created by magic on 2020/10/8.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWorkZoneModel.h"

#import "YzCommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZWebViewController : YzCommonViewController
@property(nonatomic, copy)NSURL * url;
@property(nonatomic, assign)BOOL needUA;
@property(nonatomic, assign)BOOL hiddenCloseBtn;

@end

NS_ASSUME_NONNULL_END
