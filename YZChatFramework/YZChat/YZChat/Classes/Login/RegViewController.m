//
//  RegViewController.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "RegViewController.h"
#import "UIBarButtonItem+Extensions.h"
#import "LoginViewController.h"
//#import "AppDelegate.h"
#import "UIColor+ColorExtension.h"
#import "TextFieldInputView.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import "THeader.h"
#import "YChatNetworkEngine.h"
#import "UIButton+Captcha.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <YYText/YYText.h>
#import "WebViewController.h"
#import "UIBarButtonItem+Extensions.h"
#import "YChatValidInput.h"

@interface RegViewController ()<TextFieldInputViewDelegate>
@property (nonatomic, strong)TextFieldInputView *phoneField;
@property (nonatomic, strong)TextFieldInputView *smsCodeField;
@property (nonatomic, strong)TextFieldInputView *passwordField;
@property (nonatomic, strong)TextFieldInputView *confirmPasswordField;
@property (nonatomic, strong)QMUIButton         *confirmBtn;
@property (nonatomic, strong)YYLabel            *userAgreementLabel;
@property (nonatomic, strong)UIButton           *checkBoxBtn;
@property (nonatomic, assign)BOOL isLoading;
@end

@implementation RegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self makeConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:KCommonBackgroundColor];
   
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"";
    } else {
        // Fallback on earlier versions
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

- (void)setupView {
    [self.view addSubview:self.phoneField];
    [self.view addSubview:self.smsCodeField];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:self.confirmPasswordField];
    [self.view addSubview:self.confirmBtn];
    [self.view addSubview:self.checkBoxBtn];
    
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];

    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意服务协议和隐私条款"];
    text.yy_font = [UIFont systemFontOfSize:12];
    text.yy_color = [UIColor colorWithHex:KCommonlittleLightGrayColor];
    [text yy_setColor:[UIColor colorWithHex:kCommonBlueTextColor] range:NSMakeRange(7, 4)];
    [text yy_setColor:[UIColor colorWithHex:kCommonBlueTextColor] range:NSMakeRange(12, 4)];
    
    [text yy_setTextHighlightRange:NSMakeRange(7, 4)//设置点击的位置
                             color:[UIColor colorWithHex:kCommonBlueTextColor]
                   backgroundColor:[UIColor colorWithHex:KCommonBackgroundColor]
                         tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        WebViewController* webVc = [[WebViewController alloc]init];
        webVc.url = [NSURL URLWithString:userAgreementUrl];
        webVc.title = @"用户协议";
        [self.navigationController pushViewController:webVc animated:true];
    }];
    
    [text yy_setTextHighlightRange:NSMakeRange(12, 4)//设置点击的位置
                             color:[UIColor colorWithHex:kCommonBlueTextColor]
                   backgroundColor:[UIColor colorWithHex:KCommonBackgroundColor]
                         tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        WebViewController* webVc = [[WebViewController alloc]init];
        webVc.url = [NSURL URLWithString:privacyPolicyUrl];
        webVc.title = @"隐私条款";
        [self.navigationController pushViewController:webVc animated:true];
    }];
    
    YYLabel *highlightRangeLabel = [YYLabel new];
    highlightRangeLabel.attributedText = text;
    highlightRangeLabel.userInteractionEnabled = YES;
    highlightRangeLabel.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.userAgreementLabel = highlightRangeLabel;
    [self.view addSubview:highlightRangeLabel];
    
    if (self.codeType == SmscodeTypeRegUser) {
        self.checkBoxBtn.hidden = false;
        self.userAgreementLabel.hidden = false;
    }else {
        self.checkBoxBtn.hidden = true;
        self.checkBoxBtn.selected = true;
        self.userAgreementLabel.hidden = true;
    }
}

- (void)makeConstraint {
    [_phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@(25));
        make.right.equalTo(@-20);
        make.height.equalTo(@54);
    }];
    
    [_smsCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_phoneField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    
    [_passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_smsCodeField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    
    [_confirmPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_passwordField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@48);
        make.top.equalTo(_confirmPasswordField.mas_bottom).offset(20);
    }];
    
    [_checkBoxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_confirmBtn.mas_left);
        make.centerY.equalTo(_userAgreementLabel.mas_centerY);
        make.size.equalTo(@20);
    }];
    
    [_userAgreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_checkBoxBtn.mas_right).offset(2);
        make.centerY.equalTo(_checkBoxBtn.mas_centerY);
        make.right.equalTo(@-10);
        make.height.equalTo(@17);
        make.top.equalTo(_confirmBtn.mas_bottom).offset(30);
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

- (TextFieldInputView*)passwordField {
    if (!_passwordField) {
        _passwordField = [[TextFieldInputView alloc]initWith:TextInputTypeNormal];
        _passwordField.textField.placeholder = @"请输入密码(6-16位，大小写字母+数字)";
        [_passwordField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _passwordField.textField.tag = 102;
        _passwordField.textField.secureTextEntry = YES;
    }
    return _passwordField;
}

- (TextFieldInputView*)confirmPasswordField {
    if (!_confirmPasswordField) {
        _confirmPasswordField = [[TextFieldInputView alloc]initWith:TextInputTypeNormal];
        _confirmPasswordField.textField.placeholder = @"请输入确认密码";
        [_confirmPasswordField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _confirmPasswordField.textField.tag = 103;
        _confirmPasswordField.textField.secureTextEntry = YES;
    }
    return _confirmPasswordField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self checkInput];
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

- (UIButton*)checkBoxBtn {
    if (!_checkBoxBtn) {
        _checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBoxBtn addTarget:self action:@selector(checkBoxBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBoxBtn setImage:[UIImage imageNamed:@"checkbox_unselect"] forState:UIControlStateNormal];
        [_checkBoxBtn setImage:[UIImage imageNamed:@"checkbox_selected_small"] forState:UIControlStateSelected];
    }
    return _checkBoxBtn;
}

- (void)confirmBtnAction {
    if (![YChatValidInput isPassword:self.passwordField.textField.text]) {
        [QMUITips showWithText:@"密码格式不正确"];
        return;
    }
    if (![self.passwordField.textField.text isEqualToString:self.confirmPasswordField.textField.text]) {
        [QMUITips showWithText:@"前后密码不一致"];
        return;
    }
    if (self.codeType == SmscodeTypeRegUser) {
        if (!self.checkBoxBtn.selected) {
            [QMUITips showWithText:@"请选中相关协议"];
            return;
        }
        [self requestReg];
    }else if (self.codeType == SmscodeTypeModifyPassword) {
        self.checkBoxBtn.hidden = true;
        self.userAgreementLabel.hidden = true;
        [self reuestResetPwd];
    }
}

- (void)requestReg {
    @weakify(self);
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [YChatNetworkEngine requestUserRegisterWithMobile:self.phoneField.textField.text smsCode:self.smsCodeField.textField.text passWord:self.passwordField.textField.text completion:^(NSDictionary *result, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                [QMUITips showInfo:@"成功"];
                [self.navigationController popViewControllerAnimated:true];
            }else {
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

- (void)reuestResetPwd {
    @weakify(self);
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [YChatNetworkEngine requestResetPasswordWithMobile:self.phoneField.textField.text smsCode:self.smsCodeField.textField.text password:self.passwordField.textField.text completion:^(NSDictionary *result, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                [QMUITips showInfo:@"成功"];
                [self.navigationController popViewControllerAnimated:true];
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
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [YChatNetworkEngine requestUserCodeWithMobile:self.phoneField.textField.text type:self.codeType completion:^(NSDictionary *result, NSError *error) {
        [UIButton settimer:btn];
        self.isLoading = NO;
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                [QMUITips showSucceed:@"发送成功"];
            }else{
                [QMUITips showError:result[@"msg"]];
            }
        }
    }];
}

- (void)checkBoxBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    [self checkInput];
}

- (void)checkInput {
    if ([self.phoneField.textField.text length] > 0 && [self.smsCodeField.textField.text length] > 0 && [self.passwordField.textField.text length] > 0 && [self.confirmPasswordField.textField.text length] > 0 && self.checkBoxBtn.selected == YES) {
           self.confirmBtn.enabled =  YES;
     }else {
        self.confirmBtn.enabled = NO;
     }
}


@end
