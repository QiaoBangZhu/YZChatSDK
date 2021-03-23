//
//  YTextFieldInputView.h
//  YChat
//
//  Created by magic on 2020/10/6.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
   YTextInputTypeNormal,
   YTextInputTypePhone,
   YTextInputTypeCode,
}YTextInputType;

@protocol YTextFieldInputViewDelegate <NSObject>

@optional
- (void)selectedCodeBtn:(UIButton *)btn;
@end


@interface YTextFieldInputView : UIView
@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, assign)YTextInputType type;
@property (nonatomic, assign)id<YTextFieldInputViewDelegate>delegate;

- (instancetype)initWith:(YTextInputType)type;

@end

