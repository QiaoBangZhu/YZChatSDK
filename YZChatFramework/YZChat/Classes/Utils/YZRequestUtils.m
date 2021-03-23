//
//  RequestUtils.m
//  YChat
//
//  Created by magic on 2020/09/01.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZRequestUtils.h"
#import <AFHTTPSessionManager.h>
#import "YZUtil.h"

@implementation YZRequestUtils

#define STR(str) [NSString stringWithUTF8String: str.toRawUTF8()]

+ (void) dispathGlobalQueue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        
    });
}

+ (void) dispathMainQueue{
    //在主线程操作UI对象
    dispatch_async(dispatch_get_main_queue(), ^(){
        
    });
}
                   
+ (NSData*)requestData:(NSString *)urlStr error:(NSError**) error {
    //创建url对象
    NSURL *url=[NSURL URLWithString:urlStr];
    //构造Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    [request setTimeoutInterval:10];
    //同步请求数据
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    return data;
}

+ (void)getData:(NSString *)urlStr completion:(void(^)(NSData *data, NSError*error))completion {
    //创建url对象
    NSURL *url=[NSURL URLWithString:urlStr];
    //构造Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    [request setTimeoutInterval:10];
    //发送异步请求
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        //在主线程操作UI对象
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(data,error);
            }
        });
         
     }];
}

//id 可以为一个字典
+ (void)postData:(NSString *)urlStr params:(NSDictionary* __nullable)dict completion:(void(^)(YZBaseResponse* responase, NSDictionary *data, NSError*error))completion {
    //创建url对象
    NSURL *url=[NSURL URLWithString:urlStr];
    //构造Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
    //dict转化
    if (dict != nil) {
        //NSData *body = [Tools dictToData:params];
        NSString *bodyStr = [YZUtil dictionary2JsonStr:dict];
        NSData *body = [bodyStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];//NSUTF8StringEncoding
        [request setHTTPBody:body];
    }
    
    //发送异步请求
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSDictionary *dictData = nil;YZBaseResponse *responseObj = nil;
        if (data != nil) {
            responseObj = [YZBaseResponse mj_objectWithKeyValues:data];
            dictData = [YZUtil jsonData2Dictionary:data];
        }
        //在主线程操作UI对象
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(responseObj,dictData,error);
            }
        });
     }];
}

+ (void)POST:(NSString *)urlStr params:(NSDictionary* __nullable)dict completion:(void(^)(YZBaseResponse* responase, NSData *data, NSError*error))completion {
    //创建url对象
     NSURL *url=[NSURL URLWithString:urlStr];
     //构造Request
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
     [request setHTTPMethod:@"POST"];
     [request setTimeoutInterval:10];
     //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
     //dict转化
     if (dict != nil) {
         NSString *bodyStr = [YZUtil dictionary2JsonStr:dict];
         NSData *body = [bodyStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];//NSUTF8StringEncoding
         [request setHTTPBody:body];
     }
     
     //发送异步请求
     NSOperationQueue *queue = [[NSOperationQueue alloc]init];
     [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
         YZBaseResponse *responseObj = nil;
         if (data != nil) {
             responseObj = [YZBaseResponse mj_objectWithKeyValues:data];
         }
         //在主线程操作UI对象
         dispatch_async(dispatch_get_main_queue(), ^(){
             if (completion) {
                 completion(responseObj,data,error);
             }
         });
      }];
}

//AFManager请求网络,#import <AFNetworking.h>
+ (void)get:(NSString *)urlStr params:(NSDictionary* )dict completion:(void (^)(NSDictionary* data, NSError* error))completion {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这句话加了之后返回的responseObject就是JSONData了，如果不加那就是正常的JSON可以直接转成字典然后操作
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"text/plain", nil];
    [manager GET:urlStr parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功---%@---%@",responseObject, [responseObject class]);
        //在主线程操作UI对象
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(nil,nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败--%@",error);
        //在主线程操作UI对象
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(nil,nil);
            }
        });
    }];
}

+ (void)post:(NSString *)urlStr params:(NSDictionary* )dict completion:(void (^)(NSDictionary* data, NSError* error))completion {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这句话加了之后返回的responseObject就是JSONData了，如果不加那就是正常的JSON可以直接转成字典然后操作
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"text/plain", nil];
    
    [manager POST:urlStr parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功---%@---%@",responseObject, [responseObject class]);
        //在主线程操作UI对象
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(nil,nil);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败--%@",error);
        //在主线程操作UI对象
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(nil,nil);
            }
        });
    }];
}

+ (void)postImageData:(NSString *)urlStr params:(NSDictionary* )dict completion:(void (^)(NSDictionary* data, NSError* error))completion {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这句话加了之后返回的responseObject就是JSONData了，如果不加那就是正常的JSON可以直接转成字典然后操作
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    manager.requestSerializer.timeoutInterval = 15;
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/json",
                                                         @"text/javascript,multipart/form-data",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"text/plain", nil];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:dict];
//    [params setValue:@"files" forKey:@"files"];
    [manager POST:urlStr parameters:dict headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSArray* photos = dict[@"files"];
        for (int i = 0; i < photos.count; i ++) {
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            formatter.dateFormat=@"yyyyMMddHHmmss";
            NSString *str=[formatter stringFromDate:[NSDate date]];
            NSString *fileName=[NSString stringWithFormat:@"%@.jpg",str];
            UIImage *image = photos[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"upload%d",i+1] fileName:fileName mimeType:@"image/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dictData = [YZUtil jsonData2Dictionary:responseObject];
               NSLog(@"123:%@",dictData);
               dispatch_async(dispatch_get_main_queue(), ^(){
                   if (completion) {
                       completion(dictData,nil);
                   }
               });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (completion) {
                completion(nil,error);
            }
        });
    }];
}

+ (void)upload:(NSString *)urlStr bodys:(NSDictionary* )bodys files:(NSDictionary* )files completion:(void (^)(NSDictionary* data, NSError* error))completion {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这句话加了之后返回的responseObject就是JSONData了，如果不加那就是正常的JSON可以直接转成字典然后操作
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"text/plain", nil];
    
    [manager POST:urlStr parameters:@{@"username":@"123"} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSURL *url=[NSURL fileURLWithPath:@"/Users/hq/Desktop/2.jpg"];
        
        [formData appendPartWithFileURL:url name:@"file" fileName:@"2.jpg" mimeType:@"image/jpeg" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

+ (void)download:(NSString *)urlStr bodys:(NSDictionary* )bodys filepath:(NSString *)filepath completion:(void (^)(NSDictionary* data, NSError* error))completion {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这句话加了之后返回的responseObject就是JSONData了，如果不加那就是正常的JSON可以直接转成字典然后操作
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"text/plain", nil];
    
    [manager POST:urlStr parameters:@{@"username":@"123"} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSURL *url=[NSURL fileURLWithPath:@"/Users/hq/Desktop/2.jpg"];
        
        [formData appendPartWithFileURL:url name:@"file" fileName:@"2.jpg" mimeType:@"image/jpeg" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//+ (void)download:(NSString *)urlStr path:(NSString*)path bodys:(NSString *)body completion:(nonnull void (^)(BOOL finished, NSData * data, NSError * error))completion {
//    UIImage* image = [RequestUtils loadLocalImage:path filePath:path];
//    NSData* imageData = UIImagePNGRepresentation(image);
//    if (imageData) {
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            if (completion) {
//                completion(true,imageData,nil);
//            }
//        });
//        return;
//    }
//    NSURL* url = [NSURL URLWithString:[urlStr stringByRemovingPercentEncoding]];
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            // 下载完成，将图片保存到本地
////            [data writeToFile:[TCUtil imageFilePath:path path: path] atomically:YES];
//            if (completion) {
//                completion(true,imageData,nil);
//            }
//        }
//        if (error) {
//            if (completion) {
//                completion(false,nil,error);
//            }
//        }
//    }];
//    [task resume];
//}

//+ (UIImage *)loadLocalImage:(NSString *)imageUrl filePath:(NSString*)path {
//    NSString * filePath = [TCUtilz imageFilePath:path path:path];
//    UIImage* image = [UIImage imageWithContentsOfFile:filePath];
//    return image;
//}

/// 删除
+ (void)deleteFiles{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:@"/DownloadFiles"];
    [fileManager removeItemAtPath:path error:nil];
}

//上传单张图
+ (void)postFile:(NSString *)url params:(NSDictionary *)params imageData:(NSData *)imageData imageName:(NSString *)imageName onComplete:(void (^)(NSDictionary *, BOOL))onComplete {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    [manager POST:url parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:imageName fileName:[NSString stringWithFormat:@"%@.png", imageName] mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //网络请求成功
        NSData *resData = [[NSData alloc] initWithData:responseObject];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        if (onComplete) {
            if ([resultDic[@"error"] boolValue]) {
            }else {
                onComplete(resultDic,YES);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error= %@", error.localizedDescription);
    }];
}

+(void)uploadImages:(NSArray *)imagesArray url:(NSString *)url filename:(NSString *)filename name:(NSString *)name    params:(NSDictionary *)params  success:(successBlock)success failure:(failureBlock)failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:
                                                           @"application/json",
                                                           @"text/json",
                                                           @"text/javascript",
                                                           @"text/html",
                                                           @"text/css",
                                                           @"text/plain",
                                                           @"application/javascript",
                                                           @"image/jpeg",
                                                           @"text/vnd.wap.wml",
                                                           @"application/x-javascript",
                                                           @"image/png",
                                                           @"multipart/form-data",nil]];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:url parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSInteger i = 0; i < imagesArray.count; i ++) {
            //压缩图片
            NSData *imageData = UIImageJPEGRepresentation(imagesArray[i], 0.5);
            NSString *imageFileName =filename;
            if (filename == nil || [filename isKindOfClass:[NSString class]] || filename.length == 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
                imageFileName = [NSString stringWithFormat:@"%@.jpg",str];
            }
            //上传图片，以文件流的格式
            [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"上传速度--%lld,总进度--%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *resData = [[NSData alloc] initWithData:responseObject];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"上传图片成功-%@",resultDic);
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            success(resultDic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error=%@",error);
        failure(error);
    }];
}


@end
