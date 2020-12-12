//
//  YPopCell.h
//  YChat
//
//  Created by magic on 2020/10/3.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPopCellData : NSObject
@property (nonatomic, strong) NSString *title;
@end

@interface YPopCell : UITableViewCell
@property (nonatomic, strong) UILabel *title;
+ (CGFloat)getHeight;
- (void)setData:(YPopCellData *)data;

@end

NS_ASSUME_NONNULL_END
