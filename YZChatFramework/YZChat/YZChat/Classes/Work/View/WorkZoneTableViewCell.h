//
//  WorkZoneTableViewCell.h
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "TCommonCell.h"
#import "WorkZoneModel.h"

@protocol  WorkZoneTableViewCellDelegate <NSObject>

- (void)didSelectedItem:(AppInfoModel*)app;

@end

@interface WorkZoneTableViewCell :TCommonTableViewCell
@property (nonatomic, assign)id<WorkZoneTableViewCellDelegate>delegate;

- (void)cellData:(WorkZoneModel*)model;

@end


