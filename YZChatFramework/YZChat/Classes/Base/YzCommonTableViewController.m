//
//  YzCommonTableViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/19.
//

#import "YzCommonTableViewController.h"

#import <IQKeyboardManager/IQKeyboardManager.h>

@interface YzCommonTableViewController ()

@end

@implementation YzCommonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    [self subscribe];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];

    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)setupSubviews {}

- (void)subscribe {}

- (void)showEmptyViewWithText:(NSString *)text {
    [self showEmptyViewWithText: text detailText: nil buttonTitle: nil buttonAction: nil];
}

@end
