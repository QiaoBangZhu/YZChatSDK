//
//  YTextFieldInputView.m
//  YChat
//
//  Created by magic on 2020/10/6.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YTextFieldInputView.h"
#import <Masonry/Masonry.h>
#import "UIColor+YZFoundation.h"
#import <QMUIKit/QMUIKit.h>

@interface YTextFieldInputView()

@property (nonatomic, strong)UIView   *areaView;
@property (nonatomic, strong)UILabel  *areaLabel;
@property (nonatomic, strong)UIView   *separateLine;
@property (nonatomic, strong)UIButton *codeButton;

@end

@implementation YTextFieldInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = YTextInputTypeNormal;
        [self setup];
    }
    return self;
}

- (instancetype)initWith:(YTextInputType)type {
    self = [super init];
    if (self) {
        self.type = type;
        [self setup];
    }
    return  self;
}


- (void)setup {
    
    switch (_type) {
        case YTextInputTypeNormal:
            self.textField.keyboardType = UIKeyboardTypeDefault;
            break;
        case YTextInputTypePhone:
            self.textField.keyboardType = UIKeyboardTypePhonePad;
        case YTextInputTypeCode:
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
        default:
            break;
    }
    self.backgroundColor = [UIColor clearColor];
    UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"searchBar_shadow"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self addSubview:self.textField];
    [self makeConstraint];
}

- (void)makeConstraint {
    switch (self.type) {
        case YTextInputTypeNormal: {
            [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                make.right.equalTo(@-10);
                make.height.equalTo(@48);
                make.centerY.equalTo(@0);
            }];
        }
            break;
        case YTextInputTypePhone: {
            [self addSubview:self.areaView];
            [self.areaView addSubview:self.areaLabel];
            [self.areaView addSubview:self.separateLine];
            
            [self.areaView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(@0);
                make.width.equalTo(@55);
            }];
            [self.separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@1);
                make.height.equalTo(@28);
                make.centerY.equalTo(@0);
                make.right.equalTo(@0);
            }];
            [self.areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                make.centerY.equalTo(@0);
                make.right.equalTo(@-5);
            }];
               
            [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_areaView.mas_right).offset(12);
                make.right.equalTo(@-10);
                make.height.equalTo(@48);
                make.centerY.equalTo(@0);
            }];
         }
            break;
        case YTextInputTypeCode: {
            [self addSubview:self.codeButton];
            [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(@0);
                make.width.equalTo(@80);
                make.right.equalTo(@-10);
                make.centerY.equalTo(@0);
            }];
            
            [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                make.right.equalTo(self.codeButton.mas_left).offset(-5);
                make.height.equalTo(@48);
                make.centerY.equalTo(@0);
            }];
         }
            break;
        default:
            break;
    }
    
}

-(UIView *)areaView {
    if (!_areaView) {
        _areaView = [[UIView alloc]init];
        _areaView.backgroundColor = [UIColor clearColor];
    }
    return _areaView;
}

- (UIView *)separateLine {
    if (!_separateLine) {
        _separateLine = [[UIView alloc]init];
        _separateLine.backgroundColor = [UIColor colorWithHex:0xE4E6E9];
    }
    return _separateLine;
}

- (UILabel *)areaLabel {
    if (!_areaLabel) {
        _areaLabel = [[UILabel alloc]init];
        _areaLabel.textColor = [UIColor colorWithHex:0xD9D9D9];
        _areaLabel.font = [UIFont systemFontOfSize:16];
        _areaLabel.text = @"+86";
    }
    return _areaLabel;
}

- (UIButton *)codeButton {
    if (!_codeButton) {
        _codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _codeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _codeButton.qmui_outsideEdge = UIEdgeInsetsMake(-10, 0, -10, 0);
        [_codeButton setTitleColor:[UIColor colorWithHex:0x1A7EFF] forState:UIControlStateNormal];
        [_codeButton addTarget:self action:@selector(codeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_codeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    }
    return _codeButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc]init];
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

- (void)codeBtnAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedCodeBtn:)]) {
        [self.delegate selectedCodeBtn:_codeButton];
    }
}

@end
