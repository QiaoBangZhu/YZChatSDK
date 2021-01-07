//
//  YZAddressBookViewController.m
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZAddressBookViewController.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import <ImSDKForiOS/ImSDK.h>
#import "TCServiceManager.h"
#import "ReactiveObjC/ReactiveObjC.h"

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import <QMUIKit/QMUIKit.h>
#import "YChatNetworkEngine.h"
#import "UserInfo.h"
#import "AddressBookTableViewCell.h"
#import "AddressBookCellData.h"
#import "NSString+TUICommon.h"
#import "UIColor+ColorExtension.h"
#import "ContactsModel.h"
#import <Masonry/Masonry.h>
#import "MMLayout/UIView+MMLayout.h"
#import "TCommonPendencyCellData.h"
#import "FriendRequestViewController.h"
#import "ProfileViewController.h"
#import "THelper.h"
#import "YChatValidInput.h"

@interface YZAddressBookViewController ()<CNContactPickerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray* dataArray;
@property (nonatomic, strong)UITableView   * tableView;
@property (nonatomic, strong)NSMutableArray* groupList;
@property (nonatomic, strong)NSMutableDictionary* dataDict;
@property (nonatomic, strong)NSMutableArray* addressArray;
@property (nonatomic, strong)NSMutableArray* requestArray;
@end

@implementation YZAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.dataArray = [[NSMutableArray alloc]init];
    self.requestArray = [[NSMutableArray alloc]init];
    self.addressArray = [[NSMutableArray alloc]init];
    
    [self showAddressBook];
    @weakify(self)
    [RACObserve(_viewModel, dataList) subscribeNext:^(id  _Nullable x) {
      @strongify(self)
        if (self.dataArray.count > 0) {
            [self makeData];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}


- (void)loadData
{
    [_viewModel loadData];
}

///选择用户列表
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:@"AddressBookTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor colorWithHex:KCommonlittleLightGrayColor]];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return _tableView;
}

- (void)fetchContactsInfoFromImServer {
    [YChatNetworkEngine requestFriendsListByMobiles:self.requestArray completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            for (NSDictionary* dic in result[@"data"]) {
                UserInfo* model = [UserInfo yy_modelWithDictionary:dic];
                for (UserInfo* info in self.addressArray) {
                    if ([info.mobile isEqualToString:model.mobile]) {
                        model.addressBookName = info.addressBookName;
                        break;
                    }
                }
                [self.dataArray addObject:model];
            }
            [self makeData];
            [self.tableView reloadData];
        }
    }];
}

- (void)makeData {
    NSMutableDictionary *dataDict = @{}.mutableCopy;
    NSMutableArray *groupList = @[].mutableCopy;
    NSMutableArray *nonameList = @[].mutableCopy;
    for (UserInfo *user in self.dataArray) {
        
        AddressBookCellData* data = [[AddressBookCellData alloc]init];
        data.title = user.addressBookName;
        data.nickname = user.nickName;
        data.identifier = user.userId;
        data.avatarUrl = [NSURL URLWithString:user.userIcon];
        data.mobile = user.mobile;
        data.type = user.userType;
        data.userIcon = user.userIcon;
        
        for (TCommonPendencyCellData* info in self.viewModel.dataList) {
            if ([info.identifier isEqualToString:data.identifier]) {
                if (info.application.type == V2TIM_FRIEND_APPLICATION_SEND_OUT) {
                    data.readyAgree = YES;
                    break;
                }
            }
        }
        
        NSString *group = [[user.addressBookName firstPinYin] uppercaseString];
        if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
            [nonameList addObject:data];
            continue;
        }
        NSMutableArray *list = [dataDict objectForKey:group];
        if (!list) {
            list = @[].mutableCopy;
            dataDict[group] = list;
            [groupList addObject:group];
        }
        [list addObject:data];
    }

    [groupList sortUsingSelector:@selector(localizedStandardCompare:)];
    if (nonameList.count) {
        [groupList addObject:@"#"];
        dataDict[@"#"] = nonameList;
    }
    for (NSMutableArray *list in [dataDict allValues]) {
        [list sortUsingSelector:@selector(compare:)];
    }
    [QMUITips hideAllTips];
    self.groupList = groupList;
    self.dataDict = dataDict;
}

- (void)showAddressBook {
   [self CheckAddressBookAuthorization:^(bool isAuthorized) {
       if (isAuthorized) {
           NSLog(@"有权限，打开通讯录");
           dispatch_async(dispatch_get_main_queue(), ^{
               [QMUITips showLoadingInView:[UIApplication sharedApplication].keyWindow];
           });
           
           CNContactStore *contactStore = [[CNContactStore alloc] init];
            //拿到所有打算获取的属性对应的key
           NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
           //创建CNContactFetchRequest对象
           CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
           //遍历所有的联系人
           [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
               // 1.获取联系人的姓名
               NSString *lastname = contact.familyName;
               NSString *firstname = contact.givenName;
               NSLog(@"%@ %@", lastname, firstname);
               // 2.获取联系人的电话号码
               NSArray *phoneNums = contact.phoneNumbers;
               NSString *phoneValue = nil;
               for (CNLabeledValue *labeledValue in phoneNums) {
                   //获取电话号码
                   CNPhoneNumber *phoneNumer = labeledValue.value;
                   phoneValue = phoneNumer.stringValue;
               }
               //去掉电话中的特殊字符
               phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"+86" withString:@""];
               phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
               phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
               phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@")" withString:@""];
               phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@" " withString:@""];
               phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@" " withString:@""];
               
               NSString* name = [NSString stringWithFormat:@"%@%@",lastname,firstname];
               UserInfo* model = [[UserInfo alloc]init];
               model.addressBookName = [name length] == 0 ? phoneValue : name;
               model.mobile = phoneValue;
                            
               ContactsModel* contacts = [[ContactsModel alloc]init];
               contacts.mobile = phoneValue;
               
               if ([phoneValue length] > 0 && [YChatValidInput isMobile:phoneValue]) {
                   [self.addressArray addObject:model];
                   [self.requestArray addObject:[contacts yy_modelToJSONString]];
               }
           }];
           
           if ([self.requestArray count] > 0) {
               [self fetchContactsInfoFromImServer];
           }else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [QMUITips showLoadingInView:[UIApplication sharedApplication].keyWindow];
                   [self showTips];
               });
           }
       }else {
           [QMUITips showWithText:@"请到设置>隐私>通讯录打开本应用的权限设置"];
       }
   }];
}

///获取权限
- (void)CheckAddressBookAuthorization:(void (^)(bool isAuthorized))block {
    if (block) {
        CNContactStore * contactStore = [[CNContactStore alloc]init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                if (error)
                {
                    NSLog(@"Error: %@", error);
                }
                else if (!granted)
                {
                    block(NO);
                }
                else
                {
                    block(YES);
                }
            }];
        }
        else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
            block(YES);
        }else {
            [QMUITips showWithText:@"请到设置>隐私>通讯录打开本应用的权限设置"];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groupList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *group = self.groupList[section];
    NSArray *list = self.dataDict[group];
    return list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     AddressBookTableViewCell*cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddressBookTableViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[AddressBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressBookTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section < [self.groupList count]) {
        NSString *group = self.groupList[indexPath.section];
        NSArray *list = self.dataDict[group];
        AddressBookCellData* data = list[indexPath.row];
        data.cselector = @selector(cellClick:);
        data.cbuttonSelector = @selector(btnClick:);
        [cell fillWithData:data];
    }
     return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)btnClick:(AddressBookTableViewCell *)cell
{
    AddressBookCellData* data = (AddressBookCellData*)cell.data;
    
    if (data.type == ADDRESSBOOK_APPLICATION_NOT_FRIEND) {
        @weakify(self)
        [[V2TIMManager sharedInstance] getFriendsInfo:@[data.identifier] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
            V2TIMFriendInfoResult *result = resultList.firstObject;
            if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
                @strongify(self)
                id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.friendProfile = result.friendInfo;
                    vc.isShowConversationAtTop = NO;
                    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } else {
                [[V2TIMManager sharedInstance] getUsersInfo:@[data.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                    @strongify(self)
                    if ([infoList.firstObject.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                        ProfileViewController* profileVc = [[ProfileViewController alloc]init];
                        [self.navigationController pushViewController:profileVc animated:true];
                        return;
                    }
                    id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
                    if ([vc isKindOfClass:[UIViewController class]]) {
                        vc.userFullInfo = infoList.firstObject;
                        if ([vc.userFullInfo.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                            vc.actionType = PCA_NONE;
                        } else {
                            vc.actionType = PCA_ADD_FRIEND;
                        }
                        [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                    }
                } fail:^(int code, NSString *msg) {
                    [THelper makeToastError:code msg:msg];
                }];
            }
        } fail:^(int code, NSString *msg) {
            [THelper makeToastError:code msg:msg];
        }];
    }else if (data.type == ADDRESSBOOK_APPLICATION_INVITE) {
        if ([data.mobile length] > 0) {
            [YChatNetworkEngine requestInviteFriendBy:data.mobile Completion:^(NSDictionary *result, NSError *error) {
                if (!error) {
                    if ([result[@"code"] intValue] == 200) {
                        [QMUITips showSucceed:result[@"data"]];
                        [self.tableView reloadData];
                    }else {
                        [QMUITips showSucceed:result[@"msg"]];
                    }
                }
            }];
        }
    }
    
}

- (void)cellClick:(AddressBookTableViewCell *)cell{
    AddressBookCellData* currData = (AddressBookCellData*)cell.data;
    if (currData.type == ADDRESSBOOK_APPLICATION_INVITE) {
        return;
    }
    TCommonPendencyCellData* data = [[TCommonPendencyCellData alloc]init];
    data.identifier = currData.identifier;
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[data.identifier] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
            @strongify(self)
            id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.friendProfile = result.friendInfo;
                vc.isShowConversationAtTop = NO;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            }
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[data.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                if ([infoList.firstObject.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                    ProfileViewController* profileVc = [[ProfileViewController alloc]init];
                    [self.navigationController pushViewController:profileVc animated:true];
                    return;
                }
                id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.userFullInfo = infoList.firstObject;
                    if ([vc.userFullInfo.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                        vc.actionType = PCA_NONE;
                    } else {
                        vc.actionType = PCA_ADD_FRIEND;
                    }
                    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        headerView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        
        UIView* leftView = [[UIView alloc]init];
        [headerView addSubview:leftView];
        leftView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [headerView addSubview:textLabel];
        textLabel.mm_fill().mm_left(26);
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.groupList[section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.groupList];
    return array;
}

- (void)showTips {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"未找到通讯录联系人" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:ac animated:YES completion:nil];

}


@end
