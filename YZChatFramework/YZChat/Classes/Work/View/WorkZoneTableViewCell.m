//
//  WorkZoneTableViewCell.m
//  YChat
//
//  Created by magic on 2020/10/4.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "WorkZoneTableViewCell.h"
#import "UIColor+ColorExtension.h"
#import <Masonry/Masonry.h>
#import "WorkZoneModel.h"
#import "AppCollectionViewCell.h"
#import "CommonConstant.h"

@interface WorkZoneTableViewCell() <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray* dataArry;
@end

@implementation WorkZoneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setupView];
        [self makeConstraint];
    }
    return self;
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
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator  = NO;
        [_collectionView registerClass:[AppCollectionViewCell class] forCellWithReuseIdentifier:@"AppCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
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
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.collectionView];
}

- (void)makeConstraint {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@12);
        make.height.equalTo(@22);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@24);
        make.right.equalTo(@-24);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(24);
        make.bottom.equalTo(@-20);
    }];
    
}

- (void)cellData:(WorkZoneModel *)model {
    self.titleLabel.text = model.toolCategory;
    [self.dataArry removeAllObjects];
    [self.dataArry addObjectsFromArray:model.toolDataList];
    [self.collectionView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AppCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AppCollectionViewCell class]) forIndexPath:indexPath];
    
    if(self.dataArry.count){
        AppInfoModel* model = self.dataArry[indexPath.item];
        [cell cellData:model];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArry.count) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItem:)]){
            AppInfoModel* info = self.dataArry[indexPath.item];
            [self.delegate didSelectedItem:info];
        }
    }
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(40,61);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 45;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 24;
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
