//
//  MapListTableViewCell.h
//  YChat
//
//  Created by magic on 2020/11/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapListTableViewCell : UITableViewCell
@property (nonatomic, strong)UIImageView* checkbox;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *subTitleLabel;

@end

NS_ASSUME_NONNULL_END
