//
//  MKMapView+YzEx.m
//  YZChat
//
//  Created by 安笑 on 2021/4/5.
//

#import "MKMapView+YzEx.h"

@implementation MKMapView (ZoomLevel)

- (int) zoomLevel {
    return (int)(log2(360 * (( self.frame.size.width/256.0) / self .region.span.longitudeDelta)) + 1);
}

- (void)setZoomLevel:(int)zoomLevel {
    [self setCenterCoordinate: self.centerCoordinate zoomLevel: zoomLevel animated: NO];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(int)zoomLevel
                   animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0, 360.0 / pow(2.0,  (double)zoomLevel) * self.frame.size.width / 256.0);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);

    [self setRegion: region animated: animated];
}

@end
