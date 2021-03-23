//
//  YZMyCustomCell.h
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCell.h"
#import "YZMyCustomCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZMyCustomCell : TUIMessageCell

@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property YZMyCustomCellData *customData;
- (void)fillWithData:(YZMyCustomCellData *)data;

@end

NS_ASSUME_NONNULL_END
