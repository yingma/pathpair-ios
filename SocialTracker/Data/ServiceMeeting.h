//
//  ServiceMeeting.h
//  SocialTracker
//
//  Created by Admin on 5/30/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceMeeting : NSObject

@property (nullable, nonatomic, retain) NSString *mid;
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSString *matches;
@property (nullable, nonatomic, retain) NSString *matches1;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *uid1;
@property (nonatomic) float lengthInMinutes;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude1;
@property (nonatomic) double longitude1;

@end
