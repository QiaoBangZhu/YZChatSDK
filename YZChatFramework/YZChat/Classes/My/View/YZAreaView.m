//
//  YZAreaView.m
//  YChat
//
//  Created by magic on 2020/12/29.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZAreaView.h"
#import "UIColor+ColorExtension.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"


#define ROWHEIGHT (48.0f)
#define HEADHEIGHT (40)

@interface YZAreaView()<UITableViewDelegate,UITableViewDataSource> {
    UIButton *outSetButton;
    UILabel*titleLabel;
    UITableView *areasTableView;
    UIButton* closeBtn;
}
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, copy)NSString* title;
@end

@implementation YZAreaView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor redColor];
}

+ (instancetype)showActionSheet:(NSString *)title AreaName:(NSArray *)areaNames
{
    YZAreaView *actionSheet = [[YZAreaView alloc]initWithFrame:CGRectZero areaTitles:areaNames cityName:title];
    [actionSheet setAlpha:0.0f];
    [actionSheet showAnimation];
    return actionSheet;
}

-(instancetype)initWithFrame:(CGRect)frame areaTitles:(NSArray *)titles cityName:(NSString*)city
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.15f]];
        outSetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [outSetButton addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:outSetButton];
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectZero];
        [self addSubview:_bottomView];
        
        areasTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [areasTableView setDelegate:self];
        [areasTableView setDataSource:self];
        [areasTableView setSeparatorColor:[UIColor colorWithHex:KCommonSepareteLineColor]];
        areasTableView.tableFooterView = [UIView new];
        [_bottomView addSubview:areasTableView];

        _titlesArray = [titles copy];
        _title = [city copy];
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self setupViewRelation];
    return self;
}
-(void)showAnimation
{
    [UIView animateWithDuration:0.26f animations:^{
        [self setAlpha:1.0f];
    }];
}

#pragma mark tableView代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROWHEIGHT;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titlesArray count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell.textLabel setText:[self.titlesArray objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!section) {
        return 40;
    }
    return .1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!section) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
        view.backgroundColor = [UIColor colorWithHex:kCommonBlueTextColor];
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(KScreenWidth-16-30, 0, 40, 40);
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [closeBtn setTitle:@"x" forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view addSubview:closeBtn];
        
        UIImageView* location =  [[UIImageView alloc]initWithFrame:CGRectMake(16,12, 16, 16)];
        location.image = YZChatResource(@"icon_location");
        [view addSubview:location];
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 200, 40)];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = _title;
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [view addSubview:titleLabel];
        
        return view;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.function != NULL)
    {
        typeof(self) __weak weakself = self;
        self.function(weakself,indexPath.row);
    }
    [self disMiss];
}

-(void)disMiss
{
    [UIView animateWithDuration:0.43f animations:^{
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, self.bottomView.frame.origin.y+self.bottomView.frame.size.height, self.bottomView.frame.size.width,self.bottomView.frame.size.height)];
        [self setBackgroundColor:[UIColor clearColor]];
    }completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}
-(void)setupViewRelation
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *width_self = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *height_self = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerX_self = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerY_self = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.superview addConstraints:@[width_self,centerX_self,height_self,centerY_self]];
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat maxTableHeight = self.bounds.size.height-HEADHEIGHT;
    
//    CGFloat needHeight = HEADHEIGHT+ROWHEIGHT*[self.titlesArray count];
    
//    CGFloat realyHeight = MIN(maxTableHeight, needHeight);
    CGFloat realyHeight = KScreenHeight*0.6;

    [_bottomView setFrame:CGRectMake(0.0f,KScreenHeight*0.4, self.bounds.size.width, realyHeight)];
       
    [areasTableView setFrame:CGRectMake(0.0f, 0.0f, _bottomView.bounds.size.width, realyHeight)];
    
    [outSetButton setFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, _bottomView.frame.origin.y)];
    
//    if (maxTableHeight > needHeight)
//    {
//        [areasTableView setScrollEnabled:NO];
//    }
//    else
//    {
//        [areasTableView setScrollEnabled:YES];
//    }
}

@end
