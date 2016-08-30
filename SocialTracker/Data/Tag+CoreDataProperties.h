//
//  Tag+CoreDataProperties.h
//  SocialTracker
//
//  Created by Admin on 5/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tag.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tag (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *tag;

@end

NS_ASSUME_NONNULL_END
