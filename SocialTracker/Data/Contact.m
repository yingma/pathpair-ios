//
//  Contact.m
//  SocialTracker
//
//  Created by Ying Ma on 5/15/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "Contact.h"
#import "Meeting.h"
#import "Tag.h"

@implementation Contact

//@synthesize image;
@synthesize needRefresh;


// Insert code here to add functionality to your managed object subclass
- (void)addMeetingsObject:(Meeting *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.meetings];
    [tempSet insertObject:value atIndex:0];
    self.meetings = tempSet;
}

@end
