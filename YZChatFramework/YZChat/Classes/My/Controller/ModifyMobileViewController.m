//
//  ModifyMobileViewController.m
//  YChat
//
//  Created by magic on 2020/10/8.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ModifyMobileViewController.h"
#import "UIBarButtonItem+Extensions.h"
#import "LoginViewController.h"
#import "UIColor+ColorExtension.h"
#import "TextFieldInputView.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import "THeader.h"
#import "YChatNetworkEngine.h"
#import "UIButton+Captcha.h"
#import "YChatSettingStore.h"
#import "UserInfo.h"

@interface ModifyMobileViewController ()<TextFieldInputViewDelegate>

@property (nonatomic, strong)TextFieldInputView *phoneField;
@property (nonatomic, strong)TextFieldInputView *smsCodeField;
@property (nonatomic, strong)QMUIButton         *confirmBtn;
@property (nonatomic, strong)UserInfo           *userInfo;

@end

@implementation ModifyMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.userInfo = [[YChatSettingStore sharedInstance]getUserInfo];
    [self setupView];
    [self makeConstraint];
}

- (void)setupView {
    [self.view addSubview:self.phoneField];
    [self.view addSubview:self.smsCodeField];
    [self.view addSubview:self.confirmBtn];
}

- (void)makeConstraint {
    [_phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@(25));
        make.right.equalTo(@-20);
        make.height.equalTo(@50);
    }];
    
    [_smsCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_phoneField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@48);
        make.top.equalTo(_smsCodeField.mas_bottom).offset(20);
    }];
}

- (TextFieldInputView*)phoneField {
    if (!_phoneField) {
        _phoneField = [[TextFieldInputView alloc]initWith:TextInputTypePhone];
        _phoneField.textField.placeholder = @"请输入手机号码";
        [_phoneField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _phoneField.textField.tag = 100;
    }
    return _phoneField;
}

- (TextFieldInputView*)smsCodeField {
    if (!_smsCodeField) {
        _smsCodeField = [[TextFieldInputView alloc]initWith:TextInputTypeCode];
        _smsCodeField.textField.placeholder = @"请输入验证码";
        _smsCodeField.delegate = self;
        [_smsCodeField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _smsCodeField.textField.tag = 101;
    }
    return _smsCodeField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([self.phoneField.textField.text length] > 0 && [self.smsCodeField.textField.text length] > 0) {
        self.confirmBtn.enabled = YES;
    }else {
        self.confirmBtn.enabled = NO;
    }
}

- (QMUIButton*)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = [UIColor colorWithHex:KCommonBlueBubbleColor];
        _confirmBtn.layer.masksToBounds = YES;
        _confirmBtn.layer.cornerRadius = 4;
        _confirmBtn.enabled = false;
    }
    return _confirmBtn;
}

- (void)confirmBtnAction {
    [YChatNetworkEngine requestChangeMobileWithUserId:self.userInfo.userId mobile:self.phoneField.textField.text oldMobile:self.userInfo.mobile smsCode:self.smsCodeField.textField.text completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                [QMUITips showSucceed:@"成功"];
                self.userInfo.mobile = self.phoneField.textField.text;
                [[YChatSettingStore sharedInstance]saveUserInfo:self.userInfo];
            }else {
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

- (void)selectedCodeBtn:(UIButton *)btn {
    if ([_phoneField.textField.text length] == 0) {
        [QMUITips showWithText:@"请输入手机号码"];
        return;
    }
    [YChatNetworkEngine requestUserCodeWithMobile:self.phoneField.textField.text type:SmscodeTypeModifyPhone completion:^(NSDictionary *result, NSError *error) {
        [UIButton settimer:btn];
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                [QMUITips showSucceed:@"发送成功"];
            }else{
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

@end
