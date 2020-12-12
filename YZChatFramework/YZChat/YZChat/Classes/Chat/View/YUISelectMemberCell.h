//
//  YUISelectMemberCell.h
//  YChat
//
//  Created by magic on 2020/10/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
#import "MMLayout/UIView+MMLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface YUISelectMemberCell : UITableViewCell

- (void)fillWithData:(UserModel *)model isSelect:(BOOL)isSelect;

@end

NS_ASSUME_NONNULL_END
