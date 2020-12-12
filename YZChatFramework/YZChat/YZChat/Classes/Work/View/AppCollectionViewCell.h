//
//  AppCollectionViewCell.h
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkZoneModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppCollectionViewCell : UICollectionViewCell

- (void)cellData:(AppInfoModel*)appInfo;

@end

NS_ASSUME_NONNULL_END
