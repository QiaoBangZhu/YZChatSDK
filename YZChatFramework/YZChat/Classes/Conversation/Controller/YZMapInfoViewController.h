//
//  YZMapInfoViewController.h
//  YChat
//
//  Created by magic on 2020/11/16.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZLocationMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZMapInfoViewController : UIViewController
@property (nonatomic, strong) YZLocationMessageCellData *locationData;

@end

NS_ASSUME_NONNULL_END
