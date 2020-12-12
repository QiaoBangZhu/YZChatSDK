//
//  ChangePasswordViewController.m
//  YChat
//
//  Created by magic on 2020/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UIColor+ColorExtension.h"
#import "YChatSettingStore.h"
#import "TextFieldInputView.h"
#import "UserInfo.h"
#import <Masonry/Masonry.h>
#import "THeader.h"
#import "YChatNetworkEngine.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <QMUIKit/QMUIKit.h>

@interface ChangePasswordViewController ()
@property (nonatomic, strong)TextFieldInputView *oldPwdField;
@property (nonatomic, strong)TextFieldInputView *newPwdField;
@property (nonatomic, strong)TextFieldInputView *confirmPwdField;
@property (nonatomic, strong)UIButton           *confirmBtn;
@property (nonatomic, strong)UserInfo           *userInfo;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.userInfo = [[YChatSettingStore sharedInstance]getUserInfo];
    [self setupView];
    [self makeConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:KCommonBackgroundColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}


- (void)setupView {
    [self.view addSubview:self.oldPwdField];
    [self.view addSubview:self.newPwdField];
    [self.view addSubview:self.confirmPwdField];
    [self.view addSubview:self.confirmBtn];
}

- (void)makeConstraint {
    [_oldPwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@(25));
        make.right.equalTo(@-20);
        make.height.equalTo(@50);
    }];
    
    [_newPwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_oldPwdField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    
    [_confirmPwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_newPwdField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@48);
        make.top.equalTo(_confirmPwdField.mas_bottom).offset(20);
    }];
    
}


- (TextFieldInputView*)oldPwdField {
    if (!_oldPwdField) {
        _oldPwdField = [[TextFieldInputView alloc]initWith:TextInputTypeNormal];
        _oldPwdField.textField.placeholder = @"请输入原密码";
        [_oldPwdField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _oldPwdField;
}

- (TextFieldInputView*)newPwdField {
    if (!_newPwdField) {
        _newPwdField = [[TextFieldInputView alloc]initWith:TextInputTypeNormal];
        _newPwdField.textField.placeholder = @"请输入新密码";
        [_newPwdField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _newPwdField;
}

- (TextFieldInputView*)confirmPwdField {
    if (!_confirmPwdField) {
        _confirmPwdField = [[TextFieldInputView alloc]initWith:TextInputTypeNormal];
        _confirmPwdField.textField.placeholder = @"请输入确认密码";
        [_confirmPwdField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _confirmPwdField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([self.oldPwdField.textField.text length] > 0 && [self.newPwdField.textField.text length] > 0 && [self.confirmPwdField.textField.text length] > 0) {
        self.confirmBtn.enabled = YES;
    }else {
        self.confirmBtn.enabled = NO;
    }
}

- (UIButton*)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
    if (![self.newPwdField.textField.text isEqualToString:self.confirmPwdField.textField.text]) {
        [QMUITips showError:@"前后密码不一致"];
        return;
    }

    [YChatNetworkEngine requestModifyPasswordWithUserId:self.userInfo.userId oldPwd:self.oldPwdField.textField.text newPassword:self.newPwdField.textField.text completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                [QMUITips showWithText:@"成功"];
                [self.navigationController popViewControllerAnimated:true];
            }else {
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

@end
