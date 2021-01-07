//
//  YZAddressBookViewController.h
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUINewFriendViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZAddressBookViewController : UIViewController
@property(nonatomic, strong)TUINewFriendViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
