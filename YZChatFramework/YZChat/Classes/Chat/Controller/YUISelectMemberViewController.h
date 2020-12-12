//
//  YUISelectMemberViewController.h
//  YChat
//
//  Created by magic on 2020/10/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
//@import ImSDK;
#import <ImSDKForiOS/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

// 可选样式
typedef NS_ENUM(NSInteger, TUISelectMemberOptionalStyle) {
    TUISelectMemberOptionalStyleNone = 0,
    TUISelectMemberOptionalStyleAtAll  = 1 << 0  // 包含所有人选项，用在@场景
};

typedef void(^SelectedFinished)(NSMutableArray <UserModel *> *modelList);

@interface YUISelectMemberViewController : UIViewController

@property(nonatomic,copy) NSString *groupId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,strong) SelectedFinished selectedFinished;
@property(nonatomic,assign) TUISelectMemberOptionalStyle optionalStyle;

@end

NS_ASSUME_NONNULL_END
