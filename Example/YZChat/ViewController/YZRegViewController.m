////
////  YZRegViewController.m
////  YZChat
////
////  Created by magic on 2020/12/17.
////  Copyright © 2020 QiaoBangZhu. All rights reserved.
////
//
#import "YZRegViewController.h"
#import <QMUIKit/QMUIKit.h>
#import "UIBarButtonItem+YZExtensions.h"
#import "YZLoginViewController.h"
#import "YTextFieldInputView.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import "YZChatNetworkEngine.h"
#import "UIButton+YZCaptcha.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <YYText/YYText.h>
#import "YZChatValidInput.h"
#import "YZChatNetworkEngine.h"
#import "UIColor+YZFoundation.h"
#import "YWebViewController.h"
#import "YZCommonConstant.h"

@interface YZRegViewController ()<YTextFieldInputViewDelegate>
@property (nonatomic, strong)YTextFieldInputView *phoneField;
@property (nonatomic, strong)YTextFieldInputView *smsCodeField;
@property (nonatomic, strong)YTextFieldInputView *passwordField;
@property (nonatomic, strong)YTextFieldInputView *confirmPasswordField;
@property (nonatomic, strong)QMUIButton          *confirmBtn;
@property (nonatomic, strong)YYLabel             *userAgreementLabel;
@property (nonatomic, strong)UIButton            *checkBoxBtn;
@property (nonatomic, assign)BOOL isLoading;

@end

@implementation YZRegViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self makeConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
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

    self.view.backgroundColor = [UIColor colorWithHex:0xF0F3F8];


    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意用户服务协议和隐私政策"];
    text.yy_font = [UIFont systemFontOfSize:12];
    text.yy_color = [UIColor colorWithHex:0xBFBFBF];
    [text yy_setColor:[UIColor colorWithHex:0x2373FF] range:NSMakeRange(7, 6)];
    [text yy_setColor:[UIColor colorWithHex:0x2373FF] range:NSMakeRange(14, 4)];

    [text yy_setTextHighlightRange:NSMakeRange(7, 6)//设置点击的位置
                             color:[UIColor colorWithHex:0x2373FF]
                   backgroundColor:[UIColor colorWithHex:0xF0F3F8]
                         tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        YWebViewController* webVc = [[YWebViewController alloc]init];
        webVc.url = [NSURL URLWithString:yzuserAgreementUrl];
        webVc.title = @"用户服务协议";
        [self.navigationController pushViewController:webVc animated:true];
    }];

    [text yy_setTextHighlightRange:NSMakeRange(14, 4)//设置点击的位置
                             color:[UIColor colorWithHex:0x2373FF]
                   backgroundColor:[UIColor colorWithHex:0xF0F3F8]
                         tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        YWebViewController* webVc = [[YWebViewController alloc]init];
        webVc.url = [NSURL URLWithString:yzprivacyPolicyUrl];
        webVc.title = @"隐私条款";
        [self.navigationController pushViewController:webVc animated:true];
    }];

    YYLabel *highlightRangeLabel = [YYLabel new];
    highlightRangeLabel.attributedText = text;
    highlightRangeLabel.userInteractionEnabled = YES;
    highlightRangeLabel.backgroundColor = [UIColor colorWithHex:0xF4F6F9];
    self.userAgreementLabel = highlightRangeLabel;
    [self.view addSubview:highlightRangeLabel];

    if (self.codeType == YZSmscodeTypeRegUser) {
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
        make.left.equalTo(@24);
        make.top.equalTo(@(24));
        make.right.equalTo(@-24);
        make.height.equalTo(@40);
    }];
    
    [_smsCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@24);
        make.trailing.equalTo(@-24);
        make.top.equalTo(_phoneField.mas_bottom).offset(16);
        make.height.equalTo(@40);
    }];
    
    [_passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@24);
        make.trailing.equalTo(@-24);
        make.top.equalTo(_smsCodeField.mas_bottom).offset(16);
        make.height.equalTo(@40);
    }];
    
    [_confirmPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@24);
        make.trailing.equalTo(@-24);
        make.top.equalTo(_passwordField.mas_bottom).offset(16);
        make.height.equalTo(@40);
    }];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@24);
        make.right.equalTo(@-24);
        make.height.equalTo(@40);
        make.top.equalTo(_confirmPasswordField.mas_bottom).offset(24);
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
        make.top.equalTo(_confirmBtn.mas_bottom).offset(12);
    }];
}

- (YTextFieldInputView*)phoneField {
    if (!_phoneField) {
        _phoneField = [[YTextFieldInputView alloc]initWith:YTextInputTypePhone];
        _phoneField.textField.placeholder = @"请输入手机号码";
        [_phoneField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _phoneField.textField.tag = 100;
    }
    return _phoneField;
}

- (YTextFieldInputView*)smsCodeField {
    if (!_smsCodeField) {
        _smsCodeField = [[YTextFieldInputView alloc]initWith:YTextInputTypeCode];
        _smsCodeField.textField.placeholder = @"请输入验证码";
        _smsCodeField.delegate = self;
        [_smsCodeField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _smsCodeField.textField.tag = 101;
    }
    return _smsCodeField;
}

- (YTextFieldInputView*)passwordField {
    if (!_passwordField) {
        _passwordField = [[YTextFieldInputView alloc]initWith:YTextInputTypeNormal];
        _passwordField.textField.placeholder = @"请输入密码(6-16位，大小写字母+数字)";
        [_passwordField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _passwordField.textField.tag = 102;
        _passwordField.textField.secureTextEntry = YES;
    }
    return _passwordField;
}

- (YTextFieldInputView*)confirmPasswordField {
    if (!_confirmPasswordField) {
        _confirmPasswordField = [[YTextFieldInputView alloc]initWith:YTextInputTypeNormal];
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
        _confirmBtn.backgroundColor = [UIColor colorWithHex:0x3386F2];
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
    if (![YZChatValidInput isPassword:self.passwordField.textField.text]) {
        [QMUITips showWithText:@"密码格式不正确"];
        return;
    }
    if (![self.passwordField.textField.text isEqualToString:self.confirmPasswordField.textField.text]) {
        [QMUITips showWithText:@"前后密码不一致"];
        return;
    }
    if (self.codeType == YZSmscodeTypeRegUser) {
        if (!self.checkBoxBtn.selected) {
            [QMUITips showWithText:@"请选中相关协议"];
            return;
        }
        [self requestReg];
    }else if (self.codeType == YZSmscodeTypeModifyPassword) {
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
    [YZChatNetworkEngine requestUserRegisterWithMobile:self.phoneField.textField.text smsCode:self.smsCodeField.textField.text passWord:self.passwordField.textField.text completion:^(NSDictionary *result, NSError *error) {
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
    [YZChatNetworkEngine requestResetPasswordWithMobile:self.phoneField.textField.text smsCode:self.smsCodeField.textField.text password:self.passwordField.textField.text completion:^(NSDictionary *result, NSError *error) {
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
    [YZChatNetworkEngine requestUserCodeWithMobile:self.phoneField.textField.text type:self.codeType completion:^(NSDictionary *result, NSError *error) {
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
