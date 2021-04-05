//
//  YZLoginViewController.m
//  YZChat
//
//  Created by magic on 2020/12/17.
//  Copyright © 2020 QiaoBangZhu. All rights reserved.
//

#import "YZLoginViewController.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "YTextFieldInputView.h"
//#import "ChangePasswordViewController.h"
#import "YZRegViewController.h"
#import "UIColor+YZFoundation.h"
#import "AbstractUserModel.h"
#import <YZChat/YZChat.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "YZAppDelegate.h"
#import "YZChatSettingStore.h"

#define StatusBar_Height    (Is_IPhoneX ? (44.0):(20.0))

@interface YZLoginViewController ()
@property (nonatomic, strong)UIView      * contentView;
@property (nonatomic, strong)UIImageView * logo;
@property (nonatomic, strong)QMUIButton  * loginBtn;
@property (nonatomic, strong)QMUIButton  * forgotPwdBtn;
@property (nonatomic, strong)QMUIButton  * registerBtn;
@property (nonatomic, strong)UILabel     * versionLabel;
@property (nonatomic, strong)UILabel     * welcomeLabel;
@property (nonatomic, strong)UILabel     * tipsLabel;
@property (nonatomic, strong)YTextFieldInputView *phoneField;
@property (nonatomic, strong)YTextFieldInputView *passwordField;


@end

@implementation YZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    [self makeConstranit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [self.navigationController setNavigationBarHidden: YES animated: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [self.navigationController setNavigationBarHidden: FALSE animated: YES];
}

- (void)setupView {
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.logo];
    [self.contentView  addSubview:self.loginBtn];
    [self.contentView addSubview:self.forgotPwdBtn];
    [self.contentView addSubview:self.registerBtn];
    [self.contentView addSubview:self.versionLabel];
    [self.contentView addSubview:self.welcomeLabel];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.phoneField];
    [self.contentView addSubview:self.passwordField];
    self.view.backgroundColor = [UIColor colorWithHex:0xF0F3F8];
}

- (void)makeConstranit {
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
        make.width.equalTo(@(self.view.frame.size.width));
    }];
    
  
    [_logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(@(44 + StatusBarHeight));
        make.size.equalTo(@59);
    }];
    
    [_welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.logo.mas_bottom).offset(8);
    }];
    
    [_phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_welcomeLabel.mas_bottom).offset(44);
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.height.equalTo(@40);
    }];
       
    [_passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_phoneField.mas_bottom).offset(10);
        make.height.equalTo(@40);
    }];
   
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@44);
        make.top.equalTo(_passwordField.mas_bottom).offset(20);
    }];
    
    [_registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_loginBtn.mas_left);
        make.top.equalTo(_loginBtn.mas_bottom).offset(15);
    }];
    
    [_forgotPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_loginBtn.mas_right);
        make.top.equalTo(_loginBtn.mas_bottom).offset(15);
    }];
    
    [_versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.bottom.equalTo(@-25);
    }];
}

- (UIView*)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
    }
    return _contentView;
}

- (UIImageView *)logo {
    if (!_logo) {
        _logo = [[UIImageView alloc]init];
        _logo.image = [UIImage imageNamed:@"logo"];
        _logo.layer.masksToBounds = YES;
        _logo.layer.cornerRadius = 8;
    }
    return _logo;
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

- (YTextFieldInputView*)passwordField {
    if (!_passwordField) {
        _passwordField = [[YTextFieldInputView alloc]initWith:YTextInputTypeNormal];
        _passwordField.textField.placeholder = @"请输入密码";
        [_passwordField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _passwordField.textField.tag = 101;
        _passwordField.textField.secureTextEntry = YES;
    }
    return _passwordField;
}

- (QMUIButton*)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginBtn.backgroundColor = [UIColor colorWithHex:0x2F7AFF];
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.layer.cornerRadius = 4;
        _loginBtn.enabled = false;
    }
    return _loginBtn;
}

- (QMUIButton*)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:@"还没有账号?去注册" forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(regBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _registerBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_registerBtn setTitleColor:[UIColor colorWithHex:0x3386F2] forState:UIControlStateNormal];
    }
    return _registerBtn;
}

- (QMUIButton*)forgotPwdBtn {
    if (!_forgotPwdBtn) {
        _forgotPwdBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPwdBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_forgotPwdBtn addTarget:self action:@selector(forgotPwdBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _forgotPwdBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_forgotPwdBtn setTitleColor:[UIColor colorWithHex:0xBFBFBF] forState:UIControlStateNormal];
    }
    return _forgotPwdBtn;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel  = [[UILabel alloc]init];
        _versionLabel.textColor = [UIColor colorWithHex:0x787878];
        _versionLabel.font = [UIFont systemFontOfSize:12];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // app版本
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _versionLabel.text = [NSString stringWithFormat:@"当前版本v%@",app_Version];
    }
    return _versionLabel;
}

- (UILabel *)welcomeLabel {
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc]init];
        _welcomeLabel.textColor = [UIColor colorWithHex:0x212121];
        _welcomeLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _welcomeLabel.text = @"欢迎使用元讯";
    }
    return _welcomeLabel;
}

-(UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.text = @"在元信与你的同事和朋友进行沟通与协作";
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = [UIColor colorWithHex:0x787878];
    }
    return _tipsLabel;
}

- (void)loginBtnAction {
    if (![_phoneField.textField.text length]) {
        [QMUITips showWithText:@"请输入手机号"];
        return;
    }else if (![_passwordField.textField.text length]) {
        [QMUITips showWithText:@"请输入密码"];
        return;
    }
    [QMUITips showLoadingInView:self.view];
    
    [YZChatNetworkEngine requestUserLoginMobile:_phoneField.textField.text loginPwd:_passwordField.textField.text completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                [QMUITips hideAllTips];
                AbstractUserModel* model = [AbstractUserModel yy_modelWithDictionary:result[@"data"]];
                model.token = result[@"token"];
                if (model.token) {
                    [[YZChatSettingStore sharedInstance] saveUserInfo:model];
                    [self fetchUserInfo:model];
                }else {
                    [QMUITips hideAllTips];
                    [QMUITips showWithText:result[@"msg"]];
                    return;
                }
            }else {
                [QMUITips hideAllTips];
                [QMUITips showWithText:result[@"msg"]];
            }
        }
   }];
}

- (void)fetchUserInfo:(AbstractUserModel*)model {
    [YZChatNetworkEngine requestUserInfoWithUserId:model.userId completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            SysUser* info = [SysUser yy_modelWithDictionary:result[@"data"]];
            [[YzIMKitAgent shareInstance] registerWithSysUser:info loginSuccess:^{
                [[YzIMKitAgent shareInstance] startAutoWithCurrentVc: nil];
             } loginFailed:^(NSInteger errCode, NSString * _Nonnull errMsg) {
                 NSLog(@"error =%@",errMsg);
            }];

        }
    }];
}

- (void)regBtnAction {
    YZRegViewController* regVc = [[YZRegViewController alloc]init];
    regVc.codeType = YZSmscodeTypeRegUser;
    regVc.title = @"注册";
    [self.navigationController pushViewController:regVc animated:YES];
}

- (void)forgotPwdBtnAction {
    YZRegViewController* forgotPwd = [[YZRegViewController alloc]init];
    forgotPwd.codeType = YZSmscodeTypeModifyPassword;
    forgotPwd.title = @"忘记密码";
    [self.navigationController pushViewController:forgotPwd animated:true];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == 100) {
        self.loginBtn.enabled = (textField.text.length > 0 && [self.passwordField.textField.text length] > 0);
    }else {
        self.loginBtn.enabled = (textField.text.length > 0 && [self.phoneField.textField.text length] > 0);
    }
}

@end
