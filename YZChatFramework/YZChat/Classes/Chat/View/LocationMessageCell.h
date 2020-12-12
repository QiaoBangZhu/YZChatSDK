//
//  LocationMessageCell.h
//  YChat
//
//  Created by magic on 2020/11/14.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCell.h"
#import "LocationMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN
@interface LocationMessageCell : TUIMessageCell
@property UILabel *titleLabel;
@property UILabel *addressLabel;
@property UIImageView *mapImageView;

@property LocationMessageCellData *locationData;
- (void)fillWithData:(LocationMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
