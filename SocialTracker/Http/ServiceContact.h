//
//  ServiceContact.h
//  SocialTracker
//
//  Created by Admin on 5/4/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceContact : NSObject

@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *uid;
//@property (nonatomic) double latitude;
//@property (nonatomic) double longitude;
@property (nullable, nonatomic, retain) NSString *bio;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSDate *birthday;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *lastname;
@property (nullable, nonatomic, retain) NSString *firstname;
@property (nullable, nonatomic, retain) NSString *photourl;


@end
