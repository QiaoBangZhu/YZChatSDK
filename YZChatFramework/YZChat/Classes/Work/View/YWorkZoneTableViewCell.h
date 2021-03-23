//
//  WorkZoneTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "YWorkZoneModel.h"

@protocol  YWorkZoneTableViewCellDelegate <NSObject>

- (void)didSelectedItem:(YAppInfoModel*)app;

@end

@interface YWorkZoneTableViewCell :TCommonTableViewCell
@property (nonatomic, assign)id<YWorkZoneTableViewCellDelegate>delegate;

- (void)cellData:(YWorkZoneModel*)model;

@end


