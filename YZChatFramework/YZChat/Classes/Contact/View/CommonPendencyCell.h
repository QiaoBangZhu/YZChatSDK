//
//  CommonPendencyCell.h
//  YChat
//
//  Created by magic on 2020/9/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "TCommonPendencyCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommonPendencyCell : TCommonTableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *addWordingLabel;
@property UIButton *agreeButton;

@property (nonatomic) TCommonPendencyCellData *pendencyData;

- (void)fillWithData:(TCommonPendencyCellData *)pendencyData;



@end

NS_ASSUME_NONNULL_END
