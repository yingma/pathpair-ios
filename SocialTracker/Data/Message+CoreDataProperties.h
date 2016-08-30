//
//  Message+CoreDataProperties.h
//  SocialTracker
//
//  Created by Admin on 7/10/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"
#import "Room.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *mid;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *utime;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSNumber *sequence;

@end

NS_ASSUME_NONNULL_END
