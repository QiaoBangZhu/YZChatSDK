//
//  YZMapInfoViewController.m
//  YChat
//
//  Created by magic on 2020/11/16.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "YZMapInfoViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+ColorExtension.h"
#import "NSBundle+YZBundle.h"
#import "CommonConstant.h"
#import "MKMapView+ZoomLevel.h"

@interface YZMapInfoViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong)MKMapView          *mapView;
@property (nonatomic, strong)UIView             *locationInfoContentView;
@property (nonatomic, strong)UILabel            *nameLabel;
@property (nonatomic, strong)UILabel            *addressLabel;
@property (nonatomic, strong)CLLocationManager  *locationManager;

@end

@implementation YZMapInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"位置信息";
    [self setupView];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [_locationManager requestWhenInUseAuthorization];
    }

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_locationData.latitude, _locationData.longitude);
    [self.mapView setCenterCoordinate: center zoomLevel: 15 animated: YES];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = center;
    [self.mapView addAnnotation: annotation];
}

- (void)setLocationData:(YZLocationMessageCellData *)locationData {
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

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame: self.view.frame];
        _mapView.rotateEnabled = NO;
        _mapView.showsUserLocation = YES;
        _mapView.showsCompass = NO;
        _mapView.showsUserLocation = YES;
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass: [MKPointAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: @"share"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"share"];
        }
        annotationView.annotation = annotation;
        UIImage* image = YZChatResource(@"map_bubble");
        annotationView.image = image;
        return annotationView;
    }

    return nil;
}

@end
