//
//  YZLocationMessageCellData.h
//  YChat
//
//  Created by magic on 2020/11/13.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZLocationMessageCellData : TUIMessageCellData
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *mapImage;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@end

NS_ASSUME_NONNULL_END
