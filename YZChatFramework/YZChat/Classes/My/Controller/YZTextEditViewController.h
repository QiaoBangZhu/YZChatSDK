//
//  YZTextEditViewController.h
//  YChat
//
//  Created by magic on 2020/9/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EditType)
{
    EditTypeMobile = 1,
    EditTypeNickname = 2,
    EditTypeEmail = 3,
    EditTypePosition = 4,
    EditTypeDepartment = 5,
    EditTypeJobNum = 6,
    EditTypeFriendRemark = 7,
    EditTypeSignture = 8,
};

NS_ASSUME_NONNULL_BEGIN

@interface YZTextEditViewController : UIViewController
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic,   copy) NSString    * textValue;
@property (nonatomic, assign) EditType      type;

- (instancetype)initWithText:(NSString *)text editType:(EditType)type;

@end

NS_ASSUME_NONNULL_END
