//
//  YzCustomMessageCell.h
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import <UIKit/UIKit.h>

#import "TUIMessageCell.h"
#import "YzCustomMessageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzCustomMessageCell : TUIMessageCell

@property (nonatomic, assign) Class customViewClass;
@property (nonatomic, strong) YzCustomMessageView *customView;

@end

NS_ASSUME_NONNULL_END
