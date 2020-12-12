//
//  MapInfoViewController.m
//  YChat
//
//  Created by magic on 2020/11/16.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "MapInfoViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <Masonry/Masonry.h>
#import "UIColor+ColorExtension.h"

@interface MapInfoViewController ()<MAMapViewDelegate>
@property (nonatomic, strong)MAMapView          * mapView;
@property (nonatomic, strong)UIView             * locationInfoContentView;
@property (nonatomic, strong)UILabel            * nameLabel;
@property (nonatomic, strong)UILabel            * addressLabel;
@property (nonatomic, strong)MAPointAnnotation  * mapAnnotation;
@property (nonatomic, assign)BOOL                 isFirstLoad;
@end

@implementation MapInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"位置信息";
    [self setupView];
    [self.mapView addAnnotation:self.mapAnnotation];
}

- (void)setLocationData:(LocationMessageCellData *)locationData {
    _locationData = locationData;
    
    if ([locationData.text length] > 0 && [locationData.text containsString:@"##"]) {
        NSArray* textArray = [locationData.text componentsSeparatedByString:@"##"];
        if ([textArray count] == 2) {
            self.nameLabel.text = textArray[0];
            self.addressLabel.text = textArray[1];
        }
    }
}

- (void)setupView {
    [self.view addSubview:self.mapView];
    [AMapServices sharedServices].enableHTTPS = YES;
    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.locationInfoContentView];
    [self.locationInfoContentView addSubview:self.addressLabel];
    [self.locationInfoContentView addSubview:self.nameLabel];
    
    [self.locationInfoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@80);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.equalTo(@12);
        make.right.equalTo(@-16);
    }];

    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(@-16);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(8);
        make.height.equalTo(@12);
    }];
    
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(@-80);
    }];
}

- (MAMapView *)mapView {
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

-(UIView *)locationInfoContentView {
    if (!_locationInfoContentView) {
        _locationInfoContentView = [[UIView alloc]init];
        _locationInfoContentView.backgroundColor = [UIColor whiteColor];
        _locationInfoContentView.hidden = NO;
    }
    return _locationInfoContentView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor colorWithHex:KCommonBlackTextColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc]init];
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.textColor = [UIColor colorWithHex:KCommonBubbleTextGrayColor];
    }
    return _addressLabel;
}

#pragma mark mapViewDelegate

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation && userLocation.location != nil) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.locationData.latitude, self.locationData.longitude);
        self.mapAnnotation.lockedToScreen = false;
        self.mapAnnotation.coordinate = coordinate;
        [self.mapView setCenterCoordinate:coordinate animated:true];
    }
}

/// 定位失败
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.909604, 116.397228);
    [self.mapView setCenterCoordinate:coordinate animated:true];
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated wasUserAction:(BOOL)wasUserAction {
    if (wasUserAction) {
//        [self searchAmapPOIAroundSearchRequest:mapView.centerCoordinate];
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    MAPointAnnotation* anno = (MAPointAnnotation*)annotation;
    if (anno == self.mapAnnotation) {
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationIdentifier"];
        if (!annotationView) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotationIdentifier"];
        }
        annotationView.annotation = annotation;
        UIImage* image = [UIImage imageNamed:@"map_bubble"];
        annotationView.image = image;
        annotationView.centerOffset = CGPointMake(0, -image.size.height/2);
        return annotationView;
    }
    return  nil;
}

- (MAPointAnnotation*)mapAnnotation {
    if (!_mapAnnotation) {
        _mapAnnotation = [[MAPointAnnotation alloc]init];
    }
    return _mapAnnotation;
}


@end
