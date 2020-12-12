//
//  TCommonContactCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TCommonContactCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TCommonContactCellData.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <ImSDKForiOS/ImSDK.h>
#import "CreatGroupAvatar.h"

@interface TCommonContactCell()
@property TCommonContactCellData *contactData;
@end

@implementation TCommonContactCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(34).mm_height(34).mm__centerY(28).mm_left(12);
        if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
        } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
        }

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    return self;
}

- (void)fillWithData:(TCommonContactCellData *)contactData
{
    [super fillWithData:contactData];
    self.contactData = contactData;

    self.titleLabel.text = contactData.title;
    [self.avatarView sd_setImageWithURL:contactData.avatarUrl placeholderImage:contactData.avatarImage?:DefaultAvatarImage];
}

- (void)createGrpAvatarByGrpId:(NSString *)gropId {
    if ([gropId length] > 0) {
        
        // 群组, 则将群组默认头像修改成上次使用的头像
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", gropId];
        NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
        UIImage *avatar = [self getCacheAvatarForGroup:gropId number:(UInt32)member];
        if (avatar) {
            self.contactData.avatarImage = avatar;
        }
    }
    @weakify(self)
    [[RACObserve(self.contactData,avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        if (gropId.length > 0) { //群组
            // fix: 由于getCacheGroupAvatar需要请求网络，断网时，由于并没有设置headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱
            self.avatarView.image = self.contactData.avatarImage;
            [self getCacheGroupAvatar:^(UIImage *avatar) {
                if (avatar != nil) { //已缓存群组头像
                    self.avatarView.image = avatar;
                } else { //未缓存群组头像
                    [self.avatarView sd_setImageWithURL:x
                                          placeholderImage:self.contactData.avatarImage];
                    [self prefetchGroupMembers];
                }
            }];
        } else {//个人头像
            [self.avatarView sd_setImageWithURL:x
                                  placeholderImage:self.contactData.avatarImage];
        }
    }];

}

/// 取得群组前9个用户
- (void)prefetchGroupMembers {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:self.contactData.identifier filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        int i = 0;
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo* member in memberList) {
            if (member.faceURL.length > 0) {
                [groupMemberAvatars addObject:member.faceURL];
                i++;
            }
            if (i == 9) {
                break;
            }
        }
        [self createGroupAvatar:groupMemberAvatars];
        
        // 存储当前获取到的群组头像信息
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", self.contactData.identifier];
        [NSUserDefaults.standardUserDefaults setInteger:groupMemberAvatars.count forKey:key];
        [NSUserDefaults.standardUserDefaults synchronize];
        
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.avatarView sd_setImageWithURL:self.contactData.avatarUrl
                              placeholderImage:self.contactData.avatarImage];
    }];
}

/// 创建九宫格群头像
- (void)createGroupAvatar:(NSMutableArray*)groupMemberAvatars{
    @weakify(self)
    [CreatGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(NSData *groupAvatar) {
        @strongify(self)
        UIImage *avatar = [UIImage imageWithData:groupAvatar];
        self.avatarView.image = avatar;
        [self cacheGroupAvatar:avatar number:(UInt32)groupMemberAvatars.count];
    }];
}

/// 缓存群组头像
/// @param avatar 图片
/// 取缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化取不到缓存
- (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum {
    if (self.contactData.identifier.length == 0) {
        return;
    }
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
                          self.contactData.identifier,memberNum];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check to delete old file
    NSNumber *oldValue = [defaults objectForKey:self.contactData.identifier];
    if ( oldValue != nil) {
        UInt32 oldMemberNum = [oldValue unsignedIntValue];
        NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
        self.contactData.identifier,oldMemberNum];
         NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:oldFilePath error:nil];
    }
    
    // Save image.
    BOOL success = [UIImagePNGRepresentation(self.avatarView.image) writeToFile:filePath atomically:YES];
    if (success) {
        [defaults setObject:@(memberNum) forKey:self.contactData.identifier];
    }
}

/// 获取缓存群组头像
/// 缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化要引起头像改变
- (void)getCacheGroupAvatar:(void(^)(UIImage *))imageCallBack {
    [[V2TIMManager sharedInstance] getGroupsInfo:@[self.contactData.identifier] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
        if (!groupInfo) {
            imageCallBack(nil);
            return;
        }
        UInt32 memberNum = groupInfo.info.memberCount;
        //限定1-9的范围
        memberNum = MAX(1, memberNum);
        memberNum = MIN(memberNum, 9);;
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                              self.contactData.identifier,(unsigned int)memberNum];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];

        if (success) {
            avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
            // 存储当前获取到的群组头像信息
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", self.contactData.identifier];
            [NSUserDefaults.standardUserDefaults setInteger:memberNum forKey:key];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        imageCallBack(avatar);
    } fail:^(int code, NSString *msg) {
        imageCallBack(nil);
    }];
}


/// 同步获取本地缓存的群组头像
/// @param groupId 群id
/// @param memberNum 群成员个数, 最多返回9个成员的拼接头像
- (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum {
    //限定1-9的范围
    memberNum = MAX(1, memberNum);
    memberNum = MIN(memberNum, 9);;
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                          groupId,(unsigned int)memberNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    UIImage *avatar = nil;
    BOOL success = [fileManager fileExistsAtPath:filePath];

    if (success) {
        avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return avatar;
}




@end
