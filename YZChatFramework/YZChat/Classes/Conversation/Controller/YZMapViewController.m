//
//  YZMapViewController.m
//  YChat
//
//  Created by magic on 2020/11/10.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MKMapView+ZoomLevel.h"

#import "YZMapViewController.h"
#import <Masonry/Masonry.h>
#import "YZMapListTableViewCell.h"
#import "CommonConstant.h"
#import "UIColor+ColorExtension.h"
#import "CIGAMKit.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "CommonConstant.h"
#import "NSBundle+YZBundle.h"

static NSString *annotationIdentifier = @"annotationIdentifier";

@interface YZMapViewController ()<UITableViewDelegate, UITableViewDataSource,CIGAMKeyboardManagerDelegate,AMapSearchDelegate,UISearchBarDelegate, MKMapViewDelegate>

@property (nonatomic, strong)UITableView    * tableView;
@property (nonatomic, strong)NSMutableArray * addressList;
@property (nonatomic, strong)MKMapView      * mapView;
@property (nonatomic, strong)UIView         * bottomView;
@property (nonatomic, strong)CIGAMKeyboardManager *keyboardManager;
@property (nonatomic, strong)CIGAMSearchBar  * searchBar;
@property (nonatomic, strong)CIGAMButton     * backUserLocationBtn;
@property (nonatomic, strong)UIButton       * doneBtn;

@property (nonatomic, assign)CLLocationCoordinate2D userLocation;
@property (nonatomic, strong)UIImageView       *lockedPointView;
@property (nonatomic, strong)MKPointAnnotation *pointAnnotation;
@property (nonatomic, strong)AMapPOI           *     selectedPOI;
@property (nonatomic, strong)AMapSearchAPI     *     search;
@property (nonatomic, strong)NSMutableArray    <AMapPOI *> *pois;
@property (nonatomic, strong)UIView            *     locationInfoContentView;
@property (nonatomic, strong)UILabel           *     nameLabel;
@property (nonatomic, strong)UILabel           *     addressLabel;
@property (nonatomic ,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic, assign)BOOL isSearching;

@property (nonatomic, strong)CLLocationManager  *locationManager;

@end

@implementation YZMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"位置";
    [self setupView];
    [self makeConstraint];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager requestWhenInUseAuthorization];
    }
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

    [self.lockedPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.mapView);
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
    [self.view addSubview: self.lockedPointView];
    
    [self.view addSubview:self.backUserLocationBtn];
    [self.view addSubview:self.bottomView];
    
    [self.searchBar sizeToFit];
    [self.bottomView addSubview:self.searchBar];
    [self.bottomView addSubview:self.tableView];

    self.keyboardManager = [[CIGAMKeyboardManager alloc]initWithDelegate:self];
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
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        _doneBtn.enabled = false;
    }
    return _doneBtn;
}


-(MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc]initWithFrame: self.view.frame];
        _mapView.zoomLevel = 15;
        _mapView.rotateEnabled = false;
//        _mapView.rotateCameraEnabled = false;
        _mapView.showsUserLocation = YES;
        _mapView.showsCompass = NO;
        _mapView.delegate = self;
    }
    return _mapView;
}

- (CIGAMButton *)backUserLocationBtn {
    if (!_backUserLocationBtn) {
        _backUserLocationBtn = [CIGAMButton buttonWithType:UIButtonTypeCustom];
        _backUserLocationBtn.cigam_outsideEdge = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_backUserLocationBtn setImage:YZChatResource(@"schedule_icon_map_back_user_location") forState:UIControlStateNormal];
        [_backUserLocationBtn addTarget:self action:@selector(backUserLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backUserLocationBtn;
}

- (UIImageView *)lockedPointView {
    if (!_lockedPointView) {
        _lockedPointView = [[UIImageView alloc] initWithImage: YZChatResource(@"map_bubble")];
    }

    return _lockedPointView;
}

- (MKPointAnnotation *)pointAnnotation {
    if (!_pointAnnotation) {
        _pointAnnotation = [[MKPointAnnotation alloc] init];
    }

    return _pointAnnotation;
}

- (AMapSearchAPI *)search {
    if (!_search) {
        _search = [[AMapSearchAPI alloc]init];
        _search.delegate = self;
    }
    return _search;
}

- (CIGAMSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[CIGAMSearchBar alloc]init];
        _searchBar.backgroundImage = [UIImage cigam_imageWithColor:[UIColor colorWithHex:KCommonBackgroundColor]];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索地点";
    }
    return _searchBar;
}

- (void)setIsSearching:(BOOL)isSearching {
    _isSearching = isSearching;
    if (isSearching) {
        [self.mapView addAnnotation: self.pointAnnotation];
        self.lockedPointView.hidden = YES;
    } else {
        [self.mapView removeAnnotation: self.pointAnnotation];
        self.lockedPointView.hidden = NO;
    }
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    _selectedIndexPath = selectedIndexPath;
    if (selectedIndexPath && selectedIndexPath.row < _pois.count) {
        self.selectedPOI = self.pois[selectedIndexPath.row];
        self.doneBtn.enabled = YES;
    } else {
        self.doneBtn.enabled = NO;
    }
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
        [_tableView registerClass:[YZMapListTableViewCell class] forCellReuseIdentifier:@"cell"];
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
    YZMapListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[YZMapListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([self.pois count] > 0) {
        AMapPOI* poi = self.pois[indexPath.row];
        cell.titleLabel.text =  poi.name;
        cell.subTitleLabel.text = poi.address;
        
        if (indexPath == self.selectedIndexPath) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
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
        self.isSearching = self.searchBar.text.length > 0;
        [self.tableView reloadData];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(selectedPOI.location.latitude, selectedPOI.location.longitude);
        self.pointAnnotation.coordinate = coordinate;
        [self.mapView setCenterCoordinate:coordinate animated:true];
    }
}

- (void)keyboardWillShowWithUserInfo:(CIGAMKeyboardUserInfo *)keyboardUserInfo {
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

- (void)keyboardWillHideWithUserInfo:(CIGAMKeyboardUserInfo *)keyboardUserInfo {
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
    self.selectedIndexPath = _selectedIndexPath;
    [self.tableView reloadData];
    [self.tableView cigam_scrollToTopAnimated:true];
}

-(void)backUserLocation {
    _selectedPOI = nil;
    [self searchAmapPOIAroundSearchRequest:_userLocation];
    [self.mapView setCenterCoordinate: _userLocation zoomLevel: 15 animated: YES];
    if (!self.isSearching) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self.tableView cigam_scrollToTopAnimated: YES];
}

#pragma mark mapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation.location) {
        if (self.userLocation.latitude == 0 && self.userLocation.longitude == 0) {
            self.userLocation = userLocation.location.coordinate;
            [self backUserLocation];
        }
        _userLocation = userLocation.location.coordinate;
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if (self.userLocation.latitude == 0 && self.userLocation.longitude == 0) {
        _userLocation = CLLocationCoordinate2DMake(39.909604, 116.397228);
        [self backUserLocation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.isSearching) {
        return;
    }
    [self.mapView removeAnnotations:self.mapView.annotations];

    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    [self searchAmapPOIAroundSearchRequest:centerCoordinate];

    [self.tableView cigam_scrollToTop];

    if (!self.isSearching) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: @"point"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"point"];
        }
        annotationView.annotation = annotation;
        UIImage* image = YZChatResource(@"map_bubble");
        annotationView.image = image;
        return annotationView;
    }

    return nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        if (!self.isSearching) {
            self.selectedIndexPath = nil;
        }
        self.isSearching = YES;
        [self searchLocationWithText:searchBar.text];
    }else {
        self.isSearching = NO;
        [self.pois removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    if ([searchBar.text length] > 0) {
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

- (void)searchAmapPOIAroundSearchRequest:(CLLocationCoordinate2D)coordinate {
    if (![self.searchBar isFirstResponder] && [self.searchBar.text length] == 0) {
        AMapPOIAroundSearchRequest* request = [[AMapPOIAroundSearchRequest alloc]init];
        request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        request.sortrule = 0;
        [self.search AMapPOIAroundSearch:request];
    }
}

@end
