//
//  YWorkZoneViewController.m
//  YChat
//
//  Created by magic on 2020/9/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YWorkZoneViewController.h"
#import "YChatNetworkEngine.h"
#import "YChatSettingStore.h"
#import "YWorkZoneTableViewCell.h"
#import "YWorkZoneModel.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "YWorkZoneModel.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "CIGAMKit.h"
#import "YZWebViewController.h"
#import "YZBaseManager.h"
#import "NSBundle+YZBundle.h"

@interface YWorkZoneViewController ()<UITableViewDelegate, UITableViewDataSource,YWorkZoneTableViewCellDelegate>
@property (nonatomic, strong)UITableView   * tableView;
@property (nonatomic, strong)NSMutableArray* data;
@property (nonatomic,   copy)NSString      * SSOURLString;
@property (nonatomic, strong)UIImageView   * bgView;

@end

@implementation YWorkZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"工作台";
    self.data = [[NSMutableArray alloc]init];
    [self setupView];
    [self makeConstraint];
    
}

- (UIColor *)navigationBarBarTintColor {
    return [UIColor colorWithHex: KCommonBackgroundColor];
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage cigam_imageWithColor: [UIColor colorWithHex: KCommonBackgroundColor] size:CGSizeMake(4, PixelOne) cornerRadius:0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(void)setupView {

    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 157;
    _tableView.showsVerticalScrollIndicator = false;
    _tableView.showsHorizontalScrollIndicator = false;
    [_tableView registerClass:[YWorkZoneTableViewCell class] forCellReuseIdentifier:@"WorkZoneTableViewCell"];
    _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    self.view.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)makeConstraint {
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@(24));
        make.bottom.equalTo(@-16);
        make.right.equalTo(@-9);
    }];

}

- (void)requestData {
    [self.data removeAllObjects];
    @weakify(self);
    [CIGAMTips showLoadingInView:self.view];
    [YChatNetworkEngine requestToolBoxWithUserId:[YChatSettingStore sharedInstance].getUserId completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            [CIGAMTips hideAllTips];
            if ([result[@"code"]intValue] == 200) {
                @strongify(self);
                [self.data removeAllObjects];
                for (NSDictionary* dict in result[@"data"]) {
                    YWorkZoneModel* model = [YWorkZoneModel yy_modelWithDictionary:dict];
                    [self.data addObject:model];
                }
                [self.tableView reloadData];
            }else {
                [CIGAMTips showError:result[@"msg"]];
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.data count] == 0) {
        return 174+14;
    }
    YWorkZoneModel* model = self.data[indexPath.section];
    if ([model.toolDataList count] > 0) {
        NSInteger row = 1;
        if ([model.toolDataList count]%4 == 0) {
            row = model.toolDataList.count/4;
        }else {
            row = model.toolDataList.count/4 + 1;
        }
        return (row*61 + 56 + (row-1)*24 + 24 + 14);
    }
    return 174+14;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* view = [[UIView alloc]init];
    return  view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YWorkZoneTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WorkZoneTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[YWorkZoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WorkZoneTableViewCell"];
    }
    cell.delegate = self;
    if ([[self data] count] > 0) {
        YWorkZoneModel* model = self.data[indexPath.section];
        [cell cellData:model];
    }
    return cell;
}

- (void)didSelectedItem:(YAppInfoModel *)app {
    NSString* url = app.toolUrl;
    //腾讯会议
    if ([app.toolCode isEqualToString:@"code001"]) {
        Class cls = NSClassFromString(@"TempWeMeetController");
        if (cls) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([cls respondsToSelector: @selector(sharedInstance)]) {
                id sharedInstance = [cls performSelector: @selector(sharedInstance)];

                if ([sharedInstance respondsToSelector: @selector(startWithToken:viewController:)]) {
                    [sharedInstance performSelector: @selector(startWithToken:viewController:)
                                         withObject: app.sdkToken
                                         withObject: self];
                }
            }
#pragma clang diagnostic pop
        }
        return;
    }else if([app.toolCode isEqualToString:@"code002"]){
        //网盘
        [self fetchToolToken:app];
        return;
    }else if([app.toolCode isEqualToString:@"code003"]) {
        //打车
        [self fetchToolToken:app];
        return;
    }
    YZWebViewController* webView = [[YZWebViewController alloc]init];
    webView.url = [NSURL URLWithString:url];
    webView.title = app.toolName;
    [self.navigationController pushViewController:webView animated:true];
}

- (void)fetchToolToken:(YAppInfoModel *)app {
    [YChatNetworkEngine requestToolTokenWithUserId:[[YChatSettingStore sharedInstance]getUserId] toolCode:app.toolCode toolName:app.toolName completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"] intValue] == 200) {
                NSString* token = result[@"data"];
                NSString* url = @"";
                if ([app.toolCode isEqualToString:@"code003"]) {
                    url =  [NSString stringWithFormat:@"%@%@",app.toolUrl,token];
                    [self fetchToolWebViewUrl:url appInfo:app];
                }else {
                    url =  [NSString stringWithFormat:@"%@?token=%@",app.toolUrl, token];
                    [self showWebView:url title:app.toolName needUA: NO];
                }
            }else {
                [CIGAMTips showError:result[@"msg"]];
            }
        }
    }];
}

-(void)fetchToolWebViewUrl:(NSString *)url appInfo:(YAppInfoModel *)app {
    [YChatNetworkEngine requestCarWebUrlWithBaseUrl:url url:@"" completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"Code"] intValue] == 200) {
                NSString* url = result[@"Result"][@"url"];
                if ([url length] > 0) {
                    [self showWebView:url title:app.toolName needUA:[app.toolCode isEqualToString:@"code003"] ? true : false];
                }
            }else {
                [CIGAMTips showError:result[@"Message"]];
            }
        }
    }];
}

- (void)showWebView:(NSString*)urlStr title:(NSString*)title needUA:(BOOL)isNeedUA {
    YZWebViewController* webView = [[YZWebViewController alloc]init];
    webView.url = [NSURL URLWithString:urlStr];
    webView.title = title;
    webView.needUA = isNeedUA;
    [self.navigationController pushViewController:webView animated:true];
}

@end
