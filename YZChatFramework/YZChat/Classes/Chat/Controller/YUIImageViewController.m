//
//  YUIImageViewController.m
//  YChat
//
//  Created by magic on 2020/10/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIImageViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TScrollView.h"
#import "MMLayout/UIView+MMLayout.h"
#import <Masonry/Masonry.h>
#import "CIGAMKit.h"
#import "WeChatActionSheet.h"
#import <Photos/Photos.h>

@interface YUIImageViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *downloadBtn;

@property (nonatomic, strong) UILabel *progress;
@property TScrollView *imageScrollView;

@property UIImage *saveBackgroundImage;
@property UIImage *saveShadowImage;

@end

@implementation YUIImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.saveBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.saveShadowImage = self.navigationController.navigationBar.shadowImage;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.imageScrollView = [[TScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.imageScrollView];
    self.imageScrollView.backgroundColor = [UIColor blackColor];
    [self.imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    self.imageView = [[UIImageView alloc] initWithImage:nil];
    self.imageScrollView.imageView = self.imageView;
    self.imageScrollView.maximumZoomScale = 4.0;
    self.imageScrollView.delegate = self;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAction)];
    [self.imageView addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showAlert:)];
    longPress.minimumPressDuration = 1;
    [self.imageView addGestureRecognizer:longPress];
    

    BOOL isExist = NO;
    [_data getImagePath:TImage_Type_Origin isExist:&isExist];
    if (isExist) {
        if(_data.originImage) {
            _imageView.image = _data.originImage;
        } else {
            [_data decodeImage:TImage_Type_Origin];
            @weakify(self)
            [RACObserve(_data, originImage) subscribeNext:^(UIImage *x) {
                @strongify(self)
                self.imageView.image = x;
                [self.imageScrollView setNeedsLayout];
            }];
        }
    } else {
        _imageView.image = _data.thumbImage;

        _progress = [[UILabel alloc] initWithFrame:self.view.bounds];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:18];
        _progress.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_progress];

//        _button = [[UIButton alloc] initWithFrame:CGRectZero];
//        [_button setTitle:@"查看原图" forState:UIControlStateNormal];
//        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        _button.titleLabel.font = [UIFont systemFontOfSize:13];
//        _button.backgroundColor = [UIColor clearColor];
//        _button.layer.borderColor = [UIColor whiteColor].CGColor;
//        _button.layer.borderWidth = 0.5;
//        _button.layer.cornerRadius = 3;
//        [_button.layer setMasksToBounds:YES];
//        [_button addTarget:self action:@selector(downloadOrigin:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_button];
    }
    
//    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@80);
//        make.height.equalTo(@30);
//        make.centerX.equalTo(@0);
//        make.bottom.equalTo(@-60);
//    }];
//
//    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@80);
//        make.height.equalTo(@30);
//        make.centerX.equalTo(@0);
//        make.bottom.equalTo(@-100);
//    }];
}

- (void)showAlert:(UILongPressGestureRecognizer*)ges {
    if (ges.state != UIGestureRecognizerStateBegan) {
        return;
    }
    WeChatActionSheet *sheet = [WeChatActionSheet showActionSheet:nil buttonTitles:@[@"保存相册",@"查看原图"]];
    [sheet setFunction:^(WeChatActionSheet *actionSheet,NSInteger index){
       if (index == WECHATCANCELINDEX) {
       }else{
           if (index == 0) {
               [self saveImage];
           }
           if (index == 1) {
               [self downloadOrigin:nil];
           }
       }
   }];
}

- (void)downloadOrigin:(id)sender
{
    [_data downloadImage:TImage_Type_Origin];
    @weakify(self)
    [RACObserve(_data, originImage) subscribeNext:^(UIImage *x) {
        @strongify(self)
        if (x) {
            self.imageView.image = x;
            [self.imageScrollView setNeedsLayout];
            self.progress.hidden = YES;
        }
    }];
    [RACObserve(_data, originProgress) subscribeNext:^(NSNumber *x) {
        @strongify(self)
        int progress = [x intValue];
        self.progress.text =  [NSString stringWithFormat:@"%d%%", progress];
        if (progress >= 100)
            self.progress.hidden = YES;
    }];
    self.button.hidden = YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBarHidden = NO;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self.navigationController.navigationBar setBackgroundImage:self.saveBackgroundImage
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = self.saveShadowImage;
    }
}

- (void)dismissAction {
    [self.navigationController popViewControllerAnimated:false];
}

- (void)saveImage {
    PHAuthorizationStatus current = [PHPhotoLibrary authorizationStatus];
    switch (current) {
        case PHAuthorizationStatusNotDetermined:    //用户还没有选择(第一次)
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            //弹出访问权限提示框
            if (status == PHAuthorizationStatusAuthorized) {
                [self savePhotosAlbum];
             }else {
                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"无法保存" message:@"请在iPhone的\"设置-隐私-照片选项中,允许元讯访问你的照片" preferredStyle:UIAlertControllerStyleAlert];
                 [ac addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil]];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.navigationController presentViewController:ac animated:YES completion:nil];
                 });
                 return;
            }
          }];
        }
            break;
        case PHAuthorizationStatusRestricted:       //家长控制
        {
        }
            break;
        case PHAuthorizationStatusDenied:           //用户拒绝
        {
        }
            break;
        case PHAuthorizationStatusAuthorized:       //已授权
        {
            [self savePhotosAlbum];
        }
            break;
        default:
            break;
    }
}

//保存图片
- (void)savePhotosAlbum {
    if (_data.originImage) {
        UIImageWriteToSavedPhotosAlbum(_data.originImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }else {
        UIImageWriteToSavedPhotosAlbum(_data.thumbImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [CIGAMTips showError:error.localizedDescription];
        NSLog(@"保存图片出错%@", error.localizedDescription);
    }else {
        [CIGAMTips showSucceed:@"保存成功"];
    }
}

@end
