//
//  QDCommonTableViewController.m
//  YChat
//
//  Created by magic on 2020/10/9.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "QDCommonTableViewController.h"

@implementation QDCommonTableViewController

- (void)initTableView {
    [super initTableView];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable {
    return YES;
}

- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    [super qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    [self.tableView reloadData];
}


@end
