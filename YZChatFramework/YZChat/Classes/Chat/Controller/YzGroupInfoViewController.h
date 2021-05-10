//
//  YzGroupInfoViewController.h
//  YZChat
//
//  Created by 安笑 on 2021/5/10.
//

#import "CIGAMCommonTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class YzGroupInfoViewController;
@class TGroupMemberCellData;

/////////////////////////////////////////////////////////////////////////////////
//
//                         YzGroupInfoViewControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol YzGroupInfoViewControllerDelegate <NSObject>

/**
 *  删除群组成功后的回调。如果因为网络等各种原因删除失败，该回调不会被调用。
 *  您可以通过该回调实现：（删除成功后）退出当前群组页面，返回消息列表。
 */
- (void)viewController:(YzGroupInfoViewController *)controller
        didDeleteGroup:(NSString *)groupId;

/**
 *  退出群组成功后的回调。如果因为网络等各种原因退群失败，该回调不会被调用。
 *  您可以通过该回调实现：（退出成功后）退出当前群组页面，返回消息列表。
 */
- (void)viewController:(YzGroupInfoViewController *)controller
          didQuitGroup:(NSString *)groupId;

@end

@interface YzGroupInfoViewController : CIGAMCommonTableViewController

- (instancetype)initWithGroupId:(NSString *)groupId;

@property (nonatomic, copy, readonly) NSString *groupId;
@property (nonatomic, weak) id<YzGroupInfoViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
