//
//  YUIButtonTableViewCell.h
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    YButtonGreen,
    YButtonWhite,
    YButtonRedText,
    YButtonBlue,
} YUIButtonStyle;

@interface YUIButtonCellData : TCommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property YUIButtonStyle style;
@end


@interface YUIButtonTableViewCell : TCommonTableViewCell
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView   *shadowView;

@property YUIButtonCellData *buttonData;

- (void)fillWithData:(YUIButtonCellData *)data;
@end

NS_ASSUME_NONNULL_END
