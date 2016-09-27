//
//  RoomTableViewController.h
//  SocialTracker
//
//  Created by Ying Ma on 7/9/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RoomTableViewCell.h"

@interface RoomTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(RoomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
