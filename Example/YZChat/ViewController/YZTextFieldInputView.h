//
//  YZTextFieldInputView.h
//  YChat
//
//  Created by magic on 2020/10/6.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
   YZTextInputTypeNormal,
   YZTextInputTypePhone,
   YZTextInputTypeCode,
}YZTextInputType;

@protocol YZTextFieldInputViewDelegate <NSObject>

@optional
- (void)selectedCodeBtn:(UIButton *)btn;
@end


@interface YZTextFieldInputView : UIView
@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, assign)YZTextInputType type;
@property (nonatomic, assign)id<YZTextFieldInputViewDelegate>delegate;

- (instancetype)initWith:(YZTextInputType)type;

@end

