//
//  YZLocationMessageCell.h
//  YChat
//
//  Created by magic on 2020/11/14.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCell.h"
#import "YZLocationMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN
@interface YZLocationMessageCell : TUIMessageCell
@property UILabel *titleLabel;
@property UILabel *addressLabel;
@property UIImageView *mapImageView;
@property UIImageView *shadowImageView;

@property YZLocationMessageCellData *locationData;
- (void)fillWithData:(YZLocationMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
