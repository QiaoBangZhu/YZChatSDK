//
//  YZTextFieldInputView.h
//  YChat
//
//  Created by magic on 2020/10/6.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
   TextInputTypeNormal,
   TextInputTypePhone,
   TextInputTypeCode,
}TextInputType;

@protocol TextFieldInputViewDelegate <NSObject>

@optional
- (void)selectedCodeBtn:(UIButton *)btn;
@end


@interface YZTextFieldInputView : UIView
@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, assign)TextInputType type;
@property (nonatomic, assign)id<TextFieldInputViewDelegate>delegate;

- (instancetype)initWith:(TextInputType)type;

@end

