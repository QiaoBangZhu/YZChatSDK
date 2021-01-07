//
//  UserInfo.h
//  YChat
//
//  Created by magic on 2020/9/24.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : BaseModel<NSCoding,NSCopying>
@property (nonatomic ,   copy) NSString              * userSign;
@property (nonatomic ,   copy) NSString              * userId;
@property (nonatomic ,   copy) NSString              * nickName;
@property (nonatomic ,   copy) NSString              * companyId;
@property (nonatomic ,   copy) NSString              * companyName;
@property (nonatomic ,   copy) NSString              * departMentId;
@property (nonatomic ,   copy) NSString              * departName;
@property (nonatomic ,   copy) NSString              * card;
@property (nonatomic ,   copy) NSString              * createId;
@property (nonatomic ,   copy) NSString              * createTime;
@property (nonatomic ,   copy) NSString              * dimension;
@property (nonatomic ,   copy) NSString              * email;
@property (nonatomic ,   copy) NSString              * uid;
@property (nonatomic ,   copy) NSString              * lastModifyId;
@property (nonatomic ,   copy) NSString              * lastModifyTime;
@property (nonatomic ,   copy) NSString              * longitude;
@property (nonatomic ,   copy) NSString              * mobile;
@property (nonatomic ,   copy) NSString              * password;
@property (nonatomic ,   copy) NSString              * position;
@property (nonatomic ,   copy) NSString              * userIcon;
@property (nonatomic ,   copy) NSString              * token;
@property (nonatomic , assign) NSInteger               functionPerm;
@property (nonatomic,    copy) NSString              * userRemark;
@property (nonatomic,  assign) int                     gender;
@property (nonatomic,    copy) NSString              * userSignature;
@property (nonatomic,  assign) NSInteger               userType;
@property (nonatomic,    copy) NSString              * city;
@property (nonatomic,    copy) NSString              * addressBookName;
@end

/**
 //login
 {
     code = 200;
     data =     {
         companyId = yx001001;
         departMentId = 456580923;
         departName = "\U5e73\U53f0\U7814\U53d1\U4e2d\U5fc3";
         nickName = "\U5927\U7edf\U9886";
         userIcon = "https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/1602823575368file.png";
         userId = 95e6bd162f019b60ad8380fba5e0db41;
         userSign = "eJwtjU0LgkAURf-LrMPem3mOo9AiiFJsU0l7hxltklL8CCH674m6vOdy7v2y7HzzPrZlEeMesM2cnbHv3hVuxqFvpTYoeQEYagm5UUJBoXPfgtGEq9OZKm8aZ1iEBECCc45LY8fGtZZFEkgBLKx3r4mgBEHkB4FaN1w5HcaZssnjvm2Ph*Ga7rXIxDOJxzqlU41dT7FMKih5cBlox35-xjk26A__";
     };
     msg = "";
     token = ae20aad34b30264e55766feef58b9e9f;
 }

//userInfo
 {
     code = 200;
     data =     {
         card = "";
         companyId = yx001001;
         companyName = "\U5143\U77e5\U667a\U80fd\U7814\U7a76\U9662";
         createId = "system_register";
         createTime = "2020-10-09 15:17:13";
         deleteStatus = 0;
         departName = "\U5e73\U53f0\U7814\U53d1\U4e2d\U5fc3";
         departmentId = 456580923;
         dimension = "";
         email = "dalao@apple.com";
         id = 3;
         lastModifyId = "user_update";
         lastModifyTime = "2020-10-16 12:46:41";
         longitude = "<null>";
         mobile = 13552253631;
         nickName = "\U5927\U7edf\U9886";
         password = 5d1be6df3075888b0ebcde0839b8c706;
         position = "\U603b\U7edf";
         userIcon = "https://yzkj-im.oss-cn-beijing.aliyuncs.com/user/1602823575368file.png";
         userId = 95e6bd162f019b60ad8380fba5e0db41;
     };
     msg = "\U64cd\U4f5c\U6210\U529f";
     token = "";
 }

 
 {
     code = 200;
     data =     {
         card = "";
         city = "<null>";
         companyId = de241446a50499bb77a8684cf610fd04;
         companyName = "\U5e73\U53f0\U7814\U53d1\U4e2d\U5fc3";
         createId = "system_register";
         createTime = "2020-12-19 18:45:14";
         deleteStatus = 0;
         departName = "\U5e73\U53f0\U7814\U53d1\U4e2d\U5fc3";
         departmentId = 456580923;
         dimension = "";
         email = "";
         gender = 0;
         id = 1340246810853875714;
         lastModifyId = "sys_user_update";
         lastModifyTime = "2020-12-28 15:57:17";
         longitude = "<null>";
         mobile = 13552253631;
         nickName = q;
         password = 3e804c2b4af0e53368e3cfdd8ce6d719;
         position = "";
         userIcon = "";
         userId = bd331a601384b9dfb6b7f3631d5b8676;
         userRemark = "<null>";
         userSignature = "\U7b7e\U540d";
         userType = 0;
     };
     msg = "\U64cd\U4f5c\U6210\U529f";
     token = "";
 }
 
 
 
 
 
 
 
 */


NS_ASSUME_NONNULL_END
