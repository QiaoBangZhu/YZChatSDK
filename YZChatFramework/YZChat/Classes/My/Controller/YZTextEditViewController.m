//
//  YZTextEditViewController.m
//  YChat
//
//  Created by magic on 2020/9/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZTextEditViewController.h"
#import "THeader.h"
#import "UIColor+ColorExtension.h"
#import <QMUIKit/QMUIKit.h>
#import "YChatValidInput.h"

@interface YTextField : UITextField
@property int margin;
@end


@implementation YTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    int margin = self.margin;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int margin = self.margin;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

@end


@interface YZTextEditViewController ()

@end

@implementation YZTextEditViewController

- (instancetype)initWithText:(NSString *)text editType:(EditType)type;
{
    if (self = [super init]) {
        _textValue = text;
        _type = type;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
//   self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:KCommonBackgroundColor];
//   self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.view.backgroundColor = [UIColor whiteColor];
//   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:@"保存  " forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveBtn.frame = CGRectMake(0, 0, 30, 30);
    [saveBtn addTarget:self action:@selector(onSave) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    
    _inputTextField = [[YTextField alloc] initWithFrame:CGRectZero];
    _inputTextField.text = [self.textValue stringByTrimmingCharactersInSet:
                                           [NSCharacterSet illegalCharacterSet]];
    _inputTextField.borderStyle = UITextBorderStyleNone;
    [(YTextField *)_inputTextField setMargin:10];
    _inputTextField.frame = CGRectMake(10, 10, Screen_Width-20, 40);
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(10, 51, Screen_Width-20, 1)];
    line.backgroundColor = [UIColor colorWithHex:kCommonBlueTextColor];
    [self.view addSubview:line];
    
    [self.view addSubview:_inputTextField];
}

- (void)onSave {
    if (_type == EditTypeEmail) {
        if (![YChatValidInput isEmail:self.inputTextField.text]) {
            [QMUITips showError:@"请输入正确的邮箱"];
            return;
        }
    }
    if (_type == EditTypeNickname) {
        if ([self.inputTextField.text length] > 10) {
            [QMUITips showError:@"昵称不能超过10个字"];
            return;
        }
    }
    if (_type == EditTypeFriendRemark) {
        if ([self.inputTextField.text length] > 6) {
            [QMUITips showError:@"昵称不能超过6个字"];
            return;
        }
    }
    
    if (_type == EditTypeSignture) {
        if ([self.inputTextField.text length] > 30) {
            [QMUITips showError:@"个性签名不能超过30个字"];
            return;
        }
    }
    
    self.textValue = [self.inputTextField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet illegalCharacterSet]];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
