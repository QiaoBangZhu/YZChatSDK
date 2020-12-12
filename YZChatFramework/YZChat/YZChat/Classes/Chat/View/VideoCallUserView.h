//
//  VideoCallUserView.h
//  YChat
//
//  Created by magic on 2020/11/25.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallUtils.h"

//typedef NS_ENUM(NSUInteger, CallViewLayoutStyle) {
//    CallViewLayoutStyleSmall,
//    CallViewLayoutStyleBig,
//};


NS_ASSUME_NONNULL_BEGIN

@interface VideoCallUserView : UIView

@property (nonatomic, strong)UIImageView *avatarImageView;
@property (nonatomic, strong)UILabel     *nicknameLabel;
//@property (nonatomic, assign)CallViewLayoutStyle layout;

//- (void)configureData:(CallUserModel *)user layout:(CallViewLayoutStyle)style;


@end

NS_ASSUME_NONNULL_END
