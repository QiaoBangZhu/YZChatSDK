//
//  YzCustomMessageView.m
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import "YzCustomMessageView.h"

#import <YYModel/YYModel.h>

@implementation YzCustomMessageData

- (NSString *)reuseIdentifier {
    return  @"";
}

- (CGSize)contentSize {
    return CGSizeZero;
}

- (NSData *)data {
    return [self yy_modelToJSONData];
}

@end

@implementation YzCustomMessageView

- (void)fillWithData:(YzCustomMessageData *)data {
    _data = data;
}

@end
