//
//  LocationService.h
//  SocialTracker
//
//  Created by Admin on 4/23/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kLocationChangeNotification;

@interface SignificantLocationService : NSObject <CLLocationManagerDelegate>

- (void)startSignificantChangeUpdates;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, readonly) CLLocation *location;

@end
