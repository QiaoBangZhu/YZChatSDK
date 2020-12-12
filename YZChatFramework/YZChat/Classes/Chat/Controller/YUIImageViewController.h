//
//  YUIImageViewController.h
//  YChat
//
//  Created by magic on 2020/10/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIImageMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YUIImageViewController : UIViewController
@property (nonatomic, strong) TUIImageMessageCellData *data;

@end

NS_ASSUME_NONNULL_END
