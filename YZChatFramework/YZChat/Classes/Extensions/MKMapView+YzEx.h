//
//  MKMapView+YzEx.h
//  YZChat
//
//  Created by 安笑 on 2021/4/5.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMapView (ZoomLevel)

@property (nonatomic, assign) int zoomLevel;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(int)zoomLevel animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
