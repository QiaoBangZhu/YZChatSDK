//
//  TUIAudioCallViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/7.
//

#import <AudioToolbox/AudioToolbox.h>
#import "TUIVideoCallViewController.h"
#import "TUIVideoCallUserCell.h"
#import "TUIVideoRenderView.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import <AVFoundation/AVFoundation.h>
#import "TCUtil.h"
#import <Masonry/Masonry.h>
#import <QMUIKit/QMUIKit.h>
#import <TMRTC/TMRTC.h>
#import "UIColor+Foundation.h"
#import "VideoCallUserView.h"
#import "YChatNetworkEngine.h"
#import "YChatSettingStore.h"
#import "YZBaseManager.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"

#define kSmallVideoWidth 100.0

@interface TUIVideoCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,assign) VideoCallState curState;
@property(nonatomic,assign) CGFloat topPadding;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *avaliableList;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *userList;
@property(nonatomic,strong) CallUserModel *curSponsor;
@property(nonatomic,strong) UICollectionView *userCollectionView;
@property(nonatomic,assign) BOOL refreshCollectionView;
@property(nonatomic,assign) NSInteger collectionCount;
@property(nonatomic,strong) UIButton *hangup;
@property(nonatomic,strong) UIButton *accept;
@property(nonatomic,strong) QMUIButton *mute;
@property(nonatomic,strong) QMUIButton *handsfree;
@property(nonatomic,strong) QMUIButton *cameraSwitch;
@property(nonatomic,strong) UILabel *callTimeLabel;
@property(nonatomic,strong) UIView *localPreView;
@property(nonatomic,strong) UIView *sponsorPanel;
@property(nonatomic,strong) NSMutableArray<TUIVideoRenderView *> *renderViews;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) UInt32 callingTime;
@property(nonatomic,assign) BOOL playingAlerm; // 播放响铃
@property(nonatomic,assign) BOOL isInGrp;

//播放铃声
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, assign) BOOL needPlayingAlertAfterForeground;
@property(nonatomic, assign) BOOL needPlayingRingAfterForeground;
@property(nonatomic,   weak) NSTimer *vibrateTimer;
@property(nonatomic, strong) UIView *myInfoContentView;
@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UILabel *nicknameLabel;
@property(nonatomic, assign) CGFloat avatarWidth;
@property(nonatomic, strong) UIView *remoteInfoContentView;
@property(nonatomic, strong) UIImageView* remoteAvatarImageView;
@property(nonatomic, strong) UILabel* remoteNicknameLabel;
@property(nonatomic, assign) BOOL isSmallView;
@property(nonatomic, strong) VideoCallUserView* localPreHiddenCameraView;

@end

@implementation TUIVideoCallViewController
{
    VideoCallState _curState;
    UILabel *_callTimeLabel;
    UIView *_localPreview;
    UIView *_sponsorPanel;
    UICollectionView *_userCollectionView;
    NSInteger _collectionCount;
    NSMutableArray *_userList;
}

- (instancetype)initWithSponsor:(CallUserModel *)sponsor userList:(NSMutableArray<CallUserModel *> *)userList isInGroup:(BOOL)isInGrp {
    self = [super init];
    if (self) {
        self.curSponsor = sponsor;
        self.isInGrp = isInGrp;
        [self registerForegroundNotification];
        if (sponsor) {
            self.curState = VideoCallState_OnInvitee;
        } else {
            self.curState = VideoCallState_Dailing;
        }
        self.renderViews = [NSMutableArray array];
        self.userList = [NSMutableArray array];
        [self resetUserList:^{
            for (CallUserModel *model in userList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    [self.userList addObject:model];
                }
            }
            [self setupSponsorPanel];
            [self autoSetUIByState];
        }];
        self.needPlayingRingAfterForeground = YES;
    }
    return self;
}

- (void)resetUserList:(void(^)(void))finished {
    if (self.curSponsor) {
        if (self.isInGrp && (self.curState == VideoCallState_OnInvitee)) {
            @weakify(self)
            [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
                @strongify(self)
                model.isEnter = YES;
                model.isVideoAvaliable = YES;
                [self.userList addObject:model];
                
                [self.userList addObject:self.curSponsor];
                finished();
            }];
        }else {
            self.curSponsor.isVideoAvaliable = NO;
            [self.userList addObject:self.curSponsor];
            finished();
        }
    } else {
        @weakify(self)
        [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
            @strongify(self)
            model.isEnter = YES;
            model.isVideoAvaliable = YES;
            [self.userList addObject:model];
            finished();
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCallView:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.curState == VideoCallState_OnInvitee) {
        if (self.needPlayingRingAfterForeground) {
            [self shouldRingForIncomingCall];
        }
    }
//    [self playAlerm];
    
    //呼出后立刻振铃
     if (self.curState == VideoCallState_Dailing) {
         [self performSelector:@selector(checkApplicationStateAndAlert) withObject:nil afterDelay:1];
     }
}

- (void)startVibrate {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况按静音或者锁屏键会静音
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [self triggerVibrate];
    [audioSession setActive:YES error:nil];

}

- (void)disMiss {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    [[YZBaseManager shareInstance] statisticsUsedTime:self.callingTime isVideo:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
//    [self stopAlerm];
    [self shouldStopAlertAndRing];
}

- (void)dealloc {
    [[TUICall shareInstance] closeCamara];
    [self stopPlayRing];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterUser:(CallUserModel *)user {
    if (![user.userId isEqualToString:[TUICallUtils loginUser]]) {
        TUIVideoRenderView *renderView = [[TUIVideoRenderView alloc] init];
        renderView.userModel = user;
        [renderView fillWithData:user layout:(self.isSmallView == true ? CallViewLayoutStyleSmall : CallViewLayoutStyleBig)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [renderView addGestureRecognizer:tap];
        [pan requireGestureRecognizerToFail:tap];
        [renderView addGestureRecognizer:pan];
        [self.renderViews addObject:renderView];
        [[TUICall shareInstance] startRemoteView:user.userId view:renderView];
//        [self stopAlerm];
        [self shouldStopAlertAndRing];
        if (_isInGrp) {
            [UIView performWithoutAnimation:^{
                [self.userCollectionView reloadData];
            }];
        }
    }
    self.curState = VideoCallState_Calling;
    [self updateUser:user animate:YES];
}

- (void)leaveUser:(NSString *)userId {
    [[TUICall shareInstance] stopRemoteView:userId];
    for (TUIVideoRenderView *renderView in self.renderViews) {
        if ([renderView.userModel.userId isEqualToString:userId]) {
            [self.renderViews removeObject:renderView];
            break;
        }
    }
    for (CallUserModel *model in self.userList) {
        if ([model.userId isEqualToString:userId]) {
            BOOL isVideoAvaliable = model.isVideoAvaliable;
            [self.userList removeObject:model];
            [self updateCallView:isVideoAvaliable];
            break;
        }
    }
}

- (void)updateUser:(CallUserModel *)user animate:(BOOL)animate {
    BOOL findUser = NO;
    for (int i = 0; i < self.userList.count; i ++) {
        CallUserModel *model = self.userList[i];
        if ([model.userId isEqualToString:user.userId]) {
            model = user;
            findUser = YES;
            break;
        }
    }
    if (!findUser) {
        [self.userList addObject:user];
    }
    [self updateCallView:animate];
}

- (void)updateCallView:(BOOL)animate {
    if (!self.isInGrp) {
        // 展示 1v1 视频通话
        [self show1to1CallView];
    } else {
        // 展示多人视频通话
        [self showMultiCallView:animate];
    }
}

- (void)show1to1CallView {
    self.refreshCollectionView = NO;
    if (self.collectionCount == 2) {
        [self setLocalViewInVCView:CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0) shouldTap:YES];
        CallUserModel *userFirst;
        for (CallUserModel *model in self.avaliableList) {
            if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                userFirst = model;
                break;
            }
        }
        if (userFirst) {
            TUIVideoRenderView *firstRender = [self getRenderView:userFirst.userId];
            if (firstRender) {
                firstRender.userModel = userFirst;
                [firstRender fillWithData:userFirst layout:(self.isSmallView == true ? CallViewLayoutStyleSmall : CallViewLayoutStyleBig)];

                if (![firstRender.superview isEqual:self.view]) {
                    [firstRender removeFromSuperview];
                    [self.view insertSubview:firstRender belowSubview:self.localPreView];
                    
                    if (self.isSmallView) {
                        [UIView animateWithDuration:0.1 animations:^{
                            firstRender.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
                            self.localPreView.frame = self.view.bounds;
                        }];
                    }else {
                        [UIView animateWithDuration:0.1 animations:^{
                            firstRender.frame = self.view.bounds;
                        }];
                    }
                } else {
                    if (self.isSmallView) {
                        [firstRender removeFromSuperview];
                        [self.view insertSubview:firstRender aboveSubview:self.localPreView];
                        firstRender.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
                        self.localPreView.frame = self.view.bounds;
                    }else {
                        self.isSmallView = NO;
                        firstRender.frame = self.view.bounds;
                    }
                }
                
                if (userFirst.isVideoAvaliable == NO) {
                    [self setupRemoteInfoView:firstRender];
                }else {
                    [self.remoteInfoContentView removeFromSuperview];
                }
            } else {
                NSLog(@"getRenderView error");
            }
        }
    } else { //用户退出只剩下自己（userleave引起的）
        if (self.collectionCount == 1) {
            [self setLocalViewInVCView:[UIApplication sharedApplication].keyWindow.bounds shouldTap:NO];
        }
    }
    [self bringControlBtnToFront];
}

- (void)showMultiCallView:(BOOL)animate {
    self.refreshCollectionView = YES;
    [self.view bringSubviewToFront:self.userCollectionView];
    [UIView performWithoutAnimation:^{
        self.userCollectionView.mm_top(self.collectionCount == 1 ? (self.topPadding + 62) : self.topPadding).mm_flexToBottom(132);
        [self.userCollectionView reloadData];
    }];
    [self bringControlBtnToFront];
}

- (void)bringControlBtnToFront {
    [self.view bringSubviewToFront:self.accept];
    [self.view bringSubviewToFront:self.hangup];
    [self.view bringSubviewToFront:self.mute];
    [self.view bringSubviewToFront:self.handsfree];
    [self.view bringSubviewToFront:self.sponsorPanel];
    [self.view bringSubviewToFront:self.cameraSwitch];
}

#pragma mark UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHex:0x2C2C2C];
    if (@available(iOS 11.0, *) ){
        self.topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    if (_isInGrp) {
        self.topPadding = 100;
    }

    [self setupSponsorPanel];
    [self autoSetUIByState];
    [[TUICall shareInstance] openCamera:YES view:self.localPreView];
}

- (void)setupSponsorPanel {
    [self.view addSubview:self.sponsorPanel];
    self.sponsorPanel.mm_top(self.topPadding + 18).mm_width(self.view.mm_w).mm_height(60);
    //发起者头像
    UIImageView *userImage = [[UIImageView alloc] init];
    [self.sponsorPanel addSubview:userImage];
    userImage.mm_width(60).mm_height(60).mm_right(18);
    userImage.layer.cornerRadius = 30;
    userImage.layer.masksToBounds = YES;

    //发起者名字
    UILabel *userName = [[UILabel alloc] init];
    userName.textAlignment = NSTextAlignmentRight;
    userName.font = [UIFont boldSystemFontOfSize:30];
    userName.textColor = [UIColor whiteColor];
    userName.text = self.curSponsor.name;
    [self.sponsorPanel addSubview:userName];
    [userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.right.equalTo(userImage.mas_left).offset(-12);
        make.top.equalTo(userImage.mas_top).offset(4);
    }];
    
//    userName.mm_width(100).mm_height(30).mm_right(userImage.mm_r + userImage.mm_w + 6);
    //提醒文字
    UILabel *invite = [[UILabel alloc] init];
    invite.textAlignment = NSTextAlignmentRight;
    invite.font = [UIFont systemFontOfSize:13];
    invite.textColor = [UIColor whiteColor];
    [self.sponsorPanel addSubview:invite];
//    invite.mm_width(150).mm_height(15).mm_right(userName.mm_r).mm_top(userName.mm_b + 12);
    [invite mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(userImage.mas_left).offset(-12);
        make.bottom.equalTo(@-4);
        make.width.equalTo(@150);
    }];

    if (self.curSponsor) {
        //隐藏 accept
        self.accept.hidden = NO;
        [userImage sd_setImageWithURL:[NSURL URLWithString:self.curSponsor.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
        userName.text = self.curSponsor.name;
        invite.text = @"邀请你视频通话";
    } else {
        if (self.curState == VideoCallState_Dailing) {
            if (self.collectionCount <= 2) {
                for (CallUserModel* model in self.userList) {
                    if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                        [userImage sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
                        userName.text = model.name;
                        return;
                    }
                }
            }
            invite.text = @"正在等待对方接受邀请...";
        }
        self.accept.hidden = YES;
    }
}

- (void)autoSetUIByState {
    if (self.curSponsor) {
        self.sponsorPanel.hidden = (self.curState == VideoCallState_Calling);
    }
    switch (self.curState) {
        case VideoCallState_Dailing:
        {
            self.hangup.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX).mm_bottom(106);
            self.sponsorPanel.hidden = self.isInGrp;
        }
            break;
        case VideoCallState_OnInvitee:
        {
            self.hangup.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX - 80).mm_bottom(52);
            self.accept.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX + 80).mm_bottom(52);
            self.sponsorPanel.hidden = self.isInGrp;
        }
            break;
        case VideoCallState_Calling:
        {
            self.hangup.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX).mm_bottom(52);
            self.mute.mm_width(55).mm_height(85).mm__centerX(self.view.mm_centerX - 120).mm_bottom(150);
            self.handsfree.mm_width(55).mm_height(85).mm__centerX(self.view.mm_centerX).mm_bottom(150);
            self.cameraSwitch.mm_width(55).mm_height(85).mm__centerX(self.view.mm_centerX + 120).mm_bottom(150);
            self.callTimeLabel.mm_width(50).mm_height(30).mm__centerX(self.view.mm_centerX).mm_bottom(20);
            
            self.mute.hidden = NO;
            self.handsfree.hidden = NO;
            self.callTimeLabel.hidden = NO;
            self.mute.alpha = 0.0;
            self.handsfree.alpha = 0.0;
            self.sponsorPanel.hidden = YES;
            [self startCallTiming];
        }
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        if (self.curState == VideoCallState_Calling) {
            self.mute.alpha = 1.0;
            self.handsfree.alpha = 1.0;
        }
        if (self.isInGrp) {
            [self.userCollectionView reloadData];
        }
    }];
}

- (void)startCallTiming {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    self.callingTime = 0;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.callingTime / 60, (int)self.callingTime % 60];
            self.callingTime += 1;
        });
    });
    dispatch_resume(self.timer);
}

- (void)setLocalViewInVCView:(CGRect)frame shouldTap:(BOOL)shouldTap {
    if (CGRectEqualToRect(self.localPreView.frame, frame)) {
        return;
    }
    [self.localPreView setUserInteractionEnabled:shouldTap];
    [self.localPreView.subviews.firstObject setUserInteractionEnabled:!shouldTap];
    if (![self.localPreView.superview isEqual:self.view]) {
        [self.localPreView removeFromSuperview];
        [self.view insertSubview:self.localPreView aboveSubview:self.userCollectionView];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.localPreView.frame = frame;
//        self.localPreHiddenCameraView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }];
}

- (UIButton *)hangup {
    if (!_hangup.superview) {
        _hangup = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangup setImage:YZChatResource(@"ic_hangup") forState:UIControlStateNormal];
        [_hangup addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hangup];
    }
    return _hangup;
}

- (QMUIButton *)cameraSwitch {
    if (!_cameraSwitch.superview) {
        _cameraSwitch = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_cameraSwitch setImage:YZChatResource(@"icon_camera_off") forState:UIControlStateNormal];
        [_cameraSwitch setImage:YZChatResource(@"icon_camera_on") forState:UIControlStateSelected];
        [_cameraSwitch addTarget:self action:@selector(cameraSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraSwitch setTitle:@"摄像头" forState:UIControlStateNormal];
        _cameraSwitch.titleLabel.font = [UIFont systemFontOfSize:12];
        [_cameraSwitch setTitleColor:[UIColor colorWithRed:249/255.0 green:250/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_cameraSwitch setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _cameraSwitch.selected = true;
        _cameraSwitch.imagePosition = QMUIButtonImagePositionTop;
        _cameraSwitch.spacingBetweenImageAndTitle = 8;
        [self.view addSubview:_cameraSwitch];
    }
    return _cameraSwitch;
}

- (UIButton *)accept {
    if (!_accept.superview) {
        _accept = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accept setImage:YZChatResource(@"ic_dialing") forState:UIControlStateNormal];
        [_accept addTarget:self action:@selector(acceptClick) forControlEvents:UIControlEventTouchUpInside];
        _accept.hidden = (self.curSponsor == nil);
        [self.view addSubview:_accept];
    }
    return _accept;
}

- (QMUIButton *)mute {
    if (!_mute.superview) {
        _mute = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_mute setImage:YZChatResource(@"ic_mute") forState:UIControlStateNormal];
        [_mute addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
        _mute.hidden = YES;
        [_mute setTitle:@"静音" forState:UIControlStateNormal];
        _mute.titleLabel.font = [UIFont systemFontOfSize:12];
        [_mute setTitleColor:[UIColor colorWithRed:249/255.0 green:250/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_mute setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _mute.imagePosition = QMUIButtonImagePositionTop;
        _mute.spacingBetweenImageAndTitle = 8;
        [self.view addSubview:_mute];
    }
    return _mute;
}

- (QMUIButton *)handsfree {
    if (!_handsfree.superview) {
        _handsfree = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_handsfree setImage:YZChatResource(@"ic_handsfree_on") forState:UIControlStateNormal];
        [_handsfree setImage:YZChatResource(@"ic_handsfree") forState:UIControlStateSelected];
        [_handsfree setTitle:@"免提" forState:UIControlStateNormal];
        _handsfree.titleLabel.font = [UIFont systemFontOfSize:12];
        [_handsfree setTitleColor:[UIColor colorWithRed:249/255.0 green:250/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_handsfree setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_handsfree addTarget:self action:@selector(handsfreeClick) forControlEvents:UIControlEventTouchUpInside];
        _handsfree.hidden = YES;
        _handsfree.imagePosition = QMUIButtonImagePositionTop;
        _handsfree.spacingBetweenImageAndTitle = 8;
        [self.view addSubview:_handsfree];
    }
    return _handsfree;
}

- (UILabel *)callTimeLabel {
    if (!_callTimeLabel.superview) {
        _callTimeLabel = [[UILabel alloc] init];
        _callTimeLabel.backgroundColor = [UIColor clearColor];
        _callTimeLabel.text = @"00:00";
        _callTimeLabel.textColor = [UIColor whiteColor];
        _callTimeLabel.textAlignment = NSTextAlignmentCenter;
        _callTimeLabel.hidden = YES;
        [self.view addSubview:_callTimeLabel];
    }
    return _callTimeLabel;
}

- (UIView *)sponsorPanel {
    if (!_sponsorPanel.superview) {
        _sponsorPanel = [[UIView alloc] init];
        _sponsorPanel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_sponsorPanel];
    }
    return _sponsorPanel;
}

- (UIView *)remoteInfoContentView {
    if (!_remoteInfoContentView) {
        _remoteInfoContentView = [[UIView alloc]init];
        _remoteInfoContentView.backgroundColor = [UIColor colorWithHex:0x2C2C2C];
        [_remoteInfoContentView addSubview:self.remoteAvatarImageView];
        [_remoteInfoContentView addSubview:self.remoteNicknameLabel];
    }
    return _remoteInfoContentView;
}


- (UIView *)myInfoContentView {
    if (!_myInfoContentView) {
        _myInfoContentView = [[UIView alloc]init];
        _myInfoContentView.backgroundColor = [UIColor colorWithHex:0x2C2C2C];
        [_myInfoContentView addSubview:self.avatarImageView];
        [_myInfoContentView addSubview:self.nicknameLabel];
    }
    return _myInfoContentView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc]init];
        _nicknameLabel.font = [UIFont systemFontOfSize:14];
        _nicknameLabel.textColor = [UIColor whiteColor];
    }
    return _nicknameLabel;
}

- (UIImageView *)remoteAvatarImageView {
    if (!_remoteAvatarImageView) {
        _remoteAvatarImageView = [[UIImageView alloc]init];
        _remoteAvatarImageView.layer.masksToBounds = YES;
    }
    return _remoteAvatarImageView;
}

- (UILabel *)remoteNicknameLabel {
    if (!_remoteNicknameLabel) {
        _remoteNicknameLabel = [[UILabel alloc]init];
        _remoteNicknameLabel.font = [UIFont systemFontOfSize:14];
        _remoteNicknameLabel.textColor = [UIColor whiteColor];
    }
    return _remoteNicknameLabel;
}

- (VideoCallUserView *)localPreHiddenCameraView {
    if (!_localPreHiddenCameraView) {
        _localPreHiddenCameraView = [[VideoCallUserView alloc]init];
        _localPreHiddenCameraView.backgroundColor = [UIColor colorWithHex:0x2C2C2C];
    }
    return _localPreHiddenCameraView;
}

- (UIView *)localPreView {
    if (!_localPreView) {
        _localPreView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_localPreView setUserInteractionEnabled:NO];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_localPreView addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [pan requireGestureRecognizerToFail:tap];
        [_localPreView addGestureRecognizer:pan];
        [self.view addSubview:_localPreView];
    }
    return _localPreView;
}

- (UICollectionView *)userCollectionView {
    if (!_userCollectionView.superview) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100) collectionViewLayout:layout];
        [_userCollectionView registerClass:[TUIVideoCallUserCell class] forCellWithReuseIdentifier:TUIVideoCallUserCell_ReuseId];
        if (@available(iOS 10.0, *)) {
            [_userCollectionView setPrefetchingEnabled:YES];
        } else {
            // Fallback on earlier versions
        }
        _userCollectionView.showsVerticalScrollIndicator = NO;
        _userCollectionView.showsHorizontalScrollIndicator = NO;
        _userCollectionView.contentMode = UIViewContentModeScaleToFill;
        _userCollectionView.backgroundColor = [UIColor clearColor];
        _userCollectionView.dataSource = self;
        _userCollectionView.delegate = self;
        [self.view addSubview:_userCollectionView];
        _userCollectionView.mm_top(self.topPadding + 62).mm_flexToBottom(132);
    }
    return _userCollectionView;
}

#pragma mark - 响铃🔔
// 播放铃声
- (void)playAlerm {
    self.playingAlerm = YES;
    [self loopPlayAlert];
}

// 结束播放铃声
- (void)stopAlerm {
    self.playingAlerm = NO;
}

// 循环播放声音
- (void)loopPlayAlert {
    if (!self.playingAlerm) {
        return;
    }
//    __weak typeof(self) weakSelf = self;
//    AudioServicesPlaySystemSoundWithCompletion(1012, ^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf loopPlayAlert];
//        });
//    });
}

#pragma mark click

- (void)cameraSwitchClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.myInfoContentView removeFromSuperview];
        [[TUICall shareInstance] openCamera:YES view:self.localPreView];
    }else {
        [self setupInfoView];
        [[TUICall shareInstance] closeCamara];
       
    }
}

- (void)setupInfoView {
    [self.myInfoContentView removeFromSuperview];
    [self.localPreView addSubview:self.myInfoContentView];
    self.myInfoContentView.frame = CGRectMake(0, 0, self.localPreView.frame.size.width, self.localPreView.frame.size.height);

    CGFloat width = _avatarWidth > 0 ? _avatarWidth : 64;

    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(width));
        make.center.equalTo(@0);
    }];
    self.avatarImageView.layer.cornerRadius = width/2;

    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(10);
    }];

    for (CallUserModel* model in self.userList) {
        if ([model.userId isEqualToString:[TUICallUtils loginUser]]) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
            self.nicknameLabel.text = model.name;
            break;
        }
    }
}

- (void)setupRemoteInfoView:(TUIVideoRenderView*)view {
    [self.remoteInfoContentView removeFromSuperview];
    [view addSubview:self.remoteInfoContentView];
    [self.remoteInfoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    CGFloat width = _isSmallView ? 64 : 100;
    
    [self.remoteAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(width));
        make.center.equalTo(@0);
    }];
    
    [self.remoteNicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.remoteAvatarImageView.mas_bottom).offset(10);
    }];
    
    for (CallUserModel* model in self.userList) {
        if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
            [self.remoteAvatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:YZChatResource(@"defaultAvatarImage") options:SDWebImageHighPriority];
            self.remoteNicknameLabel.text = model.name;
            break;
        }
    }
}

- (void)hangupClick {
    [[TUICall shareInstance] hangup];
    [self disMiss];
}

- (void)acceptClick {
    [[TUICall shareInstance] accept];
    [self shouldStopAlertAndRing];
    @weakify(self)
    [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
        @strongify(self)
        model.isEnter = YES;
        model.isVideoAvaliable = YES;
        [self enterUser:model];
        self.curState = VideoCallState_Calling;
        self.accept.hidden = YES;
    }];

}

- (void)muteClick {
    BOOL micMute = ![TUICall shareInstance].micMute;
    [[TUICall shareInstance] mute:micMute];
    [self.mute setImage:[TUICall shareInstance].isMicMute ? YZChatResource(@"ic_mute_on") : YZChatResource(@"ic_mute")  forState:UIControlStateNormal];
    if (micMute) {
        [THelper makeToast:@"开启静音" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    } else {
        [THelper makeToast:@"关闭静音" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    }
}

- (void)handsfreeClick {
    BOOL handsFreeOn = ![TUICall shareInstance].handsFreeOn;
    [[TUICall shareInstance] handsFree:handsFreeOn];
    self.handsfree.selected = !handsFreeOn;
    
    if (handsFreeOn) {
        [THelper makeToast:@"使用扬声器" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    } else {
        [THelper makeToast:@"使用听筒" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    }
}

- (void)handleTapGesture:(UIPanGestureRecognizer *)tap {
    if (self.collectionCount != 2) {
        return;
    }
    if ([tap.view isEqual:self.localPreView]) {
        if (self.localPreView.frame.size.width == kSmallVideoWidth) {
            CallUserModel *userFirst;
            for (CallUserModel *model in self.avaliableList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    userFirst = model;
                    break;
                }
            }
            if (userFirst) {
                TUIVideoRenderView *firstRender = [self getRenderView:userFirst.userId];
                [firstRender fillWithData:userFirst layout:CallViewLayoutStyleSmall];
                [firstRender removeFromSuperview];
                [self.view insertSubview:firstRender aboveSubview:self.localPreView];
                self.isSmallView = YES;
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.localPreView.frame = self.view.frame;
                    self.myInfoContentView.frame = CGRectMake(0, 0, self.localPreView.frame.size.width, self.localPreView.frame.size.height);
                    firstRender.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
                    
                    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                         make.size.equalTo(@100);
                         make.centerX.equalTo(@0);
                         make.centerY.equalTo(@-50);
                    }];
                    
                    if(userFirst.isVideoAvaliable == NO) {
                        [self setupRemoteInfoView:firstRender];
                    }
                }];
                self.avatarWidth = 100;
                self.avatarImageView.layer.cornerRadius = self.avatarWidth/2;
                self.remoteAvatarImageView.layer.cornerRadius = 32;
            }
        }
    } else {
        UIView *smallView = tap.view;
        if (smallView.frame.size.width == kSmallVideoWidth) {
            [smallView removeFromSuperview];
            [self.view insertSubview:smallView belowSubview:self.localPreView];
            TUIVideoRenderView* remoteView = (TUIVideoRenderView*)smallView;
            remoteView.layout = CallViewLayoutStyleBig;
            self.isSmallView = NO;
            [UIView animateWithDuration:0.3 animations:^{
                remoteView.frame = self.view.frame;
                self.localPreView.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
                self.myInfoContentView.frame = CGRectMake(0, 0, self.localPreView.frame.size.width, self.localPreView.frame.size.height);
                [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.size.equalTo(@64);
                     make.center.equalTo(@0);
                }];
                self.avatarWidth = 64;
                self.avatarImageView.layer.cornerRadius = self.avatarWidth/2;
                [self.remoteAvatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.equalTo(@100);
                    make.center.equalTo(@0);
                }];
                self.remoteAvatarImageView.layer.cornerRadius = 50;
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    UIView *smallView = pan.view;
    if (smallView) {
        if (pan.view.frame.size.width == kSmallVideoWidth) {
            if (pan.state == UIGestureRecognizerStateBegan) {
                
            } else if (pan.state == UIGestureRecognizerStateChanged) {
                CGPoint translation = [pan translationInView:self.view];
                CGFloat newCenterX = translation.x + (smallView.center.x);
                CGFloat newCenterY = translation.y + (smallView.center.y);
                if (( newCenterX < (smallView.bounds.size.width) / 2) ||
                    ( newCenterX > self.view.bounds.size.width - (smallView.bounds.size.width) / 2))  {
                    return;
                }
                if (( newCenterY < (smallView.bounds.size.height) / 2) ||
                    (newCenterY > self.view.bounds.size.height - (smallView.bounds.size.height) / 2))  {
                    return;
                }
                [UIView animateWithDuration:0.1 animations:^{
                    smallView.center = CGPointMake(newCenterX, newCenterY);
                }];
                [pan setTranslation:CGPointZero inView:self.view];
            } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            }
        }
    }
}

#pragma mark UICollectionViewDelegate
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIVideoCallUserCell *cell = (TUIVideoCallUserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TUIVideoCallUserCell_ReuseId forIndexPath:indexPath];
    if (self.refreshCollectionView) {
        CallUserModel *model = [[CallUserModel alloc]init];
        if (_isInGrp && indexPath.row < self.userList.count) {
            model = self.userList[indexPath.row];
        }else {
            if (indexPath.row < [self.avaliableList count]) {
                model = self.avaliableList[indexPath.row];
            }
        }
        [cell fillWithData:model renderView:[self getRenderView:model.userId] curState:self.curState];        
        if ([model.userId isEqualToString:[TUICallUtils loginUser]]) {
            [self.localPreView removeFromSuperview];
            [cell addSubview:self.localPreView];
            [cell sendSubviewToBack:self.localPreView];
            self.localPreView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectWidth = collectionView.frame.size.width;
//    CGFloat collectHeight = collectionView.frame.size.height;
    if (self.collectionCount <= 4) {
        CGFloat width = collectWidth / 2;
//        CGFloat height = collectHeight / 2;
        CGFloat height = collectWidth / 2;

        if (self.collectionCount % 2 == 1 && indexPath.row == self.collectionCount - 1) {
            if (indexPath.row == 0 && self.collectionCount == 1) {
                return CGSizeMake(width, width);
            } else {
                return CGSizeMake(width, height);
            }
        } else {
            return CGSizeMake(width, height);
        }
    } else {
        CGFloat width = collectWidth / 3;
        CGFloat height = collectWidth / 3;
        return CGSizeMake(width, height);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark data
- (NSMutableArray <CallUserModel *> *)avaliableList {
    NSMutableArray *avaliableList = [NSMutableArray array];
    for (CallUserModel *model in self.userList) {
        if (model.isEnter) {
            [avaliableList addObject:model];
        }
    }
    return avaliableList;
}

- (void)setCurState:(VideoCallState)curState {
    if (_curState != curState) {
        _curState = curState;
        [self autoSetUIByState];
    }
}

- (VideoCallState)curState {
    return _curState;
}

- (NSInteger)collectionCount {
    _collectionCount = (self.avaliableList.count <= 4 ? self.avaliableList.count : 9);
    if (_isInGrp) {
        _collectionCount = (self.userList.count <= 4 ? self.userList.count : 9);
    }else {
        if (self.curState == VideoCallState_OnInvitee || self.curState == VideoCallState_Dailing) {
            _collectionCount = 0;
        }
    }
    return _collectionCount;
}

- (CallUserModel *)getUserById:(NSString *)userID {
    for (CallUserModel *user in self.userList) {
        if ([user.userId isEqualToString:userID]) {
            return user;
        }
    }
    return nil;
}

- (TUIVideoRenderView *)getRenderView:(NSString *)userID {
    for (TUIVideoRenderView *renderView in self.renderViews) {
        if ([renderView.userModel.userId isEqualToString:userID]) {
            return renderView;
        }
    }
    return nil;
}

/*!
 收到电话，可以播放铃声
 */
- (void)shouldRingForIncomingCall {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"voip_call" ofType:@"mp3"];
        [self startPlayRing:ringPath];
        self.needPlayingRingAfterForeground = NO;
    } else {
        self.needPlayingRingAfterForeground = YES;
    }
}

- (void)checkApplicationStateAndAlert {
    if (self.curState == VideoCallState_Dailing) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//            NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"voip_calling_ring" ofType:@"mp3"];
//            [self startPlayRing:ringPath];
            [self startVibrate];
            self.needPlayingAlertAfterForeground = NO;
        } else {
            self.needPlayingAlertAfterForeground = YES;
        }
    }
}

- (void)appDidBecomeActive {
    if (self.needPlayingAlertAfterForeground) {
        [self checkApplicationStateAndAlert];
    } else if (self.needPlayingRingAfterForeground) {
        [self shouldRingForIncomingCall];
    }
}

- (void)triggerVibrate {
    [self.vibrateTimer invalidate];
    self.vibrateTimer = nil;
    
    self.vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(triggerVibrateAction) userInfo:nil repeats:YES];
}

- (void)triggerVibrateAction
{
    NSInteger checker = [TCUtil compareVersion:[UIDevice currentDevice].systemVersion toVersion:@"9.0"];
    if (checker >= 0) {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{});
    }
    else{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)startPlayRing:(NSString *)ringPath {
    if (ringPath) {
        if (self.audioPlayer) {
            [self stopPlayRing];
        }
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if (self.curState == VideoCallState_Dailing) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP error:nil];
        } else {
            //默认情况按静音或者锁屏键会静音
            [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
            [self triggerVibrate];
        }
        
        [audioSession setActive:YES error:nil];

        NSURL *url = [NSURL fileURLWithPath:ringPath];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
}

- (void)stopPlayRing {
    if (self.vibrateTimer) {
        [self.vibrateTimer invalidate];
        self.vibrateTimer = nil;
    }
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        //设置铃声停止后恢复其他app的声音
        [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    }
}

/*!
 停止播放铃声(通话接通或挂断)
 */
- (void)shouldStopAlertAndRing {
    self.needPlayingRingAfterForeground = NO;
    self.needPlayingAlertAfterForeground = NO;
    [self stopPlayRing];
}


- (void)registerForegroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)handleAudioRouteChange:(NSNotification*)notification
{
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *port = route.outputs.firstObject;
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable : //1
            [self reloadSpeakerRoute:NO];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable : //2
            [self reloadSpeakerRoute:YES];
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange : //3
            break;
        case AVAudioSessionRouteChangeReasonOverride : //4
        {
            if ([port.portType isEqualToString:AVAudioSessionPortBuiltInReceiver] || [port.portType isEqualToString: AVAudioSessionPortBuiltInSpeaker]){
                [self reloadSpeakerRoute:YES];
            }
            else{
                [self reloadSpeakerRoute:NO];
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep : //6
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory : //7
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange : //8
            break;
        default:
            break;
    }
}

- (void)reloadSpeakerRoute:(BOOL)enable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.handsfree.enabled = enable;
    });
}

//是否戴耳机了
- (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs])
    {
        NSString *outputer = desc.portType;
        if ([outputer isEqualToString:AVAudioSessionPortHeadphones] || [outputer isEqualToString:AVAudioSessionPortBluetoothLE] || [outputer isEqualToString:AVAudioSessionPortBluetoothHFP] || [outputer isEqualToString:AVAudioSessionPortBluetoothA2DP])
            return YES;
    }
    return NO;
}


@end

