//
//  YUIGroupConversationListController.m
//  YChat
//
//  Created by magic on 2020/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YUIGroupConversationListController.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "YZChatViewController.h"

#import "YZCardMsgCellData.h"
#import "YZUtil.h"
#import "TUICallUtils.h"
#import "TUISystemMessageCellData.h"
#import "THelper.h"
#import "TUIKit.h"
#import "ReactiveObjC.h"
#import "YZMsgManager.h"

@interface YUIGroupConversationListController ()

@end

@implementation YUIGroupConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
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
        UIView * bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        [headerView addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [bgView addSubview:textLabel];
        
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.centerY.equalTo(@0);
            make.right.equalTo(@-16);
        }];
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.viewModel.groupList[section];

    return headerView;
}

- (void)didSelectConversation:(TCommonContactCell *)cell
{
    TUIConversationCellData *conversationData = [[TUIConversationCellData alloc] init];
    conversationData.groupID = cell.contactData.identifier;
    if(_isFromOtherApp) {
        [self sendCardMsgFromOtherAppWithData:conversationData];
        return;
    }
    YZChatViewController *chat = [[YZChatViewController alloc] init];
    chat.conversationData = conversationData;
    
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)sendCardMsgFromOtherAppWithData:(TUIConversationCellData*)cdata {
    @weakify(self)
   [[YZMsgManager shareInstance]sendMessageWithMsgType:YZSendMsgTypeGrp message:self.customMsg userId:nil grpId:cdata.groupID loginSuccess:^{
      @strongify(self)
      dispatch_async(dispatch_get_main_queue(), ^{
          [self.navigationController popViewControllerAnimated:YES];
      });
   } loginFailed:^(int errCode, NSString *errMsg) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [THelper makeToastError:errCode msg:errMsg];
       });
   }];
}
@end
