//
//  LocationService.m
//  SocialTracker
//
//  Created by Admin on 4/23/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "SignificantLocationService.h"
#import "NSObject+Event.h"
#import "ServiceEngine.h"
#import "AFNetworkReachabilityManager.h"
#import "PathSenseService.h"

@implementation SignificantLocationService

NSString * const kLocationChangeNotification = @"kLocationChangeNotification";

- (void)startSignificantChangeUpdates {
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    // Only report to location manager if the user has traveled 100 meters
    self.locationManager.distanceFilter = 100.0f;
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS 8 or later
        [_locationManager requestAlwaysAuthorization];
    }
    
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {  // iOS 9 or later
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (fabs(howRecent) < 15.0) {
        
        // update coordinate of the location
        _location = location;
        
        // update the web service if online
        if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable)
            return;
        
        // give way to use more accurate position service
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kGPSKey])
            return;
        
        // If the event is recent, do something with it.
        [NSObject eventPostNotification:kLocationChangeNotification
                               withDict:@{@"latitude":[NSString stringWithFormat:@"%f", location.coordinate.latitude], @"longitude":[NSString stringWithFormat:@"%f", location.coordinate.longitude]}];
        
        //static dispatch_once_t onceToken;
        
        //dispatch_once(&onceToken, ^{
            [[ServiceEngine sharedEngine] publishLongitude:location.coordinate.longitude
                                                  latitude:location.coordinate.latitude
                                                 doneBlock:^(NSError *error) {
                                                 }];
        //});

        
    }
}


@end
