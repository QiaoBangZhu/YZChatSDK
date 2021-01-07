//
//  TUIAudioCallViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/7.
//

#import <AudioToolbox/AudioToolbox.h>
#import "TUIAudioCallViewController.h"
#import "TUIAudioCallUserCell.h"
#import "TUIAudioCalledView.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import <Masonry/Masonry.h>
#import <QMUIKit/QMUIKit.h>
#import "YZBaseManager.h"
#import "TCUtil.h"
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

#define kUserCalledView_Width  160
#define kUserCalledView_Top  160

@interface TUIAudioCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,assign) AudioCallState curState;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *userList;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *members;
//单聊
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *singleCallUserList;
@property(nonatomic,strong) CallUserModel *curSponsor;
@property(nonatomic,strong) TUIAudioCalledView *calledView;
@property(nonatomic,strong) UICollectionView *userCollectionView;
//存放被邀请的参会人(不包含自己)
@property(nonatomic,strong) UICollectionView *invateMembersCollectionView;
@property(nonatomic,assign) NSInteger collectionCount;
@property(nonatomic,strong) UIButton *hangup;
@property(nonatomic,strong) UIButton *accept;
@property(nonatomic,strong) QMUIButton *mute;
@property(nonatomic,strong) QMUIButton *handsfree;
@property(nonatomic,strong) UILabel  *callTimeLabel;
@property(nonatomic,strong) UILabel  *otherMembersLabel;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) UInt32 callingTime;
@property(nonatomic,assign) BOOL playingAlerm; // 播放响铃
@property(nonatomic,assign) BOOL isInGrp;

//播放铃声
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, assign) BOOL needPlayingAlertAfterForeground;
@property(nonatomic, assign) BOOL needPlayingRingAfterForeground;
@property(nonatomic, weak) NSTimer *vibrateTimer;


@end

@implementation TUIAudioCallViewController
{
    AudioCallState _curState;
    UIView *_onInviteePanel;
    UICollectionView *_userCollectionView;
    TUIAudioCalledView *_calledView;
    NSInteger _collectionCount;
    UIButton *_hangup;
    UIButton *_accept;
    QMUIButton *_mute;
    QMUIButton *_handsfree;
}

- (instancetype)initWithSponsor:(CallUserModel *)sponsor userList:(NSMutableArray<CallUserModel *> *)userList isInGroup:(BOOL)isInGrp {
    self = [super init];
    if (self) {
        [self registerForegroundNotification];
        self.curSponsor = sponsor;
        self.isInGrp = isInGrp;
        self.singleCallUserList = [userList mutableCopy];
        if (sponsor) {
            self.curState = AudioCallState_OnInvitee;
        } else {
            self.curState = AudioCallState_Dailing;
        }
        [self resetUserList:^{
            //单聊时候 没有自己
//            if (!self.isInGrp) {
//                [self.userList removeAllObjects];
//            }
            for (CallUserModel *model in userList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    if (self.curState == AudioCallState_Dailing) {
                        [self.userList addObject:model];
                    }
                    if (self.curState == AudioCallState_OnInvitee) {
                        [self.members addObject:model];
                    }
                }
            }
        }];
        self.needPlayingRingAfterForeground = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData:NO];
    
   //呼出后立刻振铃
    if (self.curState == AudioCallState_Dailing) {
        [self performSelector:@selector(checkApplicationStateAndAlert) withObject:nil afterDelay:1];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if (self.curState == AudioCallState_OnInvitee) {
        if (self.needPlayingRingAfterForeground) {
            [self shouldRingForIncomingCall];
        }
    }
//    [self playAlerm];    
}

- (void)disMiss {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    [[YZBaseManager shareInstance] statisticsUsedTime:self.callingTime isVideo:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    
//    [self stopAlerm];
    [self shouldStopAlertAndRing];
    [self removeProximityMonitoringObserver];

}

#pragma mark logic

- (void)resetUserList:(void(^)(void))finished {
    self.userList = [NSMutableArray array];
    self.members = [NSMutableArray array];
    if (self.curSponsor) {
        [self.userList addObject:self.curSponsor];
        finished();
    } else {
        @weakify(self)
        [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
            @strongify(self)
            model.isEnter = YES;
            [self.userList addObject:model];
            finished();
        }];
    }
}

- (void)enterUser:(CallUserModel *)user {
    self.curState = AudioCallState_Calling;
    [self updateUser:user animate:YES];
    if (![user.userId isEqualToString:[TUICallUtils loginUser]]) {    
//        [self stopAlerm];
        [self shouldStopAlertAndRing];
    }
}

- (void)leaveUser:(NSString *)userId {
    for (CallUserModel *model in self.userList) {
        if ([model.userId isEqualToString:userId]) {
            [self.userList removeObject:model];
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
    [self reloadData:animate];
}

- (void)reloadData:(BOOL)animate {
    CGFloat topPadding = 175;
    if (@available(iOS 11.0, *)) {
        topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    @weakify(self)
    
//    if (self.curState == AudioCallState_Dailing) {
//        if (!_isInGrp) {
//            NSMutableArray* tempArr  = [self.userList mutableCopy];
//            for (CallUserModel* model in tempArr) {
//                if ([model.userId isEqualToString:[TUICallUtils loginUser]]) {
//                    [self.userList removeObject:model];
//                    break;
//                }
//            }
//        }
//    }
    
    [UIView performWithoutAnimation:^{
        @strongify(self)
//        self.userCollectionView.mm_top(self.collectionCount == 1 ? 115 : topPadding).mm_flexToBottom(180);
        self.userCollectionView.frame = CGRectMake(50,self.collectionCount == 1 ? 115:175, self.view.frame.size.width - 100, self.view.frame.size.height - (self.collectionCount == 1 ? 115:175)- 180);
        [self.userCollectionView reloadData];

        if (self.curState == AudioCallState_OnInvitee) {
            CGFloat collectonViewX = (self.view.
            frame.size.width - 35*self.members.count)/2;
            CGFloat collectionViewWidth = 35*self.members.count;
            
            self.invateMembersCollectionView.frame = CGRectMake(collectonViewX,self.otherMembersLabel.frame.origin.y + self.otherMembersLabel.frame.size.height + 10,collectionViewWidth >= self.view.frame.size.width ? self.view.frame.size.width :collectionViewWidth,30);
            self.otherMembersLabel.hidden = self.members.count == 0;
            [self.invateMembersCollectionView reloadData];
        }
    }];
}

#pragma mark UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
    
    CGFloat topPadding = 175;
    if (@available(iOS 11.0, *) ){
        topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
//    self.userCollectionView.mm_height(self.view.frame.size.height - 175 - 180).mm_top(topPadding);
    [self autoSetUIByState];
    [self addProximityMonitoringObserver];
}

- (void)autoSetUIByState {
    switch (self.curState) {
        case AudioCallState_Dailing:
        {
            self.hangup.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX).mm_bottom(106);
            self.calledView.hidden = YES;
            self.otherMembersLabel.hidden = YES;
            self.invateMembersCollectionView.hidden = YES;
            self.userCollectionView.hidden = NO;
            
            if (!self.isInGrp) {
                for (CallUserModel*model in self.singleCallUserList) {
                    if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                        [self.calledView fillWithData:model];
                        break;
                    }
                }
                self.userCollectionView.hidden = YES;
                self.calledView.hidden = NO;
            }
            
            if ([self isHeadsetPluggedIn]) {
                [self reloadSpeakerRoute:NO];
            }
          
        }
            break;
        case AudioCallState_OnInvitee:
        {
            self.hangup.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX - 80).mm_bottom(106);
            self.accept.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX + 80).mm_bottom(106);
            self.calledView.hidden = NO;
            self.otherMembersLabel.hidden = NO;
            self.invateMembersCollectionView.hidden = NO;
            self.userCollectionView.hidden = YES;
            [self.calledView fillWithData:self.curSponsor];
        }
            break;
        case AudioCallState_Calling:
        {
            self.hangup.mm_width(72).mm_height(72).mm__centerX(self.view.mm_centerX).mm_bottom(106);
            self.mute.mm_width(55).mm_height(55).mm__centerX(self.view.mm_centerX - 120).mm_bottom(114);
            self.handsfree.mm_width(55).mm_height(55).mm__centerX(self.view.mm_centerX + 120).mm_bottom(114);
            self.callTimeLabel.mm_width(50).mm_height(30).mm__centerX(self.view.mm_centerX).mm_bottom(self.hangup.mm_h + self.hangup.mm_b + 10);
            self.mute.hidden = NO;
            self.handsfree.hidden = NO;
            self.callTimeLabel.hidden = NO;
            self.mute.alpha = 0.0;
            self.handsfree.alpha = 0.0;
            
            if (_isInGrp) {
                self.calledView.hidden = YES;
                self.userCollectionView.hidden = NO;
                self.invateMembersCollectionView.hidden = NO;
                self.otherMembersLabel.hidden = NO;
            }else {
                //单聊
                self.calledView.hidden = NO;
                self.calledView.dailingLabel.hidden = YES;
                self.userCollectionView.hidden = YES;
                self.invateMembersCollectionView.hidden = YES;
                self.otherMembersLabel.hidden = YES;
            }
            
            [self startCallTiming];
            
            if ([self isHeadsetPluggedIn]) {
                [self reloadSpeakerRoute:NO];
            }
        }
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        if (self.curState == AudioCallState_Calling) {
            self.mute.alpha = 1.0;
            self.handsfree.alpha = 1.0;
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

- (UIButton *)hangup {
    if (!_hangup.superview) {
        _hangup = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangup setImage:YZChatResource(@"ic_hangup") forState:UIControlStateNormal];
        [_hangup addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hangup];
    }
    return _hangup;
}

- (UIButton *)accept {
    if (!_accept.superview) {
        _accept = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accept setImage:YZChatResource(@"ic_dialing")  forState:UIControlStateNormal];
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
        [_mute setTitle:@"静音" forState:UIControlStateNormal];
        _mute.titleLabel.font = [UIFont systemFontOfSize:12];
        _mute.hidden = YES;
        [self.view addSubview:_mute];
        _mute.imagePosition = QMUIButtonImagePositionTop;
    }
    return _mute;
}

- (QMUIButton *)handsfree {
    if (!_handsfree.superview) {
        _handsfree = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_handsfree setImage:YZChatResource(@"ic_handsfree_on") forState:UIControlStateNormal];
        [_handsfree setImage:YZChatResource(@"ic_handsfree") forState:UIControlStateSelected];
        [_handsfree addTarget:self action:@selector(handsfreeClick) forControlEvents:UIControlEventTouchUpInside];
        _handsfree.hidden = YES;
        [_handsfree setTitle:@"免提" forState:UIControlStateNormal];
        [_handsfree setTitleColor:[UIColor colorWithRed:249/255.0 green:250/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_handsfree setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _handsfree.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_handsfree];
        _handsfree.imagePosition = QMUIButtonImagePositionTop;
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

- (TUIAudioCalledView *)calledView {
    if (!_calledView.superview) {
        _calledView = [[TUIAudioCalledView alloc] initWithFrame:CGRectMake((self.view.mm_w - kUserCalledView_Width) / 2, kUserCalledView_Top - 80, kUserCalledView_Width, kUserCalledView_Width + 60)];
        _calledView.hidden = YES;
        [self.view addSubview:_calledView];
    }
    return _calledView;
}

- (UICollectionView *)userCollectionView {
    if (!_userCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 40;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(50, 175, self.view.frame.size.width - 100, self.view.frame.size.height-175) collectionViewLayout:layout];
        [_userCollectionView registerClass:[TUIAudioCallUserCell class] forCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId];
        if (@available(iOS 10.0, *)) {
            [_userCollectionView setPrefetchingEnabled:YES];
        } else {
            // Fallback on earlier versions
        }
        _userCollectionView.showsVerticalScrollIndicator = NO;
        _userCollectionView.showsHorizontalScrollIndicator = NO;
        _userCollectionView.contentMode = UIViewContentModeScaleToFill;
        _userCollectionView.dataSource = self;
        _userCollectionView.delegate = self;
        _userCollectionView.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
        [self.view addSubview:_userCollectionView];
    }
    return _userCollectionView;
}

- (UICollectionView *)invateMembersCollectionView {
    if (!_invateMembersCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _invateMembersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.otherMembersLabel.frame.origin.y + self.otherMembersLabel.frame.size.height + 20,self.view.frame.size.width, 83) collectionViewLayout:layout];
        [_invateMembersCollectionView registerClass:[TUIAudioCallUserCell class] forCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId];
        if (@available(iOS 10.0, *)) {
            [_invateMembersCollectionView setPrefetchingEnabled:YES];
        } else {
            // Fallback on earlier versions
        }
        _invateMembersCollectionView.showsVerticalScrollIndicator = NO;
        _invateMembersCollectionView.showsHorizontalScrollIndicator = NO;
        _invateMembersCollectionView.contentMode = UIViewContentModeScaleToFill;
        _invateMembersCollectionView.dataSource = self;
        _invateMembersCollectionView.delegate = self;
        _invateMembersCollectionView.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0];
        [self.view addSubview:_invateMembersCollectionView];
    }
    return _invateMembersCollectionView;
}

- (UILabel *)otherMembersLabel {
    if (!_otherMembersLabel) {
        _otherMembersLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,self.calledView.frame.origin.y + self.calledView.frame.size.height + 30, Screen_Width, 20)];
        _otherMembersLabel.text = @"其他还有";
        _otherMembersLabel.textAlignment = NSTextAlignmentCenter;
        _otherMembersLabel.textColor = [UIColor whiteColor];
        _otherMembersLabel.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_otherMembersLabel];
    }
    return _otherMembersLabel;
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
//    AudioServicesPlaySystemSoundWithCompletion(1008, ^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf loopPlayAlert];
//        });
//    });
}

#pragma mark Event
- (void)hangupClick {
    [[YZBaseManager shareInstance] statisticsUsedTime:self.callingTime isVideo:NO];
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
        [self enterUser:model];
        self.curState = AudioCallState_Calling;
        self.accept.hidden = YES;
    }];
}

- (void)muteClick {
    BOOL micMute = ![TUICall shareInstance].micMute;
    [[TUICall shareInstance] mute:micMute];
    [self.mute setImage:[TUICall shareInstance].isMicMute ? YZChatResource(@"ic_mute_on") : YZChatResource(@"ic_mute")  forState:UIControlStateNormal];
    if ([TUICall shareInstance].isMicMute) {
        [_mute setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }else {
        [_mute setTitleColor:[UIColor colorWithRed:249/255.0 green:250/255.0 blue:249/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    
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

#pragma mark UICollectionViewDelegate

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.curState == AudioCallState_OnInvitee) {
        return  self.members.count;
    }
    return self.collectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIAudioCallUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId forIndexPath:indexPath];
    if (self.curState == AudioCallState_OnInvitee) {
        if (indexPath.row < self.members.count) {
            [cell fillWithData:self.members[indexPath.row] isCurSponsor:YES count:self.userList.count];
        } else {
            [cell fillWithData:[[CallUserModel alloc] init] isCurSponsor:YES count:self.userList.count];
        }
        return  cell;
    }
    
    if (indexPath.row < self.userList.count) {
        [cell fillWithData:self.userList[indexPath.row] isCurSponsor:NO count:self.userList.count];
    } else {
        [cell fillWithData:[[CallUserModel alloc] init] isCurSponsor:NO count:self.userList.count];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.curSponsor != nil) {
        if (_curState == AudioCallState_Calling && _isInGrp) {
            return  CGSizeMake(64, 113);
        }
        return  CGSizeMake(30, 30);
    }
    if (self.collectionCount == 1) {
        return  CGSizeMake(160, 274);
    }else {
        return  CGSizeMake(64, 113);
    }
//    if (self.collectionCount <= 4) {
//        CGFloat border = collectWidth / 2;
//        if (self.collectionCount % 2 == 1 && indexPath.row == self.collectionCount - 1) {
//            return CGSizeMake(collectWidth, border);
//        } else {
//            return CGSizeMake(border, border);
//        }
//    } else {
//        CGFloat border = collectWidth / 3;
//        return CGSizeMake(border, border);
//    }
}


#pragma mark data

- (void)setCurState:(AudioCallState)curState {
    if (_curState != curState) {
        _curState = curState;
        [self autoSetUIByState];
    }
}

- (AudioCallState)curState {
    return _curState;
}

- (NSInteger)collectionCount {
    _collectionCount = (self.userList.count <= 4 ? self.userList.count : 9);
    if (self.curState == AudioCallState_OnInvitee) {
        _collectionCount = 1;
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
    if (self.curState == AudioCallState_Dailing) {
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

- (void)startVibrate {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况按静音或者锁屏键会静音
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [self triggerVibrate];
    [audioSession setActive:YES error:nil];

}

- (void)startPlayRing:(NSString *)ringPath {
    if (ringPath) {
        if (self.audioPlayer) {
            [self stopPlayRing];
        }
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if (self.curState == AudioCallState_Dailing) {
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

- (void)dealloc {
    [self stopPlayRing];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - proximity 监听耳朵是否靠近手机屏幕
- (void)addProximityMonitoringObserver {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(proximityStatueChanged:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
}

- (void)removeProximityMonitoringObserver {
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
}

- (void)proximityStatueChanged:(NSNotificationCenter *)notification {
    if (self.curState == AudioCallState_Dailing)
    {
        if ([UIDevice currentDevice].proximityState)
            [TUICall shareInstance].isHandsFreeOn = NO;
        else
            [TUICall shareInstance].isHandsFreeOn = YES;
    }
}

@end

