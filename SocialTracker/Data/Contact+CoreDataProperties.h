//
//  Contact+CoreDataProperties.h
//  SocialTracker
//
//  Created by Admin on 7/20/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contact.h"
#import "Room.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bio;
@property (nullable, nonatomic, retain) NSDate *birthday;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *firstname;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSString *lastname;
@property (nullable, nonatomic, retain) NSNumber *like;
@property (nullable, nonatomic, retain) NSNumber *flag;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *photourl;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSOrderedSet<Meeting *> *meetings;
@property (nullable, nonatomic, retain) NSSet<Tag *> *tags;
@property (nullable, nonatomic, retain) Room *room;

@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)insertObject:(Meeting *)value inMeetingsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMeetingsAtIndex:(NSUInteger)idx;
- (void)insertMeetings:(NSArray<Meeting *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMeetingsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMeetingsAtIndex:(NSUInteger)idx withObject:(Meeting *)value;
- (void)replaceMeetingsAtIndexes:(NSIndexSet *)indexes withMeetings:(NSArray<Meeting *> *)values;
- (void)addMeetingsObject:(Meeting *)value;
- (void)removeMeetingsObject:(Meeting *)value;
- (void)addMeetings:(NSOrderedSet<Meeting *> *)values;
- (void)removeMeetings:(NSOrderedSet<Meeting *> *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet<Tag *> *)values;
- (void)removeTags:(NSSet<Tag *> *)values;

@end

NS_ASSUME_NONNULL_END
