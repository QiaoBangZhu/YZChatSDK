//
//  YZChooseCityViewController.m
//  YChat
//
//  Created by magic on 2020/12/28.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "YZChooseCityViewController.h"
#import "UIColor+ColorExtension.h"
#import "YZCityModel.h"
#import <Masonry/Masonry.h>
#import "MMLayout/UIView+MMLayout.h"
#import "NSString+TUICommon.h"
#import "YZAreaView.h"
#import "YChatNetworkEngine.h"

@interface YZChooseCityViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray* dataArray;
@property (nonatomic, strong)NSMutableArray* groupList;
@property (nonatomic, strong)NSMutableDictionary* dataDict;
@property (nonatomic, strong)UITableView * tableView;
@end

@implementation YZChooseCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择地区";
    self.dataArray = [[NSMutableArray alloc]init];
    [self fetchListData];
}

///选择用户列表
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        _tableView.separatorColor = [UIColor colorWithHex:KCommonSeparatorLineColor];
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor colorWithHex:KCommonLittleLightGrayColor]];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return _tableView;
}

- (void)fetchListData {
    [YChatNetworkEngine requestFetchCityListWithCompletion:^(NSDictionary *result, NSError *error) {
        if (!error) {
            for (NSDictionary* dict in result[@"data"]) {
                YZCityModel* model = [YZCityModel yy_modelWithDictionary:dict];
                [self.dataArray addObject:model];
            }
            NSMutableDictionary *dataDict = @{}.mutableCopy;
            NSMutableArray *groupList = @[].mutableCopy;
            NSMutableArray *nonameList = @[].mutableCopy;
            for (YZCityModel *cityInfo in self.dataArray) {
                NSString *group = [[cityInfo.city firstPinYin] uppercaseString];
                if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
                    [nonameList addObject:cityInfo];
                    continue;
                }
                NSMutableArray *list = [dataDict objectForKey:group];
                if (!list) {
                    list = @[].mutableCopy;
                    dataDict[group] = list;
                    [groupList addObject:group];
                }
                [list addObject:cityInfo];
            }
            
            [groupList sortUsingSelector:@selector(localizedStandardCompare:)];
            if (nonameList.count) {
                [groupList addObject:@"#"];
                dataDict[@"#"] = nonameList;
            }
            for (NSMutableArray *list in [dataDict allValues]) {
                [list sortUsingSelector:@selector(compare:)];
            }

            self.groupList = groupList;
            self.dataDict = dataDict;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groupList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *group = self.groupList[section];
    NSArray *list = self.dataDict[group];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.section < [self.groupList count]) {
        NSString *group = self.groupList[indexPath.section];
        NSArray *list = self.dataDict[group];
        YZCityModel* city = list[indexPath.row];
        cell.textLabel.text = city.city;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#define TEXT_TAG 1
    static NSString *headerViewId = @"ContactDrawerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewId];
    if (!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewId];
        headerView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        
        UIView* leftView = [[UIView alloc]init];
        [headerView addSubview:leftView];
        leftView.backgroundColor = [UIColor colorWithHex:KCommonBackgroundColor];
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.tag = TEXT_TAG;
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.textColor = [UIColor colorWithHex:KCommonBlackColor];
        [headerView addSubview:textLabel];
        textLabel.mm_fill().mm_left(26);
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *label = [headerView viewWithTag:TEXT_TAG];
    label.text = self.groupList[section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray arrayWithObject:@""];
    [array addObjectsFromArray:self.groupList];
    return array;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES
     ];
    
    NSString *group = self.groupList[indexPath.section];
    NSArray *list = self.dataDict[group];
    YZCityModel* city = list[indexPath.row];
    
    YZAreaView* sheet = [YZAreaView showActionSheet:city.city AreaName:city.area];
    [sheet setFunction:^(YZAreaView * _Nonnull actionSheet, NSInteger index) {
        NSString* s = city.area[index];
        NSString* selectedCity = [NSString stringWithFormat:@"%@ %@",city.city,s];
        self.finishBlock(selectedCity);
        [self.navigationController popViewControllerAnimated:true];
    }];
}





@end
