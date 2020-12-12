//
//  LoginViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "LoginViewController.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry.h>
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "FieldInputView.h"
#import "RegViewController.h"
#import "YChatNetworkEngine.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "RequestUtils.h"
#import "UserInfo.h"
#import "YChatSettingStore.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>

//#import "AppDelegate.h"
#import "UIColor+ColorExtension.h"
#import "TextFieldInputView.h"
#import "ChangePasswordViewController.h"
#import "UIColor+ColorExtension.h"
#import "TUILocalStorage.h"
#import "TUIKit.h"
//#import "YzIMKitAgent.h"

@interface LoginViewController ()
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIView      * contentView;
@property (nonatomic, strong)UIImageView * logo;
@property (nonatomic, strong)FieldInputView * phoneInput;
@property (nonatomic, strong)FieldInputView * pwdInput;
@property (nonatomic, strong)QMUIButton  * loginBtn;
@property (nonatomic, strong)QMUIButton  * forgotPwdBtn;
@property (nonatomic, strong)QMUIButton  * registerBtn;
@property (nonatomic, strong)UILabel     * versionLabel;
@property (nonatomic, strong)UILabel     * welcomeLabel;
@property (nonatomic, strong)UILabel     * tipsLabel;
@property (nonatomic, strong)TextFieldInputView *phoneField;
@property (nonatomic, strong)TextFieldInputView *passwordField;
@property (nonatomic, strong)UIImageView * topImageView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self makeConstranit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}


- (void)setupView {
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.topImageView];
    [self.contentView addSubview:self.logo];
    [self.contentView  addSubview:self.loginBtn];
    [self.contentView addSubview:self.forgotPwdBtn];
    [self.contentView addSubview:self.registerBtn];
    [self.contentView addSubview:self.versionLabel];
    [self.contentView addSubview:self.welcomeLabel];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.phoneField];
    [self.contentView addSubview:self.passwordField];
    
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
}

- (void)makeConstranit {
//    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(@0);
//    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
        make.width.equalTo(@(self.view.frame.size.width));
    }];
    
    [_topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(@0);
        make.height.equalTo(@400);
    }];
    
    [_logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@(NavBar_Height + StatusBarHeight + 5));
        make.size.equalTo(@96);
    }];
    
    [_welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(self.logo.mas_bottom).offset(16);
    }];
    
    [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(_welcomeLabel.mas_bottom).offset(4);
    }];
    
    [_phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tipsLabel.mas_bottom).offset(30);
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.height.equalTo(@50);
    }];
       
    [_passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.top.equalTo(_phoneField.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
   
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(@48);
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

- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc]init];
        _topImageView.image = [UIImage imageNamed:@"login_bg"];
    }
    return _topImageView;
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

- (TextFieldInputView*)phoneField {
    if (!_phoneField) {
        _phoneField = [[TextFieldInputView alloc]initWith:TextInputTypePhone];
        _phoneField.textField.placeholder = @"请输入手机号码";
        [_phoneField.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _phoneField.textField.tag = 100;
    }
    return _phoneField;
}

- (TextFieldInputView*)passwordField {
    if (!_passwordField) {
        _passwordField = [[TextFieldInputView alloc]initWith:TextInputTypeNormal];
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
        _loginBtn.backgroundColor = [UIColor colorWithHex:KCommonBlueBubbleColor];
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
        [_registerBtn setTitleColor:[UIColor colorWithHex:KCommonBlueBubbleColor] forState:UIControlStateNormal];
    }
    return _registerBtn;
}

- (QMUIButton*)forgotPwdBtn {
    if (!_forgotPwdBtn) {
        _forgotPwdBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPwdBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_forgotPwdBtn addTarget:self action:@selector(forgotPwdBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _forgotPwdBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_forgotPwdBtn setTitleColor:[UIColor colorWithHex:kCommonGrayTextColor] forState:UIControlStateNormal];
    }
    return _forgotPwdBtn;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel  = [[UILabel alloc]init];
        _versionLabel.textColor = [UIColor colorWithHex:kCommonGrayTextColor];
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
        _welcomeLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        _welcomeLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        _welcomeLabel.text = @"欢迎使用元信";
    }
    return _welcomeLabel;
}

-(UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.text = @"在元信与你的同事和朋友进行沟通与协作";
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = [UIColor colorWithHex:kCommonGrayTextColor];
    }
    return _tipsLabel;
}

- (void)loginBtnAction {
//    [[YzIMKitAgent shareInstance]initAppId:@"de241446a50499bb77a8684cf610fd04"];
//    SysUser* user = [[SysUser alloc]init];
//    user.userId = @"95e6bd162f019b60ad8380fba5e0db41";
//    user.nickName = @"大统领";
//
//    [[YzIMKitAgent shareInstance]registerWithSysUser:user loginSuccess:^{
//
//     } loginFailed:^(int errCode, NSString * _Nonnull errMsg) {
//
//    }];
    
    if (![_phoneField.textField.text length]) {
        [QMUITips showWithText:@"请输入手机号"];
        return;
    }else if (![_passwordField.textField.text length]) {
        [QMUITips showWithText:@"请输入密码"];
        return;
    }
    [QMUITips showLoadingInView:self.view];
    [YChatNetworkEngine requestUserLoginMobile:_phoneField.textField.text loginPwd:_passwordField.textField.text completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                [QMUITips hideAllTips];
                UserInfo* model = [UserInfo yy_modelWithDictionary:result[@"data"]];
                model.token = result[@"token"];
                if (model.token) {
                    UserInfo* tokenInfo = [[UserInfo alloc]init];
                    tokenInfo.token = model.token;
                    [[YChatSettingStore sharedInstance] saveUserInfo:tokenInfo];
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

- (void)fetchUserInfo:(UserInfo*)model {
    [YChatNetworkEngine requestUserInfoWithUserId:model.userId completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            UserInfo* info = [UserInfo yy_modelWithDictionary:result[@"data"]];
            info.userSign = model.userSign;
            info.departMentId = model.departMentId;
            info.token = model.token;
            [self loginTencentIM:info];
        }
    }];
    
}

- (void)loginTencentIM:(UserInfo*)info {
//    [QMUITips hideAllTips];
//    [[V2TIMManager sharedInstance] login:info.userId userSig:info.userSign succ:^{
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        NSData *deviceToken = delegate.deviceToken;
//        if (deviceToken) {
//            TIMTokenParam *param = [[TIMTokenParam alloc] init];
//            //企业证书 ID
//            param.busiId = sdkBusiId;
//            [param setToken:deviceToken];
//            [[TIMManager sharedInstance] setToken:param succ:^{
//                NSLog(@"-----> 上传 token 成功 ");
//                //推送声音的自定义化设置
//                TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
//                config.openPush = 0;
//                config.c2cSound = @"sms-received.caf";
//                config.groupSound = @"sms-received.caf";
//                [[TIMManager sharedInstance] setAPNS:config succ:^{
//                    NSLog(@"-----> 设置 APNS 成功");
//                } fail:^(int code, NSString *msg) {
//                    NSLog(@"-----> 设置 APNS 失败");
//                }];
//            } fail:^(int code, NSString *msg) {
//                NSLog(@"-----> 上传 token 失败 ");
//            }];
//        }
//        [[YChatSettingStore sharedInstance]saveUserInfo:info];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            app.window.rootViewController = [app getMainController];            
//        });
//    } fail:^(int code, NSString *msg) {
//         [QMUITips showWithText:msg];
//        [[YChatSettingStore sharedInstance]logout];
//    }];
}

- (void)regBtnAction {
    RegViewController* regVc = [[RegViewController alloc]init];
    regVc.codeType = SmscodeTypeRegUser;
    regVc.title = @"注册";
//    app.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:regVc];
    [self.navigationController pushViewController:regVc animated:true];
}

- (void)forgotPwdBtnAction {
    RegViewController* forgotPwd = [[RegViewController alloc]init];
    forgotPwd.codeType = SmscodeTypeModifyPassword;
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


