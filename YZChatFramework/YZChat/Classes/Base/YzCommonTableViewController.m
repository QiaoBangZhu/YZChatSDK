//
//  YzCommonTableViewController.m
//  YZChat
//
//  Created by 安笑 on 2021/4/19.
//

#import "YzCommonTableViewController.h"

@interface YzCommonTableViewController ()

@end

@implementation YzCommonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)showEmptyViewWithText:(NSString *)text {
    [self showEmptyViewWithText: text detailText: nil buttonTitle: nil buttonAction: nil];
}

@end
