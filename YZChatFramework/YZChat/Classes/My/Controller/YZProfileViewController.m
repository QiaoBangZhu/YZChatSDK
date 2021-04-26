//
//  ProfileViewController.m
//  YChat
//
//  Created by magic on 2020/9/21.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZProfileViewController.h"
#import "THeader.h"
#import "TUIButtonCell.h"
#import "TCommonTextCell.h"
#import "TCommonAvatarCell.h"
#import "ReactiveObjC/ReactiveObjC.h"

#import "UIColor+TUIDarkMode.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>

#import "YChatSettingStore.h"
#import "YUserInfo.h"
#import "YZTextEditViewController.h"
#import "YChatNetworkEngine.h"

#import "CIGAMKit.h"
#import "WeChatActionSheet.h"
#import "YzFileManager.h"
#import "UIImage+YChatExtension.h"
#import "CommonConstant.h"
#import "YChatUploadManager.h"
#import "UIColor+ColorExtension.h"
#import "YZModifyMobileViewController.h"
#import "YZChooseCityViewController.h"
#import "TUIAvatarViewController.h"
#import <Masonry/Masonry.h>

@interface YZProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *data;
@property (nonatomic, strong)YUserInfo* profile;
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation YZProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configureNav];
    [self.view addSubview:self.tableView];
    //如果不加这一行代码，依然可以实现点击反馈，但反馈会有轻微延迟，体验不好。
    self.tableView.delaysContentTouches = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.top.equalTo(@0);
        make.bottom.equalTo(@24);
    }];
    
    [self setupViews];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSeparatorLineColor];
    
        [_tableView registerClass:[TCommonTextCell class] forCellReuseIdentifier:@"textCell"];
        [_tableView registerClass:[TCommonAvatarCell class] forCellReuseIdentifier:@"avatarCell"];
        _tableView.showsVerticalScrollIndicator = false;
        _tableView.alwaysBounceHorizontal = NO;
        _tableView.contentInset = UIEdgeInsetsMake(24, 0, 0, 0);
        
//        _tableView.layer.shadowColor = [[UIColor colorWithHex:0xAEAEC0] CGColor];
//        _tableView.layer.shadowOffset = CGSizeMake(3,3);
//        _tableView.layer.shadowOpacity = 1;
//        _tableView.layer.shadowRadius = 5;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupData];
}

- (void)setupViews
{
    self.title = @"个人信息";
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelfInfoUpdated:) name:TUIKitNotification_onSelfInfoUpdated object:nil];
    
//    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
//    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
//        self.profile = infoList.firstObject;
//        [self setupData];
//    } fail:nil];
}

- (void)setupData
{
    _data = [NSMutableArray array];
    YUserInfo* user = [[YChatSettingStore sharedInstance]getUserInfo];
    self.profile = user;
    TCommonAvatarCellData *avatarData = [TCommonAvatarCellData new];
    avatarData.key = @"头像";
    avatarData.showAccessory = YES;
    avatarData.avatarUrl = [NSURL URLWithString:self.profile.userIcon];
    avatarData.cselector = @selector(didSelectAvatar);
    avatarData.cbuttonSelector = @selector(showAvatarPreview:);


    TCommonTextCellData *nicknameData = [TCommonTextCellData new];
    nicknameData.key = @"昵称";
    nicknameData.value = self.profile.nickName;
    nicknameData.showAccessory = YES;
    nicknameData.cselector = @selector(didSelectChangeNickname);
    
    TCommonTextCellData *genderData = [TCommonTextCellData new];
    genderData.key = @"性别";
    genderData.value = @"保密";
    if (self.profile.gender == 1) {
        genderData.value = @"男";
    }
    if (self.profile.gender == 2) {
        genderData.value = @"女";
    }
    genderData.showAccessory = YES;
    genderData.cselector = @selector(didSelectGender);
    
    TCommonTextCellData *positionData = [TCommonTextCellData new];
    positionData.key = @"地区";
    positionData.value = [self.profile.position length] == 0 ? @"未选择": self.profile.position;
    positionData.showAccessory = YES;
    positionData.cselector = @selector(didSelectPosition);
    
    TCommonTextCellData *signtureData = [TCommonTextCellData new];
    signtureData.key = @"个性签名";
    signtureData.value = self.profile.userSignature;
    signtureData.showAccessory = YES;
    signtureData.showBottomCorner = YES;
    signtureData.cselector = @selector(didSelectSignture);

    [_data addObject:@[avatarData,nicknameData, genderData, positionData,signtureData]];

//    TCommonTextCellData *departmant = [TCommonTextCellData new];
//    departmant.key = @"部门";
//    departmant.value = [user.departName length] == 0 ? @"待完善" : user.departName;
//    phoneData.cselector = @selector(didSelectDepartMant);
//    departmant.showAccessory = YES;
//
//    TCommonTextCellData *position = [TCommonTextCellData new];
//    position.key = @"职位";
//    position.value = [user.position length] == 0 ? @"待完善" : user.position;
//    position.cselector = @selector(didSelectChangePosition);
//    position.showAccessory = YES;
//
//    TCommonTextCellData *jobNum = [TCommonTextCellData new];
//    jobNum.key = @"工号";
//    jobNum.value = [user.departMentId length] == 0 ? @"待完善" : user.departMentId;
//    jobNum.cselector = @selector(didSelectJobNum);
//    jobNum.showAccessory = YES;

    TCommonTextCellData *phoneData = [TCommonTextCellData new];
    phoneData.key = @"手机号";
    phoneData.value = self.profile.mobile;
    phoneData.showAccessory = YES;
    phoneData.showTopCorner = YES;
    phoneData.cselector = @selector(didSelectChangeMobile);
    
    TCommonTextCellData *email = [TCommonTextCellData new];
    email.key = @"邮箱";
    email.value = [user.email length] == 0 ? @"待完善" : user.email;
    email.showAccessory = YES;
    email.showBottomCorner = YES;
    email.cselector = @selector(didSelectChangeEmail);

    //@[departmant,position,jobNum,email]
    [_data addObject:@[phoneData,email]];

    [self.tableView reloadData];
}

- (void)showAvatarPreview:(TCommonAvatarCell *)cell {
    
    TCommonAvatarCellData* data = (TCommonAvatarCellData*)cell.data;
    
    TUIProfileCardCellData* avatarData = [[TUIProfileCardCellData alloc]init];
    avatarData.avatarUrl = data.avatarUrl;
    avatarData.avatarImage = data.avatarImage;
    
    TUIAvatarViewController *image = [[TUIAvatarViewController alloc] init];
    image.avatarData = avatarData;
    [self.navigationController pushViewController:image animated:YES];
}

- (void)didSelectAvatar
{
     WeChatActionSheet *sheet = [WeChatActionSheet showActionSheet:nil buttonTitles:@[@"拍照",@"从手机相册选择"]];
     [sheet setFunction:^(WeChatActionSheet *actionSheet,NSInteger index){
        if (index == WECHATCANCELINDEX) {}else{
            if (index == 0) {
                [self showCamera];
            }
            if (index == 1) {
                [self showPhotoAlbum];
            }
        }
    }];
}

- (void)didSelectChangeNickname
{
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText:self.profile.nickName editType:EditTypeNickname];
    vc.title = @"修改昵称";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.nickName = x;
        [self requestEditUserInfo];
    }];
}

-(void)didSelectGender {
    WeChatActionSheet *sheet = [WeChatActionSheet showActionSheet:nil buttonTitles:@[@"保密",@"男",@"女"]];
    [sheet setFunction:^(WeChatActionSheet *actionSheet,NSInteger index){
       if (index == WECHATCANCELINDEX) {}else{
           if (index == 0) {
               self.profile.gender = 0;
           }
           if (index == 1) {
               self.profile.gender = 1;
           }
           if (index == 2) {
               self.profile.gender = 2;
           }
           [self requestEditUserInfo];
       }
   }];
}

- (void)didSelectPosition {
    YZChooseCityViewController* vc = [[YZChooseCityViewController alloc]init];
    vc.title = @"选择地区";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    vc.finishBlock = ^(NSString * city) {
        @strongify(self)
        self.profile.position = city;
        [self requestEditUserInfo];
    };
}

- (void)didSelectSignture {
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText:self.profile.userSignature editType:EditTypeSignture];
    vc.title = @"修改个性签名";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.userSignature = x;
        [self requestEditUserInfo];
    }];
}

- (void)didSelectChangeMobile {
    YZModifyMobileViewController* vc = [[YZModifyMobileViewController alloc]init];
    vc.title = @"修改手机号";
    [self.navigationController pushViewController:vc animated:true];
}

- (void)didSelectChangeEmail {
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText:self.profile.email editType:EditTypeEmail];
    vc.title = @"修改邮箱";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.email = x;
        [self requestEditUserInfo];
    }];
}

- (void)didSelectChangePosition {
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText:self.profile.position editType:EditTypePosition];
    vc.title = @"修改职位";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.position = x;
        [self requestEditUserInfo];
    }];
}

- (void)didSelectDepartMant {
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText:self.profile.departName editType:EditTypeDepartment];
    vc.title = @"修改部门";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.departName = x;
        [self requestEditUserInfo];
    }];
}

- (void)didSelectJobNum {
    YZTextEditViewController *vc = [[YZTextEditViewController alloc] initWithText:self.profile.departMentId editType:EditTypeJobNum];
    vc.title = @"修改工号";
    [self.navigationController pushViewController:vc animated:YES];
    @weakify(self)
    [[RACObserve(vc, textValue) skip:1] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.profile.departMentId = x;
        [self requestEditUserInfo];
    }];
}


#pragma mark -- 打开相机
- (void)showCamera {
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init] ;
    cameraController.allowsEditing = YES;
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.delegate = self;
    cameraController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:cameraController animated:YES completion:nil];
}

#pragma mark -- 打开相册
- (void)showPhotoAlbum {
    UIImagePickerController *albumController = [[UIImagePickerController alloc] init];
    albumController.allowsEditing = YES;
    albumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    albumController.delegate = self;
    
    [self presentViewController:albumController animated:YES completion:nil];
}

#pragma mark -- imagepicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (info != nil) {
        [self performSelector:@selector(processImagePicker:) withObject:info afterDelay:0.1f];
    }
}

- (void)processImagePicker:(NSDictionary *)info {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(processImagePicker:) object:nil];
    UIImage *editImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    UIImage* scaleImage = [editImage resizedImageWithMaximumSize:CGSizeMake(375, 375)];
    NSError* error = nil;
    [YzFileManager writeFileAtPath:kHeadImageContentFile content:UIImageJPEGRepresentation(scaleImage, 1) error:&error];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                TCommonAvatarCellData* avatarData = self.data[0][0];
                avatarData.avatarImage = scaleImage;
                avatarData.key = @"头像";
                avatarData.showAccessory = YES;
                avatarData.avatarUrl = [NSURL URLWithString:self.profile.userIcon];
                
                NSMutableArray* tempArray = self.data.mutableCopy;
                NSMutableArray* tempSectionArray = [tempArray[0] mutableCopy];
                [tempSectionArray replaceObjectAtIndex:0 withObject:avatarData];
                [tempArray replaceObjectAtIndex:0 withObject:tempSectionArray];
                [self.data removeAllObjects];
                [self.data addObjectsFromArray:tempArray];
                
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError* error = nil;
        NSData* imageData = [YzFileManager readFileAtPathAsData:kHeadImageContentFile error:&error];
        [YChatUploadManager post:commonUploadFile params: nil imageData:imageData imageName:@"file" onComplete:^(NSDictionary * _Nonnull json, BOOL isSuccess) {
            if (isSuccess) {
                if ([json[@"code"] intValue] == 200) {
                    NSString* headImageUrl = json[@"data"][@"userIcon"];
                    self.profile.userIcon = headImageUrl;
                    [self requestEditUserInfo];
                }else {
                    [CIGAMTips showError:json[@"msg"]];
                }
              
            }
        }];
    });
}

- (void)requestEditUserInfo {
    @weakify(self)
    [YChatNetworkEngine requestUpdateUserInfoWithUserId:self.profile.userId
                                 avatar:[self.profile.userIcon length] == 0 ? @"" : self.profile.userIcon
                               nickname:[self.profile.nickName length] == 0 ? @"" : self.profile.nickName
                                 cardNum:[self.profile.card length] == 0 ? @"" : self.profile.card
                                position:[self.profile.position length] == 0 ? @"" : self.profile.position
                                   emali:[self.profile.email length] == 0 ? @"" : self.profile.email
                                password:[self.profile.password length] == 0 ? @"" : self.profile.password
                               signature:[self.profile.userSignature length] == 0 ? @"" :self.profile.userSignature
                                    city:[self.profile.city length] == 0 ? @"" : self.profile.city
                                  gender:self.profile.gender
                              completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                @strongify(self)
                [[YChatSettingStore sharedInstance]saveUserInfo:self.profile];
                [self setupData];
                [CIGAMTips showWithText:@"修改成功"];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!section) {
        return 0;
    }
    return 24;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = _data[indexPath.section];
    TCommonCellData *data = array[indexPath.row];

    return [data heightOfWidth:Screen_Width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = _data[indexPath.section];
    NSObject *data = array[indexPath.row];
    if([data isKindOfClass:[TCommonTextCellData class]]) {
        TCommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 24, 0, 24)];
         }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 24, 0, 24)];
        }
        cell.valueLabel.textColor = [UIColor colorWithHex:kCommonBlueTextColor];
        cell.keyLabel.font = [UIFont systemFontOfSize:14];
        cell.valueLabel.font = [UIFont systemFontOfSize:14];
        [cell fillWithData:(TCommonTextCellData *)data];
        
        return cell;
    }  else if([data isKindOfClass:[TCommonAvatarCellData class]]){
        TCommonAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell" forIndexPath:indexPath];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 24, 0, 24)];
         }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 24, 0, 24)];
        }
        cell.keyLabel.font = [UIFont systemFontOfSize:14];
        cell.keyLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [cell fillWithData:(TCommonAvatarCellData *)data];
        
        return cell;
    }
    return nil;
}



@end
