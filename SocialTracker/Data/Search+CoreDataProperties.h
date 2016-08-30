//
//  Search+CoreDataProperties.h
//  SocialTracker
//
//  Created by Admin on 5/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Search.h"

NS_ASSUME_NONNULL_BEGIN

@interface Search (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *ageFrom;
@property (nullable, nonatomic, retain) NSNumber *ageTo;
@property (nullable, nonatomic, retain) NSNumber *female;
@property (nullable, nonatomic, retain) NSNumber *male;
@property (nullable, nonatomic, retain) NSSet<Tag *> *tags;

@end

@interface Search (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet<Tag *> *)values;
- (void)removeTags:(NSSet<Tag *> *)values;

@end

NS_ASSUME_NONNULL_END
