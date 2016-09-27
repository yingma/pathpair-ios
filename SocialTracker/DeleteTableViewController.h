//
//  DeleteTableViewController.h
//  SocialTracker
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Path Pair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DeleteTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
