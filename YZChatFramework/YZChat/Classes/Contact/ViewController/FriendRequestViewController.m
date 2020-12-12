//
//  FriendRequestViewController.m
//  YChat
//
//  Created by magic on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//
/** 
 *  本文件实现了添加好友时的视图，在您想要添加其他用户为好友时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "FriendRequestViewController.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIProfileCardCell.h"
#import "THeader.h"
#import "TIMUserProfile+DataProvider.h"
#import "Toast/Toast.h"
#import <ReactiveObjC.h>
#import "UIImage+TUIKIT.h"
#import "TUIKit.h"
#import "THelper.h"
#import "AddFriendHeaderCell.h"
#import "ButtonTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>

@interface FriendRequestViewController () <UITableViewDataSource, UITableViewDelegate, AddFriendHeaderCellDelegate>
@property UITableView *tableView;
@property UITextView  *addWordTextView;
@property UILabel *groupNameLabel;
@property BOOL keyboardShown;
@property TUIProfileCardCellData *cardCellData;
@property ButtonCellData * btnData;
@property NSString* words;

@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化视图内的组件
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];

    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    
//    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
//        self.words = [NSString stringWithFormat:@"我是%@", profile.nickname.length?profile.nickname:profile.identifier];
//    } fail:^(int code, NSString *msg) {
//
//    }];

    TUIProfileCardCellData *data = [TUIProfileCardCellData new];
    data.name = self.user.nickName;
    data.identifier =  self.user.userId;
    data.signature = self.user.mobile;
    data.avatarImage = DefaultAvatarImage;
    data.avatarUrl = [NSURL URLWithString:self.user.userIcon];
    self.cardCellData = data;
    
    ButtonCellData *btnData = [[ButtonCellData alloc]init];
    btnData.title = @"添加到通讯录";
    btnData.style = BtnBlueText;
    btnData.cbuttonSelector = @selector(onSend);
    btnData.reuseId = @"ButtonCell";
    btnData.hasLine = NO;
    self.btnData = btnData;

    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          @strongify(self);
          return !self.keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         self.keyboardShown = YES;
         [self adjustContentOffsetDuringKeyboardAppear:YES withNotification:x];
     }];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          @strongify(self);
          return self.keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         self.keyboardShown = NO;
         [self adjustContentOffsetDuringKeyboardAppear:NO withNotification:x];
     }];
}

#pragma mark - Keyboard
/**
 *根据键盘的上浮与下沉，使组件一起浮动，保证视图不被键盘遮挡
 */
- (void)adjustContentOffsetDuringKeyboardAppear:(BOOL)appear withNotification:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);


    CGSize contentSize = self.tableView.contentSize;
    contentSize.height += appear? -keyboardHeight : keyboardHeight;

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.tableView.contentSize = contentSize;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 250;
    }
    return  50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 0;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        AddFriendHeaderCell *cell = [[AddFriendHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddFriendHeaderCell"];
        cell.delegate = self;
        [cell fillWithData:self.cardCellData];
        return cell;
    }
    if (indexPath.section == 1) {
        ButtonTableViewCell *cell = [[ButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
        [cell fillWithData:self.btnData];
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/**
 *发送好友请求，包含请求后的回调
 */
- (void)onSend
{
    [self.view endEditing:YES];
    // display toast with an activity spinner
    [self.view makeToastActivity:CSToastPositionCenter];
    TIMFriendRequest *req = [[TIMFriendRequest alloc] init];
    req.addWording = self.words;
    req.remark = @"";
    req.group = self.groupNameLabel.text;
    req.identifier = self.user.userId;
    req.addSource = @"iOS";
    req.addType = TIM_FRIEND_ADD_TYPE_BOTH;
    
    [[TIMFriendshipManager sharedInstance] addFriend:req succ:^(TIMFriendResult *result) {
        NSString *msg = [NSString stringWithFormat:@"%ld", (long)result.result_code];
        //根据回调类型向用户展示添加结果
        if (result.result_code == TIM_ADD_FRIEND_STATUS_PENDING) {
            msg = @"发送成功,等待审核同意";
        }
        if (result.result_code == TIM_ADD_FRIEND_STATUS_FRIEND_SIDE_FORBID_ADD) {
            msg = @"对方禁止添加";
        }
        if (result.result_code == 0) {
            msg = @"已添加到好友列表";
        }
        if (result.result_code == TIM_FRIEND_PARAM_INVALID) {
            msg = @"好友已存在";
        }
        if (result.result_code == TIM_ADD_FRIEND_STATUS_IN_SELF_BLACK_LIST) {
            msg = @"需要解除黑名单+好友";
        }

        [self.view hideToastActivity];
        [self.view makeToast:msg
                    duration:3.0
                    position:CSToastPositionBottom];

    } fail:^(int code, NSString *msg) {
        [self.view hideToastActivity];
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)addFriendWords:(NSString *)words {
    self.words = words;
    NSLog(@"%@",self.words);
}


@end
