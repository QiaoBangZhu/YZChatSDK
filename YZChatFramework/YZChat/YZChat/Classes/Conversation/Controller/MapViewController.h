//
//  MapViewController.h
//  YChat
//
//  Created by magic on 2020/11/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationMessageCellData.h"

typedef void (^SelectedLocationBlock) (NSString *name, NSString *address, double latitude, double longitude);

@interface MapViewController : UIViewController
@property (nonatomic, copy)SelectedLocationBlock locationBlock;


@end
