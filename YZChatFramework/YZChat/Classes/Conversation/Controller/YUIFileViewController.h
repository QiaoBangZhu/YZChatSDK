//
//  YUIFileViewController.h
//  YChat
//
//  Created by magic on 2020/10/15.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIFileMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YUIFileViewController : UIViewController
@property (nonatomic, strong) TUIFileMessageCellData *data;

@end

NS_ASSUME_NONNULL_END
