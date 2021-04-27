//
//  YzCustomMessageCell.m
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import "YzCustomMessageCell.h"

@implementation YzCustomMessageCell

- (YzCustomMessageView *)customView {
    if (!_customView) {
        _customView = [[self.customViewClass alloc] init];

        [self.container addSubview: _customView];
    }

    return _customView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect containFrame = self.container.frame;
    containFrame.size.height -= 15;
    self.container.frame = containFrame;

    CGRect readReceiptFrame = self.readReceiptLabel.frame;
    readReceiptFrame.origin.y -= 15;
    self.readReceiptLabel.frame = readReceiptFrame;

    containFrame.origin = CGPointZero;
    self.customView.frame = containFrame;
}

@end
