//
//  YZModifyMobileViewController.m
//  YChat
//
//  Created by magic on 2020/10/8.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZModifyMobileViewController.h"
#import "UIBarButtonItem+Extensions.h"
#import "UIColor+ColorExtension.h"
#import "YZTextFieldInputView.h"
#import "CIGAMKit.h"
#import <Masonry/Masonry.h>
#import "THeader.h"
#import "YChatNetworkEngine.h"
#import "UIButton+Captcha.h"
#import "YChatSettingStore.h"
#import "YUserInfo.h"

@interface YZModifyMobileViewController ()<TextFieldInputViewDelegate>

@property (nonatomic, strong)YZTextFieldInputView *phoneField;
@property (nonatomic, strong)YZTextFieldInputView *smsCodeField;
@property (nonatomic, strong)CIGAMButton         *confirmBtn;
@property (nonatomic, strong)YUserInfo           *userInfo;

@end

@implementation YZModifyMobileViewController

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

- (YZTextFieldInputView*)phoneField {
    if (!_phoneField) {
        _phoneField = [[YZTextFieldInputView alloc]initWith:TextInputTypePhone];
        _phoneField.textField.placeholder = @"请输入手机号码";
        [_phoneField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _phoneField.textField.tag = 100;
    }
    return _phoneField;
}

- (YZTextFieldInputView*)smsCodeField {
    if (!_smsCodeField) {
        _smsCodeField = [[YZTextFieldInputView alloc]initWith:TextInputTypeCode];
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

- (CIGAMButton*)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [CIGAMButton buttonWithType:UIButtonTypeCustom];
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
                [CIGAMTips showSucceed:@"成功"];
                self.userInfo.mobile = self.phoneField.textField.text;
                [[YChatSettingStore sharedInstance]saveUserInfo:self.userInfo];
            }else {
                [CIGAMTips showError:result[@"msg"]];
            }
        }
    }];
}

- (void)selectedCodeBtn:(UIButton *)btn {
    if ([_phoneField.textField.text length] == 0) {
        [CIGAMTips showWithText:@"请输入手机号码"];
        return;
    }
    [YChatNetworkEngine requestUserCodeWithMobile:self.phoneField.textField.text type:SmscodeTypeModifyPhone completion:^(NSDictionary *result, NSError *error) {
        [UIButton settimer:btn];
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                [CIGAMTips showSucceed:@"发送成功"];
            }else{
                [CIGAMTips showError:result[@"msg"]];
            }
        }
    }];
}

@end
