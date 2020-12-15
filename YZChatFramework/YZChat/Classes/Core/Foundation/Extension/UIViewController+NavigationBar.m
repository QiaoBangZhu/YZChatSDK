//
//  UIViewController+NavigationBar.m
//  YChat
//
//  Created by magic on 2020/10/21.
//  Copyright © 2020 Apple. All rights reserved.
//

//#import "UIViewController+NavigationBar.h"
//#import "ZWhiteNavigationBar.h"
//#import "ZClearNavigationBar.h"
//#import "UIColor+Foundation.h"
//#import "CommonConstant.h"
//#import "UIControl+BlocksKit.h"
//#import "UIView+Foundation.h"
//
//@implementation UIViewController (NavigationBar)

//- (void)viewDidLoad {
//
//   self.isVisible = NO;
//
//   self.automaticallyAdjustsScrollViewInsets = NO;
//   //网络状态发生变化的时候的通知方法
//   [[NSNotificationCenter defaultCenter]addObserver:self
//                                           selector:@selector(playerNetWorkStatesChange:) name:@"netWorkChangeEventNotification"
//                                             object:nil];
//   self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//   if (!self.hiddenGobackHomeBtn) {
//
//   }
//}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.isVisible = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.isVisible = NO;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    if (self.navigationBarStyle == ZNavigationBarStyleDefault)
//    {
//        return UIStatusBarStyleLightContent;
//    }
//    else if (self.navigationBarStyle == ZNavigationBarStyleLight)
//    {
//        return UIStatusBarStyleDefault;
//    }
//    return UIStatusBarStyleLightContent;
//}
//
//- (ZNavigationBar *)createNavigationBar
//{
//    if (self.navigationBarStyle == ZNavigationBarStyleDefault)
//    {
//        return [[ZNavigationBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ZNavigationBarHeight)];
//    }
//    else if (self.navigationBarStyle == ZNavigationBarStyleLight)
//    {
//        return [[ZWhiteNavigationBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ZNavigationBarHeight)];
//    }
//    else if (self.navigationBarStyle == ZNavigationBarStyleClear) {
//        return [[ZClearNavigationBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ZNavigationBarHeight)];
//    }
//    else
//    {
//        return [[ZNavigationBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ZNavigationBarHeight)];
//    }
//}
//
//
//- (void)addNavigationBar {
//    if (!self.navigationBar) {
//        self.navigationBar = [self createNavigationBar];
//        NSString *title = self.title;
//        self.navigationBar.title = title;
//    }
//    
//    if (!self.navigationBar.superview) {
//        [self.view addSubview:self.navigationBar];
//    }
//}
//
//- (void)setTitle:(NSString *)title
//{
//    [super setTitle:title];
//    if (self.navigationBar)
//    {
//        self.navigationBar.title = title;
//    }
//}
//
//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    [self.view bringSubviewToFront:self.navigationBar];
//    if (!self.hiddenGobackHomeBtn) {
//        self.gobackHomeBtn.hidden = false;
//        [self.view bringSubviewToFront:self.gobackHomeBtn];
//    }else{
//        self.gobackHomeBtn.hidden = true;
//    }
//}
//
//- (void)back
//{
//    if (_isLandscape) {
//        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//    }else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}
//
//- (void)addDefaultBackButton
//{
//    if (self.navigationBar) {
//        if ([self.navigationBar isKindOfClass:[ZNavigationBar class]]) {
//            [self addBackButtonWithImage:[UIImage imageNamed:@"icon_back"]];
//        } else {
//            [self addBackButtonWithImage:[UIImage imageNamed:@"icon_back"]];
//        }
//    }
//}
//
//- (void)addBackButtonWithImage:(UIImage *)image
//{
//    __weak typeof(self) weakSelf = self;
//    [self addLeftButtonWithImage:image handler:^(id sender) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf back];
//    }];
//}
//
//- (void)addGobackBtn{
//    
//    if (!self->backBtnShow) {
//        self->backBtnShow = YES;
//        [YBFuncItemManager shareInstance].delegate = self;
//        [YBFuncItemManager showSuspensionViewWithDataArray:@[]];
//    }
//}
//
//- (void)hiddenGobackBtn:(BOOL)hide {
//    [YBFuncItemManager hiddenSuspensionView:hide];
//}
//
//- (void)addLeftButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 40.f, 40.f);
//    [btn setImage:image forState:UIControlStateNormal];
//    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.leftBarButton = btn;
//}
//
//- (void)addCustomLeftButtonWithImage:(UIImage *)image handler:(void(^)(id sender))handler {
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, image.size.width+15, image.size.height);
//    [btn setImage:image forState:UIControlStateNormal];
//    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.leftBarButton = btn;
//}
//
//
//- (void)addSecondLeftButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 40.f, 40.f);
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.secondLeftBarButton = btn;
//}
//
//- (void)addSecondRightButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 40.f, 40.f);
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.secondRightBarButton = btn;
//}
//
//- (void)addRightButtonWithImage:(UIImage *)image handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 40.f, 40.f);
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.rightBarButton = btn;
//}
//
//- (void)addRightButtonWithTitle:(NSString *)title handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 100.f, 40.f);
//    [btn setTitle:title forState:UIControlStateNormal];
//    btn.titleLabel.textAlignment = NSTextAlignmentRight;
//    btn.titleLabel.font = [UIFont systemFontOfSize:12];
//    CGRect frame = btn.frame;
//    frame.size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
//                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                  attributes:@{NSFontAttributeName:btn.titleLabel.font}
//                                     context:nil].size;
//    frame.size.height = 40;
//    btn.frame = frame;
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    frame = btn.frame;
//    frame.size.width = btn.frame.size.width + 20;
//    btn.frame = frame;
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.rightBarButton = btn;
//}
//
//- (void)addLeftButtonWithTitle:(NSString *)title handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 100.f, 40.f);
//    [btn setTitle:title forState:UIControlStateNormal];
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    CGRect frame = btn.frame;
//    frame.size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
//                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                  attributes:@{NSFontAttributeName:btn.titleLabel.font}
//                                     context:nil].size;
//    btn.frame = frame;
//    frame.size.height = 40;
//    
//    frame = btn.frame;
//    frame.size.width = btn.frame.size.width + 20;
//    btn.frame = frame;
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.leftBarButton = btn;
//}
//
//- (void)addSecondLeftButtonWithTitle:(NSString *)title handler:(void (^)(id sender))handler
//{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0.0f, 0.0f, 53.f, 40.f);
//    [btn setTitle:title forState:UIControlStateNormal];
//    btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
//    CGRect frame = btn.frame;
//    frame.size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
//                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                  attributes:@{NSFontAttributeName:btn.titleLabel.font}
//                                     context:nil].size;
//    btn.frame = frame;
//    [btn setExclusiveTouch:YES];
//    [btn bk_addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
//    self.navigationBar.secondLeftBarButton = btn;
//}
//
//- (CGRect)viewBounds
//{
//    return CGRectMake(0, self.view.bounds.origin.y + self.navigationBar.height, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationBar.height);
//}



//@end
