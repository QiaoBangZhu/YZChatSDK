//
//  YChatUploadManager.m
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZChatUploadManager.h"
#import <AFNetworking.h>
#import "YZChatRequestBuilder.h"
#import <QMUIKit.h>

@implementation YZChatUploadManager
DEF_SINGLETON(YZChatUploadManager);

+ (void)post:(NSString *)url params:(NSDictionary * __nullable)params imageData:(NSData *)imageData imageName:(NSString *)imageName onComplete:(void (^)(NSDictionary *, BOOL))onComplete {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    url = [NSString stringWithFormat:@"%@%@", YCHAT_REQUEST_BASE_URLS_PRODUCTION, url];
    [manager POST:url parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData name:imageName fileName:[NSString stringWithFormat:@"%@.png", imageName] mimeType:@"image/jpeg"];
        NSLog(@"%@",formData);
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress = %@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //网络请求成功
        NSData *resData = [[NSData alloc] initWithData:responseObject];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        if (onComplete) {
           if ([resultDic[@"error"] boolValue]) {
               [QMUITips showError: resultDic[@"msg"]];
           }else {
               onComplete(resultDic,YES);
           }
       }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [QMUITips showError: error.localizedDescription];
    }];
}

@end
