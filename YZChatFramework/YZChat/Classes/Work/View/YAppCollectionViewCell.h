//
//  YAppCollectionViewCell.h
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWorkZoneModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YAppCollectionViewCell : UICollectionViewCell

- (void)cellData:(YAppInfoModel*)appInfo;

@end

NS_ASSUME_NONNULL_END
