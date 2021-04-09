//
//  YZSearchConversationViewController.m
//  YChat
//
//  Created by magic on 2020/10/26.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZSearchConversationViewController.h"
#import "YZSearchBarView.h"
#import "CommonConstant.h"
#import "UIColor+ColorExtension.h"
#import "YChatSettingStore.h"
#import "YChatNetworkEngine.h"
//#import <ImSDK/ImSDK.h>
#import <ImSDKForiOS/ImSDK.h>

#import "UIColor+ColorExtension.h"
#import "FriendRequestViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <Masonry/Masonry.h>

#import "TCServiceManager.h"
#import "TUIConversationCell.h"
#import "TUIConversationCellData.h"
#import "YChatViewController.h"

@interface YZSearchConversationViewController ()<SearchBarDelegate,UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)YZSearchBarView  * searchBarView;
@property (nonatomic, strong)NSMutableArray * searchList;
@property (nonatomic, strong)UITableView    * tableView;

@end

@implementation YZSearchConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.hidesBackButton = YES;
    
    UIView* titleView = [[UIView alloc]initWithFrame:self.searchBarView.frame];
    [titleView addSubview:self.searchBarView];
    self.navigationItem.titleView = titleView;
    self.view.backgroundColor =  [UIColor colorWithHex:KCommonBackgroundColor];
    
    self.searchList = [[NSMutableArray alloc]init];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource =  self;
        _tableView.tableFooterView =  [UIView new];
        [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:@"cell"];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSepareteLineColor];
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    }
    return _tableView;
}

- (YZSearchBarView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[YZSearchBarView alloc]initWithFrame:CGRectMake(0, 0,KScreenWidth-10,44)];
        _searchBarView.placeholder = @"昵称/备注/群昵称";
        _searchBarView.isShowCancle = YES;
        _searchBarView.isCanEdit =  YES;
        _searchBarView.delegate = self;
        [_searchBarView becomeFirstResponder];
    }
    return _searchBarView;
}

- (void)onCancle {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)textDidChange:(NSString *)searchText {
     [self.searchList removeAllObjects];
     dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
     dispatch_async(globalQueue, ^{
     if (searchText != nil && searchText.length > 0) {
         //遍历需要搜索的所有内容，其中self.dataArray为存放总数据的数组
         for (TUIConversationCellData *model in self.dataArray) {
               NSString *tempStr = model.title;
               if ([tempStr rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0 ) {
                 [self.searchList addObject:model];
               }
           }
      }else{
          self.searchList = [[NSMutableArray alloc]init];
      }
       //回到主线程
      dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
      });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    YChatViewController *chat = [[YChatViewController alloc] init];
    chat.conversationData = cell.convData;
    [self.navigationController pushViewController:chat animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    TUIConversationCellData *data = [self.searchList objectAtIndex:indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];
    cell.titleLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
    cell.subTitleLabel.textColor = [UIColor colorWithHex:KCommonBorderColor];
    cell.timeLabel.textColor = [UIColor colorWithHex:KCommonTimeColor];
    
    cell.changeColorWhenTouched = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 78, 0, 0)];
        if (indexPath.row == (self.searchList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



@end
