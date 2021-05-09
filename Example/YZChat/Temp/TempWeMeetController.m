//
//  TempWeMeetController.m
//  YZChat_Example
//
//  Created by 安笑 on 2021/5/9.
//  Copyright © 2021 QiaoBangZhu. All rights reserved.
//

#import "TempWeMeetController.h"

#import <TMRTC/TMRTC.h>
#import <QMUIKit/QMUIKit.h>

@interface TempWeMeetController ()<TMRTCAuthServiceDelegate, TMRTCAuthServiceDataSource>

@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, weak) UIViewController *topViewController;

@end

@implementation TempWeMeetController

DEF_SINGLETON(TempWeMeetController);

- (instancetype)init {
    self = [super init];
    if (self) {
        TMRTCAppDelegateInitAttributes *attributes = [[TMRTCAppDelegateInitAttributes alloc] init];
        attributes.extensionGroupId = @"com.yuanzhi.chat";
        /// FIXME: 有这个bundle???
        attributes.resourceBundlePath = [[NSBundle mainBundle] pathForResource: @"TMRTCResource" ofType: @"bundle"];
        attributes.sdkId = @"2009233371";
        attributes.sdkToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIyMDA5MjMzMzcxIiwiaWF0IjoxNjAxMjgyNTY2LCJleHAiOjE2MDY1NTI5NjYsImF1ZCI6IlRlbmNlbnQgTWVldGluZyIsInN1YiI6Inl1YW56aGlfdGVzdDAxIn0.9DXh4MFF490mVipau7QgotrFvCe-tupj3JtefbTLQ44";
        [[TMRTCAppDelegate sharedRTC] initWithAttributes: attributes];
        [[TMRTCAppDelegate sharedRTC] authService].dataSource = self;
        [[TMRTCAppDelegate sharedRTC] authService].delegate = self;
    }
    return self;
}

- (void)startWithToken:(NSString *)token viewController:(UIViewController *)viewController {
    self.token = token;
    self.topViewController = viewController;

    self.rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if([[[TMRTCAppDelegate sharedRTC] authService] login]) {
        [QMUITips showLoadingInView: viewController.view];
    } else {
        self.rootViewController = nil;
        self.topViewController = nil;
    }
}

#pragma mark - TMRTCAuthServiceDataSource

- (void)ssoAuthCodeForAuth:(void (^)(NSString * _Nonnull))block {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://yzmetax-idp.id.meeting.qq.com/cidp/login/ai-2f96eed8349d4c7e8424cbe5a7136645?state=aHR0cHM6Ly95em1ldGF4LmlkLm1lZXRpbmcucXEuY29tL3Nzby9haS0xZTJlMzA5NjVhZjE0OGM3YWY5ODhjNGY3NzA3YTdlNg==&id_token=%@", self.token]];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                         completionHandler:^(NSData * _Nullable data,
                                                                             NSURLResponse * _Nullable rsp,
                                                                             NSError * _Nullable error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)rsp;
        if ([response statusCode] != 200) {
            [QMUITips showError: [NSString stringWithFormat: @"response error %ld", (long)[response statusCode]]];
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
        [QMUITips showError: @"sso_auth_code not found"];
    }];
    [task resume];
}

#pragma mark - TMRTCAuthServiceDelegate

- (void)auth:(TMRTCAuthService *)auth didFinishLoginWithError:(NSError *)error {
    if (error) {
        [QMUITips hideAllTipsInView: self.topViewController.view];
        self.rootViewController = nil;
        self.topViewController = nil;
        [QMUITips showError: error.localizedDescription];
    } else {
        [QMUITips hideAllTipsInView: self.topViewController.view];
    }
}

- (void)auth:(TMRTCAuthService *)auth didFinishLogoutWithError:(NSError *)error {
    if (error) {
        [QMUITips showError: error.localizedDescription];
    }
}

- (void)exit {
    [[UIApplication sharedApplication] keyWindow].rootViewController = self.rootViewController;
    self.rootViewController = nil;
    [[[TMRTCAppDelegate sharedRTC] authService] logout];
}

@end
