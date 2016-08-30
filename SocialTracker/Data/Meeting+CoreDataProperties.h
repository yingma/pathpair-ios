//
//  Meeting+CoreDataProperties.h
//  SocialTracker
//
//  Created by Admin on 6/22/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Meeting.h"

@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface Meeting (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *length;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *mid;
@property (nullable, nonatomic, retain) NSDate *start;
@property (nullable, nonatomic, retain) NSString *matches;
@property (nullable, nonatomic, retain) Contact *contact;
@property (nullable, nonatomic, retain) NSNumber *latitude1;
@property (nullable, nonatomic, retain) NSNumber *longitude1;

@end

NS_ASSUME_NONNULL_END
