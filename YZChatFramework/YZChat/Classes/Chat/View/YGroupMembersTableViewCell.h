//
//  YGroupMembersTableViewCell.h
//  YChat
//
//  Created by magic on 2020/12/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGroupMembersTableViewCell : UITableViewCell

- (void)fillWithData:(UserModel *)model;

@end

NS_ASSUME_NONNULL_END
