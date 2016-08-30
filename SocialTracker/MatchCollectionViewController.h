//
//  MatchCollectionViewController.h
//  SocialTracker
//
//  Created by Admin on 6/12/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "MatchCollectionViewCell.h"
#import "Contact.h"


@interface MatchCollectionViewController : UICollectionViewController<NSFetchedResultsControllerDelegate, CHTCollectionViewDelegateWaterfallLayout>

- (void)refresh:(id)sender;

- (IBAction)deleteButtonPressed:(UIButton *)button;

- (IBAction)likeButtonPressed:(UIButton *)button;

- (IBAction)chatButtonPressed:(UIButton *)button;


- (void)loadCell:(MatchCollectionViewCell*)cell
     withContact:(Contact *)contact;

- (void)renderCell:(MatchCollectionViewCell*)cell
       withContact:(Contact *)contact;

- (void)messageDidChange: (NSNotification*) aNotification;
    
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
