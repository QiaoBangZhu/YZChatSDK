//
//  ButtonTableViewCell.h
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"

typedef enum : NSUInteger {
    BtnGreen,
    BtnBlueText,
    BtnRedText,
    BtnBlue,
} BtnStyle;

@interface ButtonCellData : TCommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property BtnStyle style;
@property (nonatomic, assign) BOOL hasLine;
@end

@interface ButtonTableViewCell : TCommonTableViewCell
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView   *line;
@property ButtonCellData *buttonData;

- (void)fillWithData:(ButtonCellData *)data;

@end


