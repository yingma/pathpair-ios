//
//  Contact.h
//  SocialTracker
//
//  Created by Ying Ma on 5/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Meeting, Tag;

NS_ASSUME_NONNULL_BEGIN

@interface Contact : NSManagedObject

//@property (nullable, nonatomic, retain) UIImage *image;
@property (nonatomic) BOOL needRefresh;

@end

NS_ASSUME_NONNULL_END

#import "Contact+CoreDataProperties.h"
