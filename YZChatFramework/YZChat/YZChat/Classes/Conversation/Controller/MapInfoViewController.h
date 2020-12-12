//
//  MapInfoViewController.h
//  YChat
//
//  Created by magic on 2020/11/16.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapInfoViewController : UIViewController
@property (nonatomic, strong) LocationMessageCellData *locationData;

@end

NS_ASSUME_NONNULL_END
