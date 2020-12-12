//
//  RequestUtils.h
//  YChat
//
//  Created by magic on 2020/09/01.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^successBlock)(NSDictionary *responseDict);
typedef void (^failureBlock)(NSError  *error);

@interface RequestUtils : NSObject
@property (nonatomic, copy) void (^successBlock)(NSString*);
@property (nonatomic, copy) void (^failureBlock)(NSError*);

+ (void)getData:(NSString *)urlStr completion:(void(^)(NSData *data, NSError*error))completion;
+ (void)postData:(NSString *)urlStr params:(NSDictionary* __nullable)dict completion:(void(^)(BaseResponse* responase, NSDictionary *data, NSError*error))completion;

+ (void)POST:(NSString *)urlStr params:(NSDictionary* __nullable)dict completion:(void(^)(BaseResponse* responase, NSData *data, NSError*error))completion;

//AFManager请求网络
+ (void)get:(NSString *)urlStr params:(NSDictionary* )dict completion:(void (^)(NSDictionary* data, NSError* error))completion;
+ (void)post:(NSString *)urlStr params:(NSDictionary* )dict completion:(void (^)(NSDictionary* data, NSError* error))completion;
+ (void)upload:(NSString *)urlStr bodys:(NSDictionary* )bodys files:(NSDictionary* )files completion:(void (^)(NSDictionary* data, NSError* error))completion;
//+ (void)download:(NSString *)urlStr bodys:(NSDictionary* )bodys filepath:(NSString *)filepath completion:(void (^)(NSDictionary* data, NSError* error))completion;

+ (void)download:(NSString*)urlStr path:(NSString*)path bodys:(NSString*)body completion:(void (^)(BOOL finished, NSData* data, NSError* error))completion;

+ (void)postFile:(NSString *)url params:(NSDictionary *)params imageData:(NSData *)imageData imageName:(NSString *)imageName onComplete:(void (^)(NSDictionary *, BOOL))onComplete;


/**
 上传多张图片方法
 @param imagesArray  上传的图片
 @param url          请求连接，根路径
 @param filename     图片的名称(如果不传则以当时间命名)
 @param name         上传图片时填写的图片对应的参数 服务器规定的
 @param params       参数
 @param success      请求成功返回数据
 @param failure      请求失败
 */

+ (void)uploadImages:(NSArray *)imagesArray
                      url:(NSString *)url
                 filename:(NSString *)filename
                     name:(NSString *)name
                   params:(NSDictionary *)params
                  success:(successBlock)success
                     failure:(failureBlock)failure;

@end

NS_ASSUME_NONNULL_END
