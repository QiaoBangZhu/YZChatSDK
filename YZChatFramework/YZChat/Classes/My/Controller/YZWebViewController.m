//
//  WebViewController.m
//  YChat
//
//  Created by magic on 2020/10/8.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZWebViewController.h"
#import "CommonConstant.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import <QMUIKit/QMUIKit.h>
#import "UIColor+ColorExtension.h"
#import "CommonConstant.h"
#import "YChatNetworkEngine.h"
#import "YChatSettingStore.h"
#import "YZUtil.h"
#import "THelper.h"
#import "NSBundle+YZBundle.h"

#define FETCH_USERINFO @"loadJSSdk"
#define ARGEE_FETCHUSERINFO @"getUserProfile"

@interface YZWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)UIButton  *backBtn;
@property (nonatomic, strong)UIButton  *closeBtn;
@property (nonatomic,   copy)NSString* redirect_url;
@property (nonatomic, assign)BOOL load;

@end

@implementation YZWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payBack) name:@"YzWorkzonePayReturn" object:nil];
}

- (void)payBack {
    if (self.redirect_url.length) {
       NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.redirect_url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
       [self.webView loadRequest:request];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_hiddenCloseBtn) {
        [[[UIApplication sharedApplication]keyWindow]addSubview:self.closeBtn];
    }
    [[[UIApplication sharedApplication]keyWindow]addSubview:self.backBtn];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [_backBtn removeFromSuperview];
//    [_closeBtn removeFromSuperview];
//}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hiddenCloseBtn) {
        [_closeBtn removeFromSuperview];
    }
    [_backBtn removeFromSuperview];
    
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:FETCH_USERINFO];
}

- (void)setupView {
    [self.view addSubview:self.webView];
    if (_needUA) {
        [self setWebViewUA];
    }
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    [self.webView loadRequest:[NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30]];
    [QMUITips showLoading:@"加载中" inView:self.view];
}

- (WKWebView *)webView {
    if (!_webView) {
        // js配置
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:self name:FETCH_USERINFO];
        // WKWebView的配置
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userContentController;
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        _webView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        
    }
    return _webView;
}

- (UIButton *)backBtn {
    if(!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, IS_IPHONEX ? 50 : 26, 70, 30);
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)closeBtn {
    if(!_closeBtn){
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(KScreenWidth-75,IS_IPHONEX ? 50 : 26, 70, 30);
        [_closeBtn setImage:YZChatResource(@"close_icon") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

//加载请求必须同步在设置UA的后面
- (void)setWebViewUA {
    if (@available(iOS 12.0, *)){
        //由于iOS12的UA改为异步，所以不管在js还是客户端第一次加载都获取不到，所以此时需要先设置好再去
        NSString *userAgent = [self.webView valueForKey:@"yapplicationNameForUserAgent"];
        NSString *newUserAgent = [NSString stringWithFormat:@"%@%@",userAgent,@"hsh_ios"];
        [self.webView setValue:newUserAgent forKey:@"yapplicationNameForUserAgent"];
    }
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *userAgent = result;
        if ([userAgent rangeOfString:@"hsh_ios"].location != NSNotFound) {
            return ;
        }
        NSString *newUserAgent = [userAgent stringByAppendingString:@"hsh_ios"];

        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent,@"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
         //不添加以下代码则只是在本地更改UA，网页并未同步更改
        if (@available(iOS 9.0, *)) {
            [self.webView setCustomUserAgent:newUserAgent];
        } else {
            [self.webView setValue:newUserAgent forKey:@"yapplicationNameForUserAgent"];
        }
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [QMUITips hideAllTips];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"did fail with error = %@",error.localizedDescription);
}


- (void)backAction {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)closeAction {
    [self.navigationController popViewControllerAnimated:true];
}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    NSString * urlStr = navigationResponse.response.URL.absoluteString;
//    NSLog(@"--> %@",urlStr);
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL* url = navigationAction.request.URL;
    NSString* str = [self URLDecodedString:url.absoluteString];
    NSString* redirectUrl = [NSString stringWithFormat:@"redirect_url=%@://",scheme];
    if ([url.scheme isEqualToString:@"weixin"] || [url.scheme isEqualToString:@"alipay"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }else if ([str hasPrefix:wxPreUrl] && ![str containsString:redirectUrl]) {
        //发起微信支付后先到这里 我们要做的是设置Referer这个参数,解决回调到safari 浏览器，而不是APP 问题。。（借助URL Scheme 唤起APP 相关知识）
         NSURLRequest *request = navigationAction.request;
         NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc] init];
         newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
         [newRequest setValue:[NSString stringWithFormat:@"%@://",scheme] forHTTPHeaderField: @"Referer"];
         //这里记住redirect_url的值，回调APP的时候用通知重新加载redirect_url，要不然会白屏（什么也不加载）
          if (!self.redirect_url.length) {
              self.redirect_url = [self getParameter:@"redirect_url" urlStr:str];
           }
         NSString* requestUrl = [self deleteParameter:@"redirect_url" WithOriginUrl:str];
         //这个地址加了redirect_url这个回调的网址，会回调浏览器，修改redirect_url的值，这里redirect_url要传的值, 就是上面Referer的值，这样就会回调APP了
         NSString *urlStr = [NSString stringWithFormat:@"%@&redirect_url=%@://",requestUrl, scheme];
         newRequest.URL = [NSURL URLWithString:urlStr];
         [webView loadRequest:newRequest];
         self.load = YES;
         decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }

}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

//-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
//    //假如是重新打开窗口的话
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView loadRequest:navigationAction.request];
//    }
//
//    return nil;
//}

//获取URL中的某个参数：
- (NSString *)getParameter:(NSString *)parameter urlStr:(NSString *)url {
    NSError *error;
    if (!url) {
        return @"";
    }
    NSString *regTags = [[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",parameter];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:url options:0 range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [url substringWithRange:[match rangeAtIndex:2]]; //分组2所对应的串
        return tagValue;
    }
    return @"";
}

//删除URL中的某个参数：
- (NSString *)deleteParameter:(NSString *)parameter WithOriginUrl:(NSString *)originUrl {
    NSString *finalStr = [NSString string];
    NSMutableString * mutStr = [NSMutableString stringWithString:originUrl];
    NSArray *strArray = [mutStr componentsSeparatedByString:parameter];
    NSMutableString *firstStr = [strArray objectAtIndex:0];
    NSMutableString *lastStr = [strArray lastObject];
    NSRange characterRange = [lastStr rangeOfString:@"&"];
    if (characterRange.location != NSNotFound) {
        NSArray *lastArray = [lastStr componentsSeparatedByString:@"&"];
        NSMutableArray *mutArray = [NSMutableArray arrayWithArray:lastArray];
        [mutArray removeObjectAtIndex:0];
        NSString *modifiedStr = [mutArray componentsJoinedByString:@"&"];
        finalStr = [[strArray objectAtIndex:0]stringByAppendingString:modifiedStr];
    }
    else {
        //以'?'、'&'结尾
        finalStr = [firstStr substringToIndex:[firstStr length] - 1];
    }
    return finalStr;
}


-(NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:FETCH_USERINFO]) {
        NSDictionary* dict = [YZUtil jsonSring2Dictionary:message.body];
        [self fetchUserInfoWithAppKey:dict[@"appKey"]];
    }
   
}

- (void)fetchUserInfoWithAppKey:(NSString*)appKey {
    [YChatNetworkEngine requestToolKey:self.url.host toolKey:appKey completion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result[@"code"]intValue] == 200) {
                NSDictionary* params = @{ @"code":@0,
                                          @"nickName":[YChatSettingStore sharedInstance].getNickName,
                                          @"appName":result[@"data"][@"toolName"],
                                          @"appIcon":result[@"data"][@"iconUrl"],
                };
                NSString* json = [params yy_modelToJSONString];
                NSString* decodeJson = [YZUtil string2JSONString:json];
                [self jsCallOC:decodeJson];
            }else {
                NSDictionary* errorDic = @{@"code": @-1,@"msg": result[@"msg"]};
                NSString* json =[errorDic yy_modelToJSONString];
                NSString* decodeJson = [YZUtil string2JSONString:json];
                [self jsCallOC:decodeJson];
            }
        }
    }];
}

#pragma mark js调OC
- (void)jsCallOC:(NSString*)json {
    // oc调用js代码
    NSString *jsStr = [NSString stringWithFormat:@"permissionWindowYzIM('%@')",json];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"错误:%@", error.localizedDescription);
        }
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil
     ];
}

#pragma mark - WKUIDelegate delegate method
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText
    initiatedByFrame:(WKFrameInfo *)frame
    completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    if (prompt) {
        if ([prompt isEqualToString: ARGEE_FETCHUSERINFO]) {
            
            NSDictionary* params = @{@"code":@0,
                                     @"nickName":[[YChatSettingStore sharedInstance].getNickName length] ? [YChatSettingStore sharedInstance].getNickName : @"",
                                     @"userId":[[YChatSettingStore sharedInstance].getUserId length] ? [YChatSettingStore sharedInstance].getUserId : @"" ,
                                     @"mobile":[[YChatSettingStore sharedInstance].getMobile length] ? [YChatSettingStore sharedInstance].getMobile : @""
           };
           NSString* json = [params yy_modelToJSONString];
           NSString* decodeJson = [YZUtil string2JSONString:json];
           completionHandler(decodeJson);
        }
    }
}

//data =     {
//    chargeMobile = "<null>";
//    chargeName = "<null>";
//    createId = "<null>";
//    createTime = "<null>";
//    deleteStatus = 0;
//    iconUrl = "https://yzkj-im.oss-cn-beijing.aliyuncs.com/tool/jipiao.png";
//    id = 0;
//    lastModifyId = "<null>";
//    lastModifyTime = "<null>";
//    orderNum = 0;
//    sdkToken = "<null>";
//    status = 0;
//    toolCheckDomain = "wangpan.yzmetax.com";
//    toolCode = 123;
//    toolDesc = "\U6d4b\U8bd5";
//    toolKey = e10adc3949ba59abbe56e057f20f883e1;
//    toolName = "js-sdk\U6d4b\U8bd5";
//    toolUrl = "https://wangpan.yzmetax.com/index.html";
//};




@end
