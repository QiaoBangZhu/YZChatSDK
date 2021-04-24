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

- (void)setupSubviews;
- (void)subscribe;

- (void)showEmptyViewWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
