//
//  YZChooseCityViewController.h
//  YChat
//
//  Created by magic on 2020/12/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CitySelectFinishBlock)(NSString *city);

@interface YZChooseCityViewController : UIViewController

@property (nonatomic, copy)CitySelectFinishBlock finishBlock;

@end

NS_ASSUME_NONNULL_END
