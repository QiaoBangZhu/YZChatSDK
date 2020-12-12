//
//  MapViewController.m
//  YChat
//
//  Created by magic on 2020/11/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "MapViewController.h"
#import <Masonry/Masonry.h>
#import "MapListTableViewCell.h"
#import "CommonConstant.h"
#import "UIColor+ColorExtension.h"
#import <QMUIKit/QMUIKit.h>

#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchKit.h>

static NSString *annotationIdentifier = @"annotationIdentifier";

@interface MapViewController ()<UITableViewDelegate, UITableViewDataSource,QMUIKeyboardManagerDelegate,MAMapViewDelegate,AMapSearchDelegate,UISearchBarDelegate>

@property (nonatomic, strong)UITableView    * tableView;
@property (nonatomic, strong)NSMutableArray * addressList;
@property (nonatomic, strong)MAMapView      * mapView;
@property (nonatomic, strong)UIView         * bottomView;
@property (nonatomic, strong)QMUIKeyboardManager *keyboardManager;
@property (nonatomic, strong)QMUISearchBar  * searchBar;
@property (nonatomic, strong)QMUIButton     * backUserLocationBtn;
@property (nonatomic, strong)UIButton       * doneBtn;

@property (nonatomic, assign)CLLocationCoordinate2D userLocation;
@property (nonatomic, strong)MAPointAnnotation*     mapAnnotation;
@property (nonatomic, strong)AMapPOI          *     selectedPOI;
@property (nonatomic, strong)AMapSearchAPI    *     search;
@property (nonatomic, strong)NSMutableArray   <AMapPOI *> *pois;
@property (nonatomic, strong)UIView           *     locationInfoContentView;
@property (nonatomic, strong)UILabel          *     nameLabel;
@property (nonatomic, strong)UILabel          *     addressLabel;
@property (nonatomic ,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic, assign)BOOL isSearching;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"位置";
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self setupView];
    [self makeConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _keyboardManager.delegateEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _keyboardManager.delegateEnabled = NO;
}

- (void)makeConstraint {
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        make.bottom.equalTo(self.view.mas_centerY);
    }];
    
    [self.backUserLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_centerY).offset(-5);
        make.trailing.equalTo(@-10);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(@0);
        make.top.equalTo(_mapView.mas_bottom).offset(0).priorityMedium();
    }];
    
    CGFloat height = self.searchBar.frame.size.height;
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(@0);
        make.height.equalTo(@(height)).priorityHigh();
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(@0);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
    
}

- (void)setupView {
    [AMapServices sharedServices].enableHTTPS = YES;
    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.backUserLocationBtn];
    [self.view addSubview:self.bottomView];
    
    [self.searchBar sizeToFit];
    [self.bottomView addSubview:self.searchBar];
    [self.bottomView addSubview:self.tableView];

    self.keyboardManager = [[QMUIKeyboardManager alloc]initWithDelegate:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.doneBtn];
}

- (void)confirmAction {
    if (self.locationBlock) {
        if (self.selectedPOI != nil) {
            self.locationBlock(self.selectedPOI.name, self.selectedPOI.address, self.selectedPOI.location.latitude, self.selectedPOI.location.longitude);
        }
    }
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 0, 30, 30);
        [_doneBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        [_doneBtn setTitleColor:[UIColor colorWithHex:KCommonBlackColor] forState:UIControlStateNormal];
        [_doneBtn setTitle:@"确定  " forState:UIControlStateNormal];
        _doneBtn.enabled = false;
    }
    return _doneBtn;
}

-(MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc]init];
        _mapView.zoomLevel = 15;
        _mapView.rotateEnabled = false;
        _mapView.rotateCameraEnabled = false;
        _mapView.showsUserLocation = YES;
        _mapView.showsCompass = NO;
        _mapView.delegate = self;
    }
    return _mapView;
}

- (MAPointAnnotation*)mapAnnotation {
    if (!_mapAnnotation) {
        _mapAnnotation = [[MAPointAnnotation alloc]init];
    }
    return _mapAnnotation;
}

- (QMUIButton *)backUserLocationBtn {
    if (!_backUserLocationBtn) {
        _backUserLocationBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _backUserLocationBtn.qmui_outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_backUserLocationBtn setImage:[UIImage imageNamed:@"schedule_icon_map_back_user_location"] forState:UIControlStateNormal];
        [_backUserLocationBtn addTarget:self action:@selector(configureUserLocationCenter) forControlEvents:UIControlEventTouchUpInside];
        _backUserLocationBtn.hidden = YES;
    }
    return _backUserLocationBtn;
}

- (AMapSearchAPI *)search {
    if (!_search) {
        _search = [[AMapSearchAPI alloc]init];
        _search.delegate = self;
    }
    return _search;
}

- (QMUISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[QMUISearchBar alloc]init];
        _searchBar.backgroundImage = [UIImage qmui_imageWithColor:[UIColor colorWithHex:KCommonBackgroundColor]];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索地点";
    }
    return _searchBar;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[MapListTableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MapListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([self.pois count] > 0) {
        AMapPOI* poi = self.pois[indexPath.row];
        cell.titleLabel.text =  poi.name;
        cell.subTitleLabel.text = poi.address;
        
        if (!_isSearching) {
            if (indexPath == self.selectedIndexPath) {
                self.selectedPOI = poi;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else {
                cell.accessoryType = UITableViewCellAccessoryNone;

            }
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_pois count] > 0) {
        AMapPOI* selectedPOI = self.pois[indexPath.row];
        self.selectedPOI = selectedPOI;
        self.selectedIndexPath = indexPath;
        self.isSearching = NO;
        [self.tableView reloadData];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(selectedPOI.location.latitude, selectedPOI.location.longitude);
        [self.mapView setCenterCoordinate:coordinate animated:true];
    }
}

- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    CGFloat height = _mapView.frame.size.height/2;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:keyboardUserInfo.animationDuration];
    [UIView setAnimationCurve:keyboardUserInfo.animationCurve];
    [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_mapView.mas_bottom).offset(-height).priorityMedium();
    }];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:keyboardUserInfo.animationDuration];
    [UIView setAnimationCurve:keyboardUserInfo.animationCurve];
    [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_mapView.mas_bottom).offset(0).priorityMedium();
    }];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    _pois = [response.pois mutableCopy];
    [self.tableView reloadData];
    [self.tableView qmui_scrollToTopAnimated:true];
}

-(void)configureUserLocationCenter {
    _selectedPOI = nil;
    [self searchAmapPOIAroundSearchRequest:_userLocation];
    if ([self.backUserLocationBtn isHidden]) {
        [self.mapView addAnnotation:self.mapAnnotation];
    }
    _backUserLocationBtn.hidden = NO;
    [self.mapView setCenterCoordinate:_userLocation animated:true];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView qmui_scrollToTopAnimated:true];
}

-(void)setSelectedPOI:(AMapPOI *)selectedPOI {
    _selectedPOI = selectedPOI;
    if (selectedPOI) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(selectedPOI.location.latitude, selectedPOI.location.longitude);
        _doneBtn.enabled = true;
        self.mapAnnotation.lockedToScreen = false;
        self.mapAnnotation.coordinate = coordinate;
    }else {
        _doneBtn.enabled = false;
        self.mapAnnotation.lockedToScreen = true;
        self.mapAnnotation.lockedScreenPoint = CGPointMake(_mapView.frame.size.width / 2, _mapView.frame.size.height / 2);
    }
}

#pragma mark mapViewDelegate

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation && userLocation.location != nil) {
        if (self.userLocation.latitude == 0 && self.userLocation.longitude == 0) {
            self.userLocation = userLocation.location.coordinate;
            [self configureUserLocationCenter];
        }
        _userLocation = userLocation.location.coordinate;
    }
}

/// 定位失败
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (self.userLocation.latitude == 0 && self.userLocation.longitude == 0) {
        _userLocation = CLLocationCoordinate2DMake(39.909604, 116.397228);
        [self configureUserLocationCenter];
    }
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated wasUserAction:(BOOL)wasUserAction {
    if (wasUserAction) {
        [self searchAmapPOIAroundSearchRequest:mapView.centerCoordinate];
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated wasUserAction:(BOOL)wasUserAction {
    if (wasUserAction) {
        
        if (self.isSearching) {
            return;
        }
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        CLLocationCoordinate2D centerCoordinate = mapView.region.center;
        self.mapAnnotation.coordinate = centerCoordinate;
        [self.mapView addAnnotation:self.mapAnnotation];
        [self searchAmapPOIAroundSearchRequest:centerCoordinate];
        
        [self.tableView qmui_scrollToTop];

        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    }
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    MAPointAnnotation* anno = (MAPointAnnotation*)annotation;
    if (anno == self.mapAnnotation) {
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!annotationView) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        annotationView.annotation = annotation;
        UIImage* image = [UIImage imageNamed:@"map_bubble"];
        annotationView.image = image;
        annotationView.centerOffset = CGPointMake(0, -image.size.height/2);
        return annotationView;
    }
    return  nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        self.isSearching = YES;
        [self searchLocationWithText:searchBar.text];
    }else {
        [self.pois removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    if ([searchBar.text length] > 0) {
        self.isSearching = NO;
        [self searchLocationWithText:searchBar.text];
        [self.searchBar resignFirstResponder];
    }
}

- (void)searchLocationWithText:(NSString *)searchText {
    AMapPOIKeywordsSearchRequest * request =  [AMapPOIKeywordsSearchRequest alloc];
    CLLocationCoordinate2D location = self.userLocation;
    if (self.userLocation.latitude == 0 && self.userLocation.longitude == 0) {
        location = CLLocationCoordinate2DMake(39.909604, 116.397228);
    }
    request.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    request.keywords = searchText;
    request.sortrule = 0;
    [self.search AMapPOIKeywordsSearch:request];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
    self.isSearching = NO;
}

- (void)searchAmapPOIAroundSearchRequest:(CLLocationCoordinate2D)coordinate {
    if (![self.searchBar isFirstResponder] && [self.searchBar.text length] == 0) {
        AMapPOIAroundSearchRequest* request = [[AMapPOIAroundSearchRequest alloc]init];
        request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        request.sortrule = 0;
        [self.search AMapPOIAroundSearch:request];
    }
}

@end
