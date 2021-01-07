//
//  YZAreaView.h
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YZAreaView;

typedef void (^YZAreaViewFunction)(YZAreaView *actionSheet,NSInteger index);

@interface YZAreaView : UIView
@property(nonatomic,copy)YZAreaViewFunction function;
@property(nonatomic,strong,readonly)NSArray *titlesArray;

+(instancetype)showActionSheet:(NSString *)title AreaName:(NSArray *)areaNames;

-(instancetype)initWithFrame:(CGRect)frame areaTitles:(NSArray *)titles cityName:(NSString*)city;

@end

NS_ASSUME_NONNULL_END
