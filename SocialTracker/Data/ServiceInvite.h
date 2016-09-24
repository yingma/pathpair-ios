//
//  ServiceCriteria.h
//  SocialTracker
//
//  Created by Ying Ma on 8/8/16.
//  Copyright © 2016 Path Pair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceInvite : NSObject

@property (nullable, nonatomic, retain) NSString *rid; // message id
@property (nullable, nonatomic, retain) NSString *uid; // user id

@end