//
//  YZCommonTextImageTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/1.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"

@interface CommonTextCellData : TCommonCellData

@property UIImage  *thumbnail;
@property NSString *key;
@property NSString *value;
@property BOOL showAccessory;
@property BOOL showTopLine;
@property BOOL showCorner;
@property BOOL showTopCorner;
@property BOOL showBottomCorner;

@end

@interface YZCommonTextImageTableViewCell : TCommonTableViewCell
@property UIImageView* thumbnail;
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property UIView  *line;
@property UIImageView* accessoryImageView;

@property (readonly) CommonTextCellData *textData;

- (void)fillWithData:(CommonTextCellData *)data;

@end


