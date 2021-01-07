//
//  YZChatHTTPClient.m
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZChatHTTPClient.h"
#import "YZChatRequestBuilder.h"

static NSTimeInterval YChat_Gloabal_Timeout = 20.0;


@implementation YZChatHTTPClient

+ (instancetype)sharedClient {
    static YZChatHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
         sessionConfig.timeoutIntervalForRequest = YChat_Gloabal_Timeout;
        _sharedClient = [[YZChatHTTPClient alloc] initWithSessionConfiguration:sessionConfig];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.requestSerializer.timeoutInterval = YChat_Gloabal_Timeout;
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:[NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"application/x-javascript", nil]];
    });
    return _sharedClient;
}

- (NSDictionary *)setHttpHeader {
    return @{};
}

-(void)prepareHTTPS{
    //先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ychat_cert" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    NSSet *cerSet = [[NSSet alloc] initWithArray:@[certData]];
    securityPolicy.pinnedCertificates = cerSet;
    [self setSecurityPolicy:securityPolicy];
}

@end
