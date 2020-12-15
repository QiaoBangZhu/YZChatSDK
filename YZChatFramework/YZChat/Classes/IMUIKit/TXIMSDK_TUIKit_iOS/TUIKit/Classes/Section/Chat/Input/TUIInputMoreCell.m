//
//  TMoreCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIInputMoreCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "CommonConstant.h"

static TUIInputMoreCellData *TUI_Photo_MoreCell;
static TUIInputMoreCellData *TUI_Picture_MoreCell;
static TUIInputMoreCellData *TUI_Video_MoreCell;
static TUIInputMoreCellData *TUI_File_MoreCell;
static TUIInputMoreCellData *TUI_VideoCall_MoreCell;
static TUIInputMoreCellData *TUI_AudioCall_MoreCell;
static TUIInputMoreCellData *TUI_GroupLivePlay_MoreCell;
static TUIInputMoreCellData *TUI_Location_MoreCell;

@implementation TUIInputMoreCellData



+ (TUIInputMoreCellData *)pictureData
{
    if (!TUI_Picture_MoreCell) {
        TUI_Picture_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Picture_MoreCell.title = @"拍照";
        TUI_Picture_MoreCell.image = YZChatResource(@"more_camera");

    }
    return TUI_Picture_MoreCell;
}

+ (void)setPictureData:(TUIInputMoreCellData *)cameraData
{
    TUI_Picture_MoreCell = cameraData;
}

+ (TUIInputMoreCellData *)photoData
{
    if (!TUI_Photo_MoreCell) {
        TUI_Photo_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Photo_MoreCell.title = @"相册";
        TUI_Photo_MoreCell.image = YZChatResource(@"more_picture");
    }
    return TUI_Photo_MoreCell;
}

+ (void)setPhotoData:(TUIInputMoreCellData *)pictureData
{
    TUI_Photo_MoreCell = pictureData;
}

+ (TUIInputMoreCellData *)videoData
{
    if (!TUI_Video_MoreCell) {
        TUI_Video_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Video_MoreCell.title = @"摄像";
        TUI_Video_MoreCell.image = YZChatResource(@"more_video") ;
    }
    return TUI_Video_MoreCell;
}

+ (void)setVideoData:(TUIInputMoreCellData *)videoData
{
    TUI_Video_MoreCell = videoData;
}

+ (TUIInputMoreCellData *)fileData
{
    if (!TUI_File_MoreCell) {
        TUI_File_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_File_MoreCell.title = @"文件";
        TUI_File_MoreCell.image = YZChatResource(@"more_file") ;
    }
    return TUI_File_MoreCell;
}

+ (void)setFileData:(TUIInputMoreCellData *)fileData
{
    TUI_File_MoreCell = fileData;
}

+ (TUIInputMoreCellData *)videoCallData {
    if (!TUI_VideoCall_MoreCell) {
        TUI_VideoCall_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_VideoCall_MoreCell.title = @"视频通话";
        TUI_VideoCall_MoreCell.image = YZChatResource(@"more_video_call");
    }
    return TUI_VideoCall_MoreCell;
}

+ (void)setVideoCallData:(TUIInputMoreCellData *)videoCallData
{
    TUI_VideoCall_MoreCell = videoCallData;
}

+ (TUIInputMoreCellData *)audioCallData {
    if (!TUI_AudioCall_MoreCell) {
        TUI_AudioCall_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_AudioCall_MoreCell.title = @"语音通话";
        TUI_AudioCall_MoreCell.image = YZChatResource(@"more_voice_call");
    }
    return TUI_AudioCall_MoreCell;
}

+ (void)setAudioCallData:(TUIInputMoreCellData *)audioCallData
{
    TUI_AudioCall_MoreCell = audioCallData;
}

+ (TUIInputMoreCellData *)groupLivePalyData {
    if (!TUI_GroupLivePlay_MoreCell) {
        TUI_GroupLivePlay_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_GroupLivePlay_MoreCell.title = @"群直播";
        TUI_GroupLivePlay_MoreCell.image = [UIImage tk_imageNamed:@"more_group_live"];
    }
    return TUI_GroupLivePlay_MoreCell;
}

+ (void)setGroupLivePalyData:(TUIInputMoreCellData *)groupLivePalyData {
    TUI_GroupLivePlay_MoreCell = groupLivePalyData;
}

+ (TUIInputMoreCellData *)locationData {
    if (!TUI_Location_MoreCell) {
        TUI_Location_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Location_MoreCell.title = @"发送位置";
        TUI_Location_MoreCell.image = YZChatResource(@"more_location");
    }
    return TUI_Location_MoreCell;
}

+ (void)setLocationData:(TUIInputMoreCellData *)locationData
{
    TUI_Location_MoreCell = locationData;
}

@end

@implementation TUIInputMoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:11]];
    [_title setTextColor:[UIColor colorWithRed:110/255.0 green:110/255.0 blue:110/255.0 alpha:1.0]];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)fillWithData:(TUIInputMoreCellData *)data
{
    //set data
    _data = data;
    _image.image = data.image;
    [_title setText:data.title];
    //update layout
//    CGSize menuSize = TMoreCell_Image_Size;
    _image.frame = CGRectMake(0, 0, 48, 48);
    _title.frame = CGRectMake(0, _image.frame.origin.y + _image.frame.size.height, _image.frame.size.width, 25);
}

+ (CGSize)getSize
{
//    CGSize menuSize = TMoreCell_Image_Size;
    return CGSizeMake(48, 48 + 25);
}
@end
