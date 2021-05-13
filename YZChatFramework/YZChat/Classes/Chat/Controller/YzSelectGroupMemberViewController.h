//
//  YzSelectGroupMemberViewController.h
//  YZChat
//
//  Created by 安笑 on 2021/5/12.
//

#import "YzCommonTableViewController.h"

#import <ImSDKForiOS/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^GroupMemberSelectFilterBlock)(NSString *memberId);
typedef void(^GroupMemberSelectCompletedBlock)(NSArray <NSString *>*ids);

@interface YzSelectGroupMemberViewController : YzCommonTableViewController

/// 禁用联系人过滤器
@property (nonatomic, copy, nullable) GroupMemberSelectFilterBlock disableFilter;
/// 显示联系人过滤器
@property (nonatomic, copy, nullable) GroupMemberSelectFilterBlock availableFilter;
/// 列表数据为空提示
@property (nonatomic, copy, nullable) NSString *emptyTip;
/// 完成选择
@property (nonatomic, copy) GroupMemberSelectCompletedBlock selectCompleted;

- (instancetype)initWithGroupId:(NSString *)groupId
                         filter:(V2TIMGroupMemberFilter)filter
              multipleSelection: (BOOL)multipleSelection;

@end

NS_ASSUME_NONNULL_END
