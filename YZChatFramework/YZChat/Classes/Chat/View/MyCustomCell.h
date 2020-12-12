//
//  MyCustomCell.h
//  YChat
//
//  Created by magic on 2020/9/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCell.h"
#import "MyCustomCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCustomCell : TUIMessageCell

@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property MyCustomCellData *customData;
- (void)fillWithData:(MyCustomCellData *)data;

@end

NS_ASSUME_NONNULL_END
