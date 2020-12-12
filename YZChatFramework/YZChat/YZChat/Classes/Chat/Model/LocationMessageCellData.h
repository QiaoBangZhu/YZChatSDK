//
//  LocationMessageCellData.h
//  YChat
//
//  Created by magic on 2020/11/13.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationMessageCellData : TUIMessageCellData
@property NSString *text;
@property UIImage *mapImage;
@property double longitude;
@property double latitude;

@end

NS_ASSUME_NONNULL_END
