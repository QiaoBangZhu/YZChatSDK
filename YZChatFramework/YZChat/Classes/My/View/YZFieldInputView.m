//
//  FieldInputView.m
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZFieldInputView.h"
#import "UIColor+ColorExtension.h"

@interface YZFieldInputView() <QMUITextFieldDelegate>

@end

@implementation YZFieldInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = InputTypeNormal;
        [self setup];
    }
    return self;
}

- (instancetype)initWith:(InputType)type image:(UIImage *)image highlightImage:(UIImage *)hightImage {
     self = [super init];
     if (self) {
        self.image = image;
        self.highlightedImage = hightImage;
        self.type = type;
        [self setup];
     }
     return self;
}

- (void)setup {
    if (_image == nil && _highlightedImage == nil) {
        if (_type == InputTypePhone) {
            self.textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 60, 35)];
            self.textField.leftViewMode = UITextFieldViewModeAlways;
        }
    }else {
        if (_type == InputTypePhone) {
          UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35+60, 35)];
            [leftView addSubview:self.iconView];
            self.textField.leftView = leftView;
        }else {
            self.textField.leftView = self.iconView;
        }
        self.iconView.image = _image;
        self.iconView.highlightedImage = _highlightedImage;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    switch (_type) {
        case InputTypeNormal:
            break;
        case InputTypePhone:
            self.textField.keyboardType = UIKeyboardTypePhonePad;
        case InputTypeCode:
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
        default:
            break;
    }
    
    _textField.delegate = self;
    [self addSubview:self.textField];
    [self addSubview:self.line];
    
    [self makeConstraint];
}

- (void)makeConstraint {
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.leading.equalTo(@25);
        make.trailing.equalTo(@-25);
    }];
    
    switch (self.type) {
        case InputTypeNormal: {
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.line.mas_left).offset(10);
                make.right.equalTo(self.line.mas_right);
                make.height.equalTo(@35);
                make.centerY.equalTo(@0);
            }];
        }
            break;
        case InputTypePhone: {
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.equalTo(self.line.mas_left);
                 make.right.equalTo(self.line.mas_right);
                 make.height.equalTo(@35);
                 make.centerY.equalTo(@0);
            }];
         }
            break;
        case InputTypeCode: {
            [self addSubview:self.codeButton];
            [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@23);
                make.width.equalTo(@90);
                make.right.equalTo(self.line.mas_right);
                make.centerY.equalTo(@0);
            }];
            
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.line.mas_left);
                make.right.equalTo(self.codeButton.mas_left).offset(-5);
                make.height.equalTo(@35);
                make.centerY.equalTo(@0);
            }];
            
         }
            break;
        default:
            break;
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.line.isHighlighted = YES;
    self.iconView.highlighted = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.line.isHighlighted = NO;
    self.iconView.highlighted = NO;
}

-(UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.frame = CGRectMake(0, 0, 35, 35);
    }
    return _iconView;
}

- (QMUIButton *)codeButton {
    if (!_codeButton) {
        _codeButton = [QMUIGhostButton buttonWithType:UIButtonTypeCustom];
        _codeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _codeButton.qmui_outsideEdge = UIEdgeInsetsMake(-10, 0, -10, 0);
        [_codeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    }
    return _codeButton;
}

- (QMUITextField *)textField {
    if (!_textField) {
        _textField = [[QMUITextField alloc]init];
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

- (YZLine*)line {
    if (!_line) {
        _line = [[YZLine alloc]initWithAutoUpdateHeight:true normalColor:[UIColor lightGrayColor] highlightedColor:[UIColor colorWithHex:KCommonBlueBubbleColor]];
    }
    return _line;
}

@end
