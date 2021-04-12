//
//  YzCustomMessageCell.m
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import "YzCustomMessageCell.h"

#import <Masonry/Masonry.h>

@implementation YzCustomMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (YzCustomMessageView *)customerView {
    if (!_customerView) {
        _customerView = [[self.customerViewClass alloc] init];

        [self.container addSubview: _customerView];
        [_customerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@7);
            make.bottom.equalTo(@-8);
            make.leading.trailing.equalTo(@0);
        }];
    }

    return _customerView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//
//    CGRect containFrame = self.container.frame;
//    containFrame.size.height -= 15;
//    self.container.frame = containFrame;
//
//    CGRect readReceiptFrame = self.readReceiptLabel.frame;
//    readReceiptFrame.origin.y -= 15;
//    self.readReceiptLabel.frame = readReceiptFrame;
}

@end
