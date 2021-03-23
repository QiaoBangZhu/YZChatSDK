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
#import <QMUIKit/QMUIKit.h>
#import "YZWebViewController.h"
#import <TMRTC/TMRTC.h>
#import "YZBaseManager.h"
#import "NSBundle+YZBundle.h"

@interface YWorkZoneViewController ()<UITableViewDelegate, UITableViewDataSource,YWorkZoneTableViewCellDelegate,TMRTCAuthServiceDelegate,TMRTCAuthServiceDataSource>
@property (nonatomic, strong)UITableView   * tableView;
@property (nonatomic, strong)NSMutableArray* data;
@property (nonatomic,   copy)NSString      * SSOURLString;
@property (nonatomic, strong)UIImageView   * bgView;

@end

@implementation YWorkZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.titleName = @"工作台";
    self.data = [[NSMutableArray alloc]init];
    [self setupView];
    [self makeConstraint];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:KCommonBackgroundColor];
    [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
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
    [QMUITips showLoadingInView:self.view];
    [YChatNetworkEngine requestToolBoxWithUserId:[YChatSettingStore sharedInstance].getUserId completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            [QMUITips hideAllTips];
            if ([result[@"code"]intValue] == 200) {
                @strongify(self);
                [self.data removeAllObjects];
                for (NSDictionary* dict in result[@"data"]) {
                    YWorkZoneModel* model = [YWorkZoneModel yy_modelWithDictionary:dict];
                    [self.data addObject:model];
                }
                [self.tableView reloadData];
            }else {
                [QMUITips showError:result[@"msg"]];
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
        url = [NSString stringWithFormat:@"%@%@",SSOFormatString,app.sdkToken];
        self.SSOURLString = url;
//        self.SSOURLString = @"https://demo4-idp.idaas.tencentcs.com/cidp/login/ai-b17a6f68b4ed47678c62e0e0a3fc3bb0?state=aHR0cHM6Ly9kZW1vNC1pZHAuaWRhYXMudGVuY2VudGNzLmNvbS9jaWRwL3Nzby9haS0xZGIxMzkwOGY5Njc0NTExOWUyYTg5YzVlYjJmNWUwYw==&id_token=eyJraWQiOiI3IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJ5dWFuemhpX3Rlc3QwMSIsImlzcyI6InRlbmNlbnQgbWVldGluZyIsIm5hbWUiOiJ5dWFuemhpX3Rlc3QwMSIsImV4cCI6MTYwNjU1Mjk2NiwiaWF0IjoxNjAxMzg3MTY2fQ.XljVdtibXPxg29VM4kDFejlJoSyx1RXoWsXlyZhj_IplgMAtwMctEqVO84seGQxVMKcYUMi-7YiQRTph1-nzg1JuxVvruLVQnYSm3iIWrmj9XgHbbOWVAP1oA5XZfDOHG2QGev4OgWxwS6l1SZNLJLUunHy4UlwTqQvzDbQyZ7-WubJ5balAre30DkYNAyxI2IE5DXOgSpSFeHF30aQiq-4WGxREF84uP--43TXKfd5H76ZyDdluKzmEXoQBJywnK9KOwLOrTB4u7nyB_MnNMH9a33IESwa1ePIZklsQsDnxZnp8M-7o32Pa--D5krq0dR2UeqrHvgqPlRPFVKD9Tg";
//
        [self configureTMRTC];
        [self configureAuthServce];
        
        if([[[TMRTCAppDelegate sharedRTC] authService] login]) {
            [QMUITips showLoadingInView:self.view];
        } else {
            NSLog(@"not init!");
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
                [QMUITips showError:result[@"msg"]];
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
                [QMUITips showError:result[@"Message"]];
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


#pragma mark - TMRTCAuthServiceDataSource

- (void)ssoAuthCodeForAuth:(void (^)(NSString *ssoCode))block {

    NSURL *SSOURL = [NSURL URLWithString:self.SSOURLString];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:SSOURL
                                                         completionHandler:^(NSData * _Nullable data,
                                                                             NSURLResponse * _Nullable rsp,
                                                                             NSError * _Nullable error) {
       NSHTTPURLResponse *response = (NSHTTPURLResponse *)rsp;
       if ([response statusCode] != 200) {
          NSAssert(0, @"response error %ld", (long)[response statusCode]);
          return;
       }
       NSURLComponents *components = [[NSURLComponents alloc] initWithString:[response.URL absoluteString]];
       for (NSURLQueryItem *queryItem in [components queryItems]) {
          if ([queryItem.name isEqualToString:@"redirect_uri"]) {
              // Get scheme
              NSString *scheme = [queryItem.value stringByRemovingPercentEncoding];
              NSURLComponents *schemeComponents = [[NSURLComponents alloc] initWithString:scheme];
              for (NSURLQueryItem *schemeQueryItem in [schemeComponents queryItems]) {
                  if ([schemeQueryItem.name isEqualToString:@"sso_auth_code"]) {
                      // Get sso audh code
                      NSString *code = schemeQueryItem.value;
                      dispatch_async(dispatch_get_main_queue(), ^{
                          block(code);
                      });
                      return;
                  }
              }
          }
        }
        NSAssert(0, @"sso_auth_code not found");
    }];
    [task resume];
}

- (void)configureTMRTC {
    TMRTCAppDelegateInitAttributes *attributes = [TMRTCAppDelegateInitAttributes new];
    attributes.extensionGroupId = @"com.yuanzhi.chat";
    attributes.resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"TMRTCResource" ofType:@"bundle"];
    attributes.sdkId = kSdkId;
    attributes.sdkToken = kSdkToken;
    [[TMRTCAppDelegate sharedRTC] initWithAttributes:attributes];
}

- (void)configureAuthServce {
    [[TMRTCAppDelegate sharedRTC] authService].delegate = self;
    [[TMRTCAppDelegate sharedRTC] authService].dataSource = self;
}

- (void)auth:(nonnull TMRTCAuthService *)auth didFinishLoginWithError:(nullable NSError *)error {
    if (error) {
        [QMUITips showError:error.localizedDescription];
    }else {
        UIViewController *viewController = [[TMRTCAppDelegate sharedRTC] rootViewController];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)auth:(nonnull TMRTCAuthService *)auth didFinishLogoutWithError:(nullable NSError *)error {
    if (error) {
        [QMUITips showError:error.localizedDescription];
    }
}

- (void)exit {
    [UIApplication sharedApplication].delegate.window.rootViewController = [[YZBaseManager shareInstance] getMainController];
      [YZBaseManager shareInstance].tabController.selectedIndex = 2;
}


@end
