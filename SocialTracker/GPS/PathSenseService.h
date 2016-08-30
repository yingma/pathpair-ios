//
//  PathSenseService.h
//  SocialTracker
//
//  Created by Admin on 4/30/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kPathChangeNotification;

@interface PathSenseService : NSObject 

- (id)init;
//- (void) trimLocationHistory;

@property (nonatomic, readonly) CLLocation* location;
@property (nonatomic) bool on;

@end
