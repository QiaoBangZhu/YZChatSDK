//
//  CIGAMPopupMenuView+YzEx.m
//  YZChat
//
//  Created by 安笑 on 2021/4/17.
//

#import "CIGAMPopupMenuView+YzEx.h"

@implementation CIGAMPopupMenuView (YzExtension)

+ (CIGAMPopupMenuView *)yz_default {
    CIGAMPopupMenuView *menu = [[CIGAMPopupMenuView alloc] init];
    menu.automaticallyHidesWhenUserTap = YES;
    menu.shouldShowItemSeparator = YES;
    menu.minimumWidth = 120;
    menu.itemTitleColor = UIColorBlack;
    menu.preferLayoutDirection = CIGAMPopupContainerViewLayoutDirectionBelow;

    return menu;
}

@end
