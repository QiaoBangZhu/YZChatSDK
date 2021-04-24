//
//  YZMapViewController.h
//  YChat
//
//  Created by magic on 2020/11/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZLocationMessageCellData.h"

#import "YzCommonViewController.h"

typedef void (^SelectedLocationBlock) (NSString *name, NSString *address, double latitude, double longitude);

@interface YZMapViewController : YzCommonViewController

@property (nonatomic, copy)SelectedLocationBlock locationBlock;

@end
