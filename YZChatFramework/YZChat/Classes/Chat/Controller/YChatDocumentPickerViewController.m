//
//  YChatDocumentPickerViewController.m
//  YChat
//
//  Created by magic on 2020/12/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YChatDocumentPickerViewController.h"
#import "UIColor+ColorExtension.h"
@interface YChatDocumentPickerViewController ()

@end

@implementation YChatDocumentPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:kCommonBlueTextColor]} forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];

}


@end
