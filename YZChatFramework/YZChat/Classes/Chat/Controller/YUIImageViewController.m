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
#import <QMUIKit/QMUIKit.h>
#import "WeChatActionSheet.h"

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

        _button = [[UIButton alloc] initWithFrame:CGRectZero];
        [_button setTitle:@"查看原图" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:13];
        _button.backgroundColor = [UIColor clearColor];
        _button.layer.borderColor = [UIColor whiteColor].CGColor;
        _button.layer.borderWidth = 0.5;
        _button.layer.cornerRadius = 3;
        [_button.layer setMasksToBounds:YES];
        [_button addTarget:self action:@selector(downloadOrigin:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }
    
    _downloadBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_downloadBtn setTitle:@"保存相册" forState:UIControlStateNormal];
    [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _downloadBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _downloadBtn.backgroundColor = [UIColor clearColor];
    _downloadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _downloadBtn.layer.borderWidth = 0.5;
    _downloadBtn.layer.cornerRadius = 3;
    [_downloadBtn.layer setMasksToBounds:YES];
    [_downloadBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadBtn];
    
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerX.equalTo(@0);
        make.bottom.equalTo(@-60);
    }];
    
    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerX.equalTo(@0);
        make.bottom.equalTo(@-100);
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
    //保存图片
    if (_data.originImage) {
        UIImageWriteToSavedPhotosAlbum(_data.originImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }else {
        UIImageWriteToSavedPhotosAlbum(_data.thumbImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存图片出错%@", error.localizedDescription);
    }else {
        [QMUITips showSucceed:@"保存成功"];
    }
}

@end
