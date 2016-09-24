//
//  ChatViewController.h
//  SocialTracker
//
//  Created by Ying Ma on 7/9/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//
#import "JSQMessages.h"
#import <CoreData/CoreData.h>
#import "Data/Room.h"

@interface ChatViewController : JSQMessagesViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) Room *room;

-(void) messageDidChange: (NSNotification*) aNotification;

@end
