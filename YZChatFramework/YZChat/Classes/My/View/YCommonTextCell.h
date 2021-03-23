//
//  YCommonTextCell.h
//  YChat
//
//  Created by magic on 2020/10/21.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCommonTextCellData : TCommonCellData
@property NSString *key;
@property NSString *value;
@property BOOL showAccessory;
@property BOOL showCorner;
@property BOOL showTopCorner;
@property BOOL showBottomCorner;

@end

@interface YCommonTextCell : TCommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property (readonly) YCommonTextCellData *textData;

- (void)fillWithData:(YCommonTextCellData *)data;

@end

NS_ASSUME_NONNULL_END
