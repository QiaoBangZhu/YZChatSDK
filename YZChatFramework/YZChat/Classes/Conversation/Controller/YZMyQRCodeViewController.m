//
//  YZMyQRCodeViewController.m
//  YChat
//
//  Created by magic on 2020/11/17.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZMyQRCodeViewController.h"
#import "UIColor+ColorExtension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QRCodeManager.h"
#import <Masonry/Masonry.h>
#import "YUserInfo.h"
#import "YChatSettingStore.h"
#import <SDWebImage/SDWebImage.h>
#import "YDefaultPortraitView.h"
#import "YChatRequestBuilder.h"
#import "CIGAMKit.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"

@interface YZMyQRCodeViewController ()
@property (nonatomic, strong) UIView *qrBgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *mobileLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) UIView *shareBgView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *shareSealTalkBtn;
@property (nonatomic, strong) UIButton *shareWechatBtn;

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) YUserInfo *user;

@end

@implementation YZMyQRCodeViewController

#pragma mark - life cycle
- (instancetype)initWithTargetId:(NSString *)targetId {
    if (self = [super init]) {
        self.targetId = targetId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的二维码";
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    
    self.user = [[YChatSettingStore sharedInstance]getUserInfo];
    self.nameLabel.text  = self.user.nickName;
    self.mobileLabel.text = self.user.mobile;
    if (![self.user.userIcon isEqualToString:@""]) {
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:self.user.userIcon]
                                  placeholderImage:YZChatResource(@"my_defaultAvatarImage")];
    }
    if (!self.portraitImageView.image) {
        self.portraitImageView.image = [YDefaultPortraitView portraitView:self.targetId name:self.user.nickName];
    }
    NSString *qrInfo = [NSString stringWithFormat:@"%@?key=ychat://user/info?u=%@", YCHAT_REQUEST_BASE_URLS_PRODUCTION,
                        self.user.userId];
    self.qrCodeImageView.image = [QRCodeManager getQRCodeImage:qrInfo];

    [self addSubViews];
}

- (void)addSubViews {
    [self.view addSubview:self.qrBgView];
    [self.view addSubview:self.shareBgView];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
    [self.view addSubview:lineView];
    
    UILabel* tips = [[UILabel alloc]init];
    tips.text = @"扫一扫二维码,加我为好友";
    tips.font = [UIFont systemFontOfSize:12];
    tips.textColor = [UIColor colorWithHex:KCommonLittleLightGrayColor];
    [self.qrBgView addSubview:tips];
    
    [self.qrBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.offset(320);
        make.height.offset(370);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(45);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrBgView);
        make.height.offset(0.5);
        make.top.equalTo(self.qrBgView.mas_bottom);
    }];
    [self.shareBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrBgView);
        make.height.offset(50);
        make.top.equalTo(lineView.mas_bottom);
    }];
    
    [tips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.bottom.equalTo(@-6);
    }];

    [self addQrBgViewSubviews];
    [self addShareBgViewSubviews];
}

- (void)addShareBgViewSubviews {
    [self.shareBgView addSubview:self.saveButton];
//    [self.shareBgView addSubview:self.shareSealTalkBtn];
//    [self.shareBgView addSubview:self.shareWechatBtn];
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
    [self.shareBgView addSubview:lineView1];
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
    [self.shareBgView addSubview:lineView2];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.shareBgView);
        make.width.offset(320);
    }];
//    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.equalTo(self.shareBgView);
//        make.left.equalTo(self.saveButton.mas_right).offset(-0.5);
//        make.width.offset(0.5);
//    }];
//    [self.shareSealTalkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.equalTo(self.shareBgView);
//        make.left.equalTo(self.saveButton.mas_right);
//        make.right.equalTo(self.shareWechatBtn.mas_left);
//    }];
//    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.equalTo(self.shareBgView);
//        make.left.equalTo(self.shareSealTalkBtn.mas_right).offset(-0.5);
//        make.width.offset(0.5);
//    }];
//    [self.shareWechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.right.equalTo(self.shareBgView);
//        make.width.offset(320 / 3);
//    }];
}

- (void)addQrBgViewSubviews {
    [self.qrBgView addSubview:self.portraitImageView];
    [self.qrBgView addSubview:self.nameLabel];
    [self.qrBgView addSubview:self.mobileLabel];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
    [self.qrBgView addSubview:lineView];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.qrBgView).offset(20);
        make.width.height.offset(50);
    }];

    [self.qrBgView addSubview:self.qrCodeImageView];
    [self.qrBgView addSubview:self.infoLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitImageView.mas_right).offset(15);
        make.right.equalTo(self.qrBgView.mas_right).offset(-15);
        make.top.equalTo(self.portraitImageView.mas_top).offset(2);
        make.height.offset(28);
    }];
    
    [self.mobileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
    }];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.qrBgView);
        make.top.equalTo(self.qrBgView).offset(90);
        make.width.offset(280);
        make.height.offset(0.5);
    }];
    
    [self.qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.qrBgView);
        make.top.equalTo(self.qrBgView).offset(70);
        make.width.height.offset(280);
    }];
}

#pragma mark - getter
- (UIView *)qrBgView {
    if (!_qrBgView) {
        _qrBgView = [[UIView alloc] init];
        _qrBgView.backgroundColor = [UIColor whiteColor];
    }
    return _qrBgView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.layer.cornerRadius = 25;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithHex:0x262626];
        _nameLabel.font = [UIFont systemFontOfSize:20];
    }
    return _nameLabel;
}

- (UILabel *)mobileLabel {
    if (!_mobileLabel) {
        _mobileLabel = [[UILabel alloc]init];
        _mobileLabel.textColor = [UIColor colorWithHex:KCommonBubbleTextGrayColor];
        _mobileLabel.font  = [UIFont systemFontOfSize:12];
    }
    return _mobileLabel;
}


- (UIImageView *)qrCodeImageView {
    if (!_qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc] init];
        _qrCodeImageView.backgroundColor = [UIColor redColor];
    }
    return _qrCodeImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor colorWithHex:0x939393];
        _infoLabel.font = [UIFont systemFontOfSize:13];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

- (UIView *)shareBgView {
    if (!_shareBgView) {
        _shareBgView = [[UIView alloc] init];
        _shareBgView.backgroundColor = [UIColor whiteColor];
    }
    return _shareBgView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton setTitleColor:[UIColor colorWithHex:0x0099ff] forState:(UIControlStateNormal)];
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_saveButton setTitle:@"保存到相册" forState:(UIControlStateNormal)];
        [_saveButton addTarget:self
                        action:@selector(didClickSaveAction)
              forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _saveButton;
}

- (UIButton *)shareSealTalkBtn {
    if (!_shareSealTalkBtn) {
        _shareSealTalkBtn = [[UIButton alloc] init];
        [_shareSealTalkBtn setTitleColor:[UIColor colorWithHex:0x0099ff] forState:(UIControlStateNormal)];
        _shareSealTalkBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_shareSealTalkBtn setTitle:@"分享到元讯" forState:(UIControlStateNormal)];
        [_shareSealTalkBtn addTarget:self
                              action:@selector(didShareYuanChatAction)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _shareSealTalkBtn;
}

- (UIButton *)shareWechatBtn {
    if (!_shareWechatBtn) {
        _shareWechatBtn = [[UIButton alloc] init];
        [_shareWechatBtn setTitleColor:[UIColor colorWithHex:0x0099ff] forState:(UIControlStateNormal)];
        _shareWechatBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_shareWechatBtn setTitle:@"分享到微信" forState:(UIControlStateNormal)];
        [_shareWechatBtn addTarget:self
                            action:@selector(didShareWechatBtnAction)
                  forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _shareWechatBtn;
}

- (void)didClickSaveAction {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:@"无法访问"
                             message:@"您没有照片访问权限，请前往“设置-隐私-照片”选项中，允许访问您的手机照片!"
                      preferredStyle:UIAlertControllerStyleAlert];
        [alertController
        addAction:[UIAlertAction actionWithTitle:@"确定"                                               style:UIAlertActionStyleDefault
                                             handler:nil]];
        [rootVC presentViewController:alertController animated:YES completion:nil];
    } else {
        [self saveImageToPhotos:[self captureCurrentView:self.qrBgView]];
    }
}

- (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)saveImageToPhotos:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        [CIGAMTips showSucceed:@"保存成功"];
    } else {
        [CIGAMTips showError:@"保存失败"];
    }
}

- (void)didShareYuanChatAction {
    
}

- (void)didShareWechatBtnAction {
    
}

@end
