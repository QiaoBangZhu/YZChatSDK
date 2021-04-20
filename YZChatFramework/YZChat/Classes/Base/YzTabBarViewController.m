//
//  YzTabBarViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/15.
//

#import "YzTabBarViewController.h"

#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"
#import "YChatSettingStore.h"
#import "YzNavigationController.h"

@interface YzTabBarViewController ()

@end

@implementation YzTabBarViewController

- (void)didInitialize {
    [super didInitialize];

    [self setupViewControllers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Public

- (void)setConversationBadge:(NSInteger)badge {
    self.conversationListController.navigationController.tabBarItem.cigam_badgeString = [self badgeStringForBadge: badge];
}

- (void)setContactsBadge:(NSInteger)badge {
    self.contactsViewController.navigationController.tabBarItem.cigam_badgeString = [self badgeStringForBadge: badge];
}

#pragma mark - Helper

- (NSString * _Nullable)badgeStringForBadge:(NSInteger)badge {
    if (!badge) return  nil;
    if (badge > 99) return @"99+";
    return [NSString stringWithFormat: @"%ld", badge];
}

#pragma mark - 页面布局

- (void)setupViewControllers {
    NSInteger perm = [[YChatSettingStore sharedInstance] getFunctionPerm];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

    if ((perm & 1) > 0) {
        self.conversationListController = [[YzInternalConversationListController alloc] init];
        YzNavigationController *nav = [[YzNavigationController alloc] initWithRootViewController: self.conversationListController];
        nav.tabBarItem.image = [self imageForName: @"message_normal"];
        nav.tabBarItem.selectedImage = [self selectedImageForName: @"message_pressed"];
        nav.tabBarItem.title = @"消息";
        [viewControllers addObject: nav];
    }

    if ((perm & 2) > 0) {
        self.contactsViewController = [[YzContactsViewController alloc] init];
        YzNavigationController *nav = [[YzNavigationController alloc] initWithRootViewController: self.contactsViewController];
        nav.tabBarItem.image = [self imageForName: @"contacts_normal"];
        nav.tabBarItem.selectedImage = [self selectedImageForName: @"contacts_pressed"];
        nav.tabBarItem.title = @"通讯录";
        [viewControllers addObject: nav];
    }

    if ((perm & 4) > 0) {
        self.workZoneViewController = [[YWorkZoneViewController alloc] init];
        YzNavigationController *nav = [[YzNavigationController alloc] initWithRootViewController: self.workZoneViewController];
        nav.tabBarItem.image = [self imageForName: @"workzone_normal"];
        nav.tabBarItem.selectedImage = [self selectedImageForName: @"workzone_selected"];
        nav.tabBarItem.title = @"工作台";
        [viewControllers addObject: nav];
    }

    if ((perm & 8) > 0) {
        self.myViewController = [[YZMyViewController alloc] init];
        YzNavigationController *nav = [[YzNavigationController alloc] initWithRootViewController: self.myViewController];
        nav.tabBarItem.image = [self imageForName: @"setting_normal"];
        nav.tabBarItem.selectedImage = [self selectedImageForName: @"setting_pressed"];
        nav.tabBarItem.title = @"我";
        [viewControllers addObject: nav];
    }

    for (UINavigationController *nav in viewControllers) {
        nav.topViewController.hidesBottomBarWhenPushed = NO;
    }
    self.viewControllers = viewControllers;
}

- (UIImage *)imageForName:(NSString *)name {
    return  [YZChatResource(name) imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)selectedImageForName:(NSString *)name {
    return  [[YZChatResource(name) cigam_imageResizedInLimitedSize: CGSizeMake(28, 28)]
             imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
}

@end
