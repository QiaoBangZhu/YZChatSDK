//
//  YzGroupPendencyViewController.h
//  YZChat
//
//  Created by 安笑 on 2021/5/11.
//

#import "CIGAMCommonTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YzGroupPendencyViewModel : NSObject

/**
 *  请求数据列表
 *  该列表中存放的对象类型为 TUIGroupPendencyCellData。
 *  即本数组中存放了当前群所有的待处理请求数据，且本属性为只读，不允许修改。
 */
@property (nonatomic, strong, readonly) NSArray *dataList;

/**
 *  未读计数
 *  即当前群组请求的未处理数目。
 */
@property (nonatomic, assign, readonly) int unReadCount;

- (instancetype)initWithGroupId:(nullable NSString *)groupId;

@end

@interface YzGroupPendencyViewController : CIGAMCommonTableViewController

- (instancetype)initWithViewModel:(YzGroupPendencyViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
