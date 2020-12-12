//
//  TransferGrpOwnerViewController.h
//  YChat
//
//  Created by magic on 2020/10/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

//@import ImSDK;
#import <ImSDKForiOS/ImSDK.h>

@interface TransferGrpOwnerViewController : UIViewController
@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)V2TIMGroupInfo * groupInfo;
@property (nonatomic, assign)BOOL finished;

@end


