//
//  YPopCell.m
//  YChat
//
//  Created by magic on 2020/10/3.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YPopCell.h"
#import <Masonry/Masonry.h>

@implementation YPopCellData

@end

@implementation YPopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];

    _title = [[UILabel alloc]init];
    _title.font = [UIFont systemFontOfSize:15];
    _title.textColor = [UIColor blackColor];
    [self addSubview:_title];
    
    self.separatorInset = UIEdgeInsetsZero;
    
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@-16);
        make.centerY.equalTo(@0);
    }];
}

- (void)setData:(YPopCellData *)data
{
    _title.text = data.title;
}

+ (CGFloat)getHeight
{
    return 44;
}

@end
