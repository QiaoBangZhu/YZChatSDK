////
////  YBaseTableViewController.m
////  YChat
////
////  Created by magic on 2020/10/25.
////  Copyright © 2020 Apple. All rights reserved.
////
//
//#import "YBaseTableViewController.h"
//#import "UIImage+YChatExtension.h"
//#import "CommonConstant.h"
//
//@interface YBaseTableViewController ()
//@property (nonatomic, strong)UILabel * titleLabel;
//
//@end
//
//@implementation YBaseTableViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0,100, 44)];
//    _titleLabel.textAlignment = NSTextAlignmentLeft;
//    _titleLabel.textColor = [UIColor blackColor];
//    _titleLabel.font = [UIFont systemFontOfSize:21 weight:UIFontWeightMedium];
//    [titleView addSubview:_titleLabel];
//    self.navigationItem.titleView = titleView;
//    
//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor clearColor]];
//
//}
//
//- (void)setTitleName:(NSString *)titleName {
//    _titleName = titleName;
//    self.titleLabel.text = titleName;
//}
//
//
//@end
