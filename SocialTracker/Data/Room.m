//
//  Room.m
//  SocialTracker
//
//  Created by Admin on 7/7/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "Room.h"
#import "Contact.h"

@implementation Room

- (void)addMessagesObject:(Message *)message {
    
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.messages];
    if ([message.sequence integerValue] != 0)
        [tempSet addObject:message];
    else
        [tempSet insertObject:message
                      atIndex:0];
    
    self.messages = tempSet;
    self.time = [NSDate date];
}



@end
