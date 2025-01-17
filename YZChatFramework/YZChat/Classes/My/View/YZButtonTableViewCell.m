//
//  ButtonTableViewCell.m
//  YChat
//
//  Created by magic on 2020/9/30.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZButtonTableViewCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import "UIColor+ColorExtension.h"

@implementation ButtonCellData

- (CGFloat)heightOfWidth:(CGFloat)width {
    return 50;
}

@end

@implementation YZButtonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_button];
    [self setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.changeColorWhenTouched = YES;
    
    _line = [[UIView alloc]initWithFrame:CGRectMake(0, 49, Screen_Width, 1)];
    _line.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    _line.hidden = YES;
    [_button addSubview:_line];
}


- (void)fillWithData:(ButtonCellData *)data
{
    [super fillWithData:data];
    self.buttonData = data;
    [_button setTitle:data.title forState:UIControlStateNormal];
    _line.hidden = !data.hasLine;
    switch (data.style) {
        case BtnGreen: {
            [_button.titleLabel setTextColor:[UIColor d_colorWithColorLight:[UIColor whiteColor] dark:RGB(180, 180, 180)]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:RGB(28, 185, 31) dark:RGB(35, 35, 35)];
            //对于背景色为绿色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:[UIColor d_colorWithColorLight:RGB(23, 154, 26) dark:RGB(47, 47, 47)]] forState:UIControlStateHighlighted];
        }
            break;
        case BtnBlueText: {
            [_button.titleLabel setTextColor:[UIColor blackColor]];
            [_button setTitleColor:[UIColor colorWithHex:kCommonBlueTextColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor whiteColor];
            //对于原本白色背景色的按钮，高亮颜色保持和白色 cell 统一。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:self.colorWhenTouched] forState:UIControlStateHighlighted];
        }
            break;
        case BtnRedText: {
            [_button.titleLabel setTextColor:[UIColor systemRedColor]];
            [_button setTitleColor:[UIColor d_systemRedColor] forState:UIControlStateNormal];
            _button.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
            //对于原本白色背景色的按钮，高亮颜色保持和白色 cell 统一。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:self.colorWhenTouched] forState:UIControlStateHighlighted];

            break;
        }
        case BtnBlue:{
            [_button.titleLabel setTextColor:[UIColor d_colorWithColorLight:[UIColor whiteColor] dark:RGB(180, 180, 180)]];
            _button.backgroundColor = [UIColor d_colorWithColorLight:RGB(30, 144, 255) dark:RGB(35, 35, 35)];
            //对于背景色为蓝色的按钮，高亮颜色比原本略深（原本的5/6）。由于无法直接设置高亮时的背景色，所以高亮背景色的变化通过生成并设置纯色图片来实现。
            [_button setBackgroundImage:[self imageWithColor:[UIColor d_colorWithColorLight:RGB(25, 120, 213) dark:RGB(47, 47, 47)]] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _button.mm_width(Screen_Width)
    .mm_height(self.mm_h)
    .mm_left(0);
    
}

- (void)onClick:(UIButton *)sender
{
    if (self.buttonData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.buttonData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.buttonData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (subview != self.contentView) {
        [subview removeFromSuperview];
    }
}

//本函数实现了生成纯色背景的功能，从而配合 setBackgroundImage: forState: 来实现高亮时纯色按钮的点击反馈。
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


@end
