//
//  YzCustomMessageView.m
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import "YzCustomMessageView.h"

@implementation YzCustomMessageData

- (CGSize)contentSize {
    return CGSizeZero;
}

@end

@implementation YzCustomMessageView

- (void)fillWithData:(YzCustomMessageData *)data {
    _data = data;
}

@end
