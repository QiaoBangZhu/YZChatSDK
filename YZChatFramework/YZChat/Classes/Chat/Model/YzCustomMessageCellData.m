//
//  YzCustomMessageCellData.m
//  YZChat
//
//  Created by 安笑 on 2021/4/12.
//

#import "YzCustomMessageCellData.h"
#import "CommonConstant.h"

@implementation YzCustomMessageCellData

- (instancetype)initWithMessage:(V2TIMMessage *)message {
    self = [super initWithDirection: message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    if (self) {
        self.showName = (message.groupID.length > 0) && !message.isSelf;
        self.innerMessage = message;
        self.msgID = message.msgID;
        self.identifier = message.sender;
        if (message.nameCard.length > 0) {
            self.name = message.nameCard;
        } else if (message.nickName.length > 0){
            self.name = message.nickName;
        }
        self.avatarUrl = [NSURL URLWithString: message.faceURL];

        switch (message.status) {
            case V2TIM_MSG_STATUS_SEND_SUCC:
                self.status = Msg_Status_Succ;
                break;
            case V2TIM_MSG_STATUS_SEND_FAIL:
                self.status = Msg_Status_Fail;
                break;
            case V2TIM_MSG_STATUS_SENDING:
                self.status = Msg_Status_Sending_2;
                break;
            default:
                break;
        }
    }

    return self;
}

- (NSString *)reuseId {
    return self.customMessageData.reuseIdentifier;
}

- (CGSize)contentSize {
    CGSize size = [self.customMessageData contentSize];
    return CGSizeMake(size.width, size.height + 15);
}

@end
