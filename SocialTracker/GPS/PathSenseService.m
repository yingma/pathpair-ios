//
//  PathSenseService.m
//  SocialTracker
//
//  Created by Ying Ma on 4/30/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//


//#import <PSLocation/PSlocation.h>
#import <CoreLocation/CoreLocation.h>

#import "PathSenseService.h"
#import "ServiceEngine.h"
#import "BLEPeripheralManager.h"
#import "NSObject+Event.h"

#import "AFNetworkReachabilityManager.h"

NSString * const kPathChangeNotification = @"kPathChangeNotification";

//@interface PathSenseService () <PSLocationManagerDelegate>
@interface PathSenseService () <CLLocationManagerDelegate>

//@property (nonatomic, readonly) PSLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;

- (void)updateUserLocation:(CLLocation *)location;

@end

@implementation PathSenseService


- (id)init{
    
    if ((self = [super init])) {
        
//        [PSLocation setApiKey:@"tRYuPbGcnY9KZ8kbcz50C74t0NPCxRr5LBSgg7K3" andClientID:@"rFtTNi7Xz4pyAq2jIaeMsCU9jYzjxPcCMytSrN5a"];
        
//        _locations = [NSMutableArray array];
        
//        _locationManager = [PSLocationManager new];
        
        // Create the location manager if this object does not
        // already have one.
        if (nil == self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
        
        [_locationManager setDelegate:self];
//       [_locationManager setMaximumLatency:20];
        [_locationManager setPausesLocationUpdatesAutomatically:NO];
        [_locationManager setDistanceFilter:50];
        
//        if ([CMMotionActivityManager isActivityAvailable]) {
//            [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//        } else {
//            [_locationManager setDesiredAccuracy:kPSLocationAccuracyPathSenseNavigation];
//        }
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS 8 or later
            [_locationManager requestAlwaysAuthorization];
        }
        
        if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {  // iOS 9 or later
            [_locationManager setAllowsBackgroundLocationUpdates:YES];
        }
        
        self.on = YES;
        
    }
    return self;
}

- (void) setOn:(bool)on {
    if (on) {
        _on = YES;
        [_locationManager startUpdatingLocation];
        
    } else {
        _on = NO;
        [_locationManager stopUpdatingLocation];
    }
 }

//- (void) trimLocationHistory {
//    
//    NSTimeInterval timeCutoff = [[(CLLocation *)[_locations lastObject] timestamp] timeIntervalSince1970] - 600.0;
//    if (timeCutoff < 0) {
//        return;
//    }
//    
//    NSMutableArray *mArray = [NSMutableArray array];
//    for (CLLocation *location in _locations) {
//        if ([[location timestamp] timeIntervalSince1970] >= timeCutoff) {
//            [mArray addObject:location];
//        }
//    }
//    _locations = [NSMutableArray arrayWithArray:mArray];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
//    [self trimLocationHistory];
//    
//    for (CLLocation *location in locations) {
//        [_locations insertObject:location atIndex:0];
//    }
    
    [self updateUserLocation:[locations lastObject]];
}

#pragma mark -
#pragma mark PSLocationManagerDelegate
#pragma mark -
//----------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Location Autorization" message:@"This application is not authorized to use location services!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
    } else {
        [_locationManager startUpdatingLocation];
    }
}

//----------------------------------------------------------------------------------
//- (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager
//             desiredAccuracyForActivity:(PSActivityType)activityType
//                         withConfidence:(PSActivityConfidence)confidence {
//    
//    CLLocationAccuracy result = [manager desiredAccuracy];
//    if (activityType == PSActivityTypeInVehicle || activityType == PSActivityTypeInVehicleStationary) {
//        if (result != kPSLocationAccuracyPathSenseNavigation) {
//            result = kPSLocationAccuracyPathSenseNavigation;
//        }
//        
//    } else {
//        if (result != kCLLocationAccuracyBest) {
//            result = kCLLocationAccuracyBest;
//        }
//    }
//    return result;
//}

#pragma mark - upload the location
//----------------------------------------------------------------------------------
- (void)updateUserLocation:(CLLocation *)location {
    
    // update the coordinate of location
    _location = location;
    
    // If the event is recent, do something with it.
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable)
        return;
    
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
        return;
    
    // If the event is recent, do something with it.
    [NSObject eventPostNotification:kPathChangeNotification
                           withDict:@{@"latitude":[NSString stringWithFormat:@"%f", location.coordinate.latitude], @"longitude":[NSString stringWithFormat:@"%f", location.coordinate.longitude]}];
    
    //static dispatch_once_t onceToken;
    
    //dispatch_once(&onceToken, ^{
        [[ServiceEngine sharedEngine] publishLongitude:location.coordinate.longitude
                                              latitude:location.coordinate.latitude
                                             doneBlock:^(NSError *error) {
                                             }];
    //});
    
}


@end
