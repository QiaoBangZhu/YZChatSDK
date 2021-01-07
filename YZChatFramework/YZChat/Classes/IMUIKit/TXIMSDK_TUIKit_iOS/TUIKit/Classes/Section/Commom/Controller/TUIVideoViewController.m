//
//  TUIVideoViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/24.
//

#import "TUIVideoViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import <Masonry/Masonry.h>
#import <QMUIKit/QMUIKit.h>

@import MediaPlayer;
@import AVFoundation;
@import AVKit;

@interface TUIVideoViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *progress;
@property AVPlayerViewController *playerVc;

@property UIImage   *saveBackgroundImage;
@property UIImage   *saveShadowImage;
@property NSString* videoPath;
@property UIButton* downloadBtn;
@end

@implementation TUIVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.saveBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.saveShadowImage = self.navigationController.navigationBar.shadowImage;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];


    @weakify(self)
    if (![_data isVideoExist])
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.frame = self.view.bounds;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];

        if (_data.thumbImage == nil) {
            [_data downloadThumb];
        }

        _progress = [[UILabel alloc] initWithFrame:self.view.bounds];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:18];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.userInteractionEnabled = YES;
        [self.view addSubview:_progress];

        [RACObserve(_data, thumbImage) subscribeNext:^(UIImage *x) {
            @strongify(self)
            self.imageView.image = x;
        }];
        [RACObserve(_data, videoProgress) subscribeNext:^(NSNumber *x) {
            @strongify(self)
            int p = [x intValue];
            self.progress.text = [NSString stringWithFormat:@"%d%%", p];
        }];

        [_data downloadVideo];
    }

    [[[RACObserve(_data, videoPath) filter:^BOOL(NSString *path) {
        return [path length] > 0;
    }] take:1] subscribeNext:^(NSString *path) {
        @strongify(self)
        self.videoPath = path;
        [self addPlayer:path];
    }];
    
    _downloadBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_downloadBtn setTitle:@"保存相册" forState:UIControlStateNormal];
    [_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _downloadBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _downloadBtn.backgroundColor = [UIColor clearColor];
    _downloadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _downloadBtn.layer.borderWidth = 0.5;
    _downloadBtn.layer.cornerRadius = 3;
    [_downloadBtn.layer setMasksToBounds:YES];
    [_downloadBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadBtn];

    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerX.equalTo(@0);
        make.bottom.equalTo(@-100);
    }];
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
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self.navigationController.navigationBar setBackgroundImage:self.saveBackgroundImage
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = self.saveShadowImage;
    }
}

- (void)addPlayer:(NSString *)path
{
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
    vc.player = ({
        AVPlayer *p = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
        p;
    });
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc.player play];
    vc.view.frame = self.view.frame;
    self.progress.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveVideo {
   if (_videoPath) {
       if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_videoPath)) {
           UISaveVideoAtPathToSavedPhotosAlbum(_videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
       }
   }
}
//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
   if (error) {
       NSLog(@"保存视频失败%@", error.localizedDescription);
   }
   else {
       [QMUITips showSucceed:@"保存视频成功"];
   }
 
}


@end
