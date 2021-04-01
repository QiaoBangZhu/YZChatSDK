//
//  YWebViewController.m
//  YZChat_Example
//
//  Created by magic on 2021/3/31.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import "YWebViewController.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import <QMUIKit/QMUIKit.h>

@interface YWebViewController ()<WKNavigationDelegate>
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)UIButton  *backBtn;

@end


@implementation YWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.webView];
  
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    [self.webView loadRequest:[NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30]];
    [QMUITips showLoading:@"加载中" inView:self.view];
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc]initWithFrame:self.view.frame];
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [QMUITips hideAllTips];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"did fail with error = %@",error.localizedDescription);
}



@end
