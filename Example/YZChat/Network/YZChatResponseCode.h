//
//  YChatResponseCode.h
//  YChat
//
//  Created by magic on 2020/9/23.
//  Copyright © 2020 Apple. All rights reserved.
//

#ifndef YChatResponseCode_h
#define YChatResponseCode_h



typedef NS_ENUM(NSInteger, RequestErrorCodeType)
{
    YChatResponseCodeParseError = -1001,
    YChatResponseCodeSucceed = 0,       //操作成功
    ReqErrorCodeUnknow = 99,            //未知错误
    ReqErrorCodeParseError = 1001,      //返回结果解析错误
    ReqErrorCodeError = 200,            //错误
    
};





#endif /* YChatResponseCode_h */



