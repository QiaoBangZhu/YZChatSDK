//
//  QRScanViewController.m
//  YChat
//
//  Created by magic on 2020/11/17.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "QRScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YScannerView.h"
#import "QRCodeManager.h"
#import "YQRInfoHandle.h"
#import "CIGAMKit.h"
#import "UIColor+ColorExtension.h"

@interface QRScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,YScannerViewDelegate>

/** 扫描器 */
@property (nonatomic, strong) YScannerView *scannerView;
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation QRScanViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scannerView];
    [self setNavi];
    [self checkCameraAuthorizationStatus];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resumeScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scannerView rcd_setFlashlightOn:NO];
    [self.scannerView rcd_hideFlashlightWithAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark-- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output
    didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects
              fromConnection:(AVCaptureConnection *)connection {
    // 获取扫一扫结果
    if (metadataObjects && metadataObjects.count > 0) {
        [self pauseScanning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *stringValue = metadataObject.stringValue;
        [self rcd_handleWithValue:stringValue];
    } else {
        [self showErrorAlertView];
    }
}

#pragma mark -  RCDScannerViewDelegate
- (void)didClickSelectImageButton {
    [self showAlbum];
}

#pragma mark-- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    [CIGAMTips showLoading:@"扫描中" inView:self.view];
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    // 获取选择图片中识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(pickImage)]];

    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (features.count > 0) {
                                       CIQRCodeFeature *feature = features[0];
                                       NSString *stringValue = feature.messageString;
                                       [self rcd_handleWithValue:stringValue];
                                   } else {
                                       [self rcd_didReadFromAlbumFailed];
                                   }
                                    [CIGAMTips hideAllTips];
                               }];
}

#pragma mark - private
- (void)showErrorAlertView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"confirm", @"RongCloudKit", nil)
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *_Nonnull action){
                                             }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"二维码识别不出来"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }]];
    });
}

- (void)setNavi {
    self.navigationItem.title = @"扫一扫";
    
    UIButton *albumBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [albumBtn addTarget:self action:@selector(didClickSelectImageButton) forControlEvents:UIControlEventTouchUpInside];
    [albumBtn setTitle:@"相册  " forState:UIControlStateNormal];
    [albumBtn setTitleColor:[UIColor colorWithHex:KCommonBlackColor] forState:UIControlStateNormal];
    UIBarButtonItem *albumItem = [[UIBarButtonItem alloc] initWithCustomView:albumBtn];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -15;
    self.navigationItem.rightBarButtonItems =  @[spaceItem,albumItem];
}

- (void)checkCameraAuthorizationStatus {
    // 校验相机权限
    [QRCodeManager rcd_checkCameraAuthorizationStatusWithGrand:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupScanner];
            });
        }
    }];
}

/** 创建扫描器 */
- (void)setupScanner {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    metadataOutput.rectOfInterest = CGRectMake([self.scannerView scanner_y] / self.view.frame.size.height,
                                               [self.scannerView scanner_x] / self.view.frame.size.width,
                                               [self.scannerView scanner_width] / self.view.frame.size.height,
                                               [self.scannerView scanner_width] / self.view.frame.size.width);

    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];

    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
    }
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
    }
#if TARGET_IPHONE_SIMULATOR
// 模拟器设置不了，会crash
#else
    if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode ];
    }
#endif

    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:videoPreviewLayer atIndex:0];

    [self.session startRunning];
}

- (void)pushImagePicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
//    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showAlbum {
    // 校验相册权限
    [QRCodeManager rcd_checkAlbumAuthorizationStatusWithGrand:^(BOOL granted) {
        if (granted) {
            [self pushImagePicker];
        }
    }];
}

- (void)appDidBecomeActive:(NSNotification *)notify {
    [self resumeScanning];
}

- (void)appWillResignActive:(NSNotification *)notify {
    [self pauseScanning];
    [self.scannerView rcd_hideFlashlightWithAnimated:YES];
}

/** 恢复扫一扫功能 */
- (void)resumeScanning {
    if (self.session) {
        [self.session startRunning];
        [self.scannerView rcd_addScannerLineAnimation];
    }
}

/** 暂停扫一扫功能 */
- (void)pauseScanning {
    if (self.session) {
        [self.session stopRunning];
        [self.scannerView rcd_pauseScannerLineAnimation];
    }
}

/**
 处理扫一扫结果
 @param value 扫描结果
 */
- (void)rcd_handleWithValue:(NSString *)value {
    [[YQRInfoHandle sharedInstance] identifyQRCode:value base:self];
}

/**
 相册选取图片无法读取数据
 */
- (void)rcd_didReadFromAlbumFailed {
    [[YQRInfoHandle alloc] identifyQRCode:@"" base:self];
}

#pragma mark - getter & setter
- (YScannerView *)scannerView {
    if (!_scannerView) {
        _scannerView = [[YScannerView alloc] initWithFrame:self.view.bounds];
        _scannerView.delegate = self;
    }
    return _scannerView;
}
@end
