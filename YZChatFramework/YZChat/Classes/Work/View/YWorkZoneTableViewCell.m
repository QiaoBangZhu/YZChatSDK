//
//  WorkZoneTableViewCell.m
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YWorkZoneTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "YWorkZoneModel.h"
#import "YAppCollectionViewCell.h"
#import "CommonConstant.h"

@interface YWorkZoneTableViewCell() <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIView* bgView;
@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray* dataArry;
@end

@implementation YWorkZoneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setupView];
        [self makeConstraint];
    }
    return self;
}

- (UIView * )bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel  = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.scrollEnabled = false;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator  = NO;
        [_collectionView registerClass:[YAppCollectionViewCell class] forCellWithReuseIdentifier:@"AppCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor  whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSMutableArray *)dataArry {
    if (!_dataArry) {
        _dataArry = [[NSMutableArray alloc]init];
    }
    return _dataArry;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    [self configureShadow];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.collectionView];
}

- (void)makeConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@6);
        make.top.equalTo(@7);
        make.right.equalTo(@-7);
        make.bottom.equalTo(@-7);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@12);
        make.height.equalTo(@22);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@22);
        make.right.equalTo(@-22);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(22);
        make.bottom.equalTo(@-20);
    }];
    
}

- (void)cellData:(YWorkZoneModel *)model {
    self.titleLabel.text = model.toolCategory;
    [self.dataArry removeAllObjects];
    [self.dataArry addObjectsFromArray:model.toolDataList];
    [self.collectionView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YAppCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YAppCollectionViewCell class]) forIndexPath:indexPath];
    
    if(self.dataArry.count){
        YAppInfoModel* model = self.dataArry[indexPath.item];
        [cell cellData:model];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArry.count) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItem:)]){
            YAppInfoModel* info = self.dataArry[indexPath.item];
            [self.delegate didSelectedItem:info];
        }
    }
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(44,61);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 41;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 24;
}

- (void)configureShadow {
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.shadowColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:92/255.0 alpha:0.13].CGColor;
    self.bgView.layer.shadowOffset = CGSizeMake(3,3);
    self.bgView.layer.shadowOpacity = 1;
    self.bgView.layer.shadowRadius = 5;

    UIView *shadowView = [[UIView alloc] init];
    [self.contentView addSubview:shadowView];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@6);
        make.top.equalTo(@7);
        make.right.equalTo(@-7);
        make.bottom.equalTo(@-7);
    }];
    
    shadowView.layer.backgroundColor = [UIColor colorWithRed:251/255.0 green:252/255.0 blue:255/255.0 alpha:1.0].CGColor;
    shadowView.layer.cornerRadius = 10;
    shadowView.layer.shadowColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.88].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(-3,-3);
    shadowView.layer.shadowOpacity = 1;
    shadowView.layer.shadowRadius = 6;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
