//
//  YzTabBarViewController.h
//  YZChat
//
//  Created by 安笑 on 2021/4/15.
//

#import "CIGAMKit.h"

#import "YzInternalConversationListController.h"
#import "YzContactsViewController.h"
#import "YWorkZoneViewController.h"
#import "YZMyViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzTabBarViewController : CIGAMTabBarViewController

@property (nonatomic, strong, nullable) YzInternalConversationListController *conversationListController;
@property (nonatomic, strong, nullable) YzContactsViewController *contactsViewController;
@property (nonatomic, strong, nullable) YWorkZoneViewController *workZoneViewController;
@property (nonatomic, strong, nullable) YZMyViewController *myViewController;

- (void)setConversationBadge:(NSInteger)badge;
- (void)setContactsBadge:(NSInteger)badge;

@end

NS_ASSUME_NONNULL_END
