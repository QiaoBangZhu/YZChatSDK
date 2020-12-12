//
//  AudioMeetUserCell.h
//  YChat
//
//  Created by magic on 2020/11/1.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioMeetUserCell : UICollectionViewCell
- (void)fillWithData:(CallUserModel *)model;

@end

NS_ASSUME_NONNULL_END
