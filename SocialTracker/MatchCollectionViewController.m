//
//  MatchCollectionViewController.m
//  SocialTracker
//
//  Created by Ying Ma on 6/12/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "MatchCollectionViewController.h"
#import "MatchCollectionViewCell.h"
#import "Http/ServiceEngine.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+TimeAgo.h"
#import "DetailTableViewController.h"
#import "NSObject+Event.h"
#import "Data/Contact.h"
#import "ChatViewController.h"


@interface MatchCollectionViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MatchCollectionViewController {
    
    NSMutableArray *_objectChanges;
    AppDelegate *_theApp;
//    NSInteger _countNew;
    //NSString *_uid;
    
}

static NSString * const reuseIdentifier = @"ITEM_CELL";
//static NSString * const kCounter= @"COUNTER";

NSString * const kNewFindingNotification = @"kNewFindingNotification";


- (void)setupRefreshControl {
    
    // TODO: Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    ((CHTCollectionViewWaterfallLayout *)self.collectionViewLayout).minimumColumnSpacing = 0;
    
    // location event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDiscoverNewMatch:)
                                                 name:kNewFindingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageDidChange:)
                                                 name:kMessageChangeNotification
                                               object:nil];
    
    _objectChanges = [NSMutableArray array];
    
    //_uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUIDKey];
    
    // Do any additional setup after loading the view.
    [self setupRefreshControl];
    
    //adjust the size of collection view.
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.collectionView.contentInset = adjustForTabbarInsets;
    self.collectionView.scrollIndicatorInsets = adjustForTabbarInsets;
    
    //self.collectionView.delegate = self;
    // put request here request loading the data here

    self.collectionView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
    // kick off your async refresh!
    [self refresh: self];
    
    //_countNew = [[NSUserDefaults standardUserDefaults] integerForKey:kCounter];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)refresh:(id)sender{
    
    NSLog(@"refresh");
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    //Meeting *lastMeeting = [_theApp lastMeeting];
    
    // use 30 days ago date
    NSDate *start = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    
//    if (lastMeeting != nil)
//        start = lastMeeting.start;
    
    [[ServiceEngine sharedEngine] searchMeetingFromTime:start
                                                 toTime:nil
                                            withSuccess:^(NSArray<ServiceMeeting *> * _Nullable meetings) {
                                                    
                                                    for (ServiceMeeting *meeting in meetings) {
                                                        
                                                        Meeting *m = [_theApp getMeeting:meeting.mid];
                                                        
                                                        NSString * uid = [[ServiceEngine sharedEngine] uid];
                                                        
                                                        if ([meeting.uid1 isEqualToString:uid])
                                                            uid = meeting.uid;
                                                        else
                                                            uid = meeting.uid1;
                                                             
                                                        
                                                        Contact *contact = [_theApp getContactbyUid:uid];
                                                        if (contact == nil) {
                                                            contact = [_theApp newContact];
                                                            contact.uid = uid;
                                                            contact.flag = [NSNumber numberWithInteger:1]; // new
                                                            
                                                            
                                                        } else if (m == nil)
                                                            contact.flag = [NSNumber numberWithInteger:2];
                                                        
                                                        //NSLog(@"%@ %d", uid, [contact.flag integerValue]);
                                                        
                                                        contact.needRefresh = YES;
                                                        
                                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                                                        
                                                        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                                                        [formatter setLocale:posix];
                                                        
                                                        if (m == nil) {
                                                            m = [_theApp newMeeting];
                                                            m.mid = meeting.mid;
                                                            m.start = [formatter dateFromString:meeting.time];
                                                            m.longitude = [NSNumber numberWithDouble:meeting.longitude];
                                                            m.latitude = [NSNumber numberWithDouble:meeting.latitude];
                                                            m.contact = contact;
                                                            [contact addMeetingsObject:m];
                                                            
                                                        }
                                                        
                                                        if ([meeting.uid isEqualToString:[[ServiceEngine sharedEngine] uid]])
                                                            m.matches = meeting.matches;
                                                        else
                                                            m.matches = meeting.matches1;
                                                        
                                                        if ([contact.flag integerValue] == 1 && m.matches != nil) {
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^ {
                                                                [_theApp setBadgeMatch:1];
                                                            });
                                                        }
                                                        
                                                        
                                                        if (meeting.lengthInMinutes >= 1) // less 1 minutes
                                                            m.length = [NSNumber numberWithFloat:meeting.lengthInMinutes];
                                                        else { // when length is zero, calc minutes on the fly
                                                            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:m.start];
                                                            // Then use it
                                                            m.length = [NSNumber numberWithFloat:interval / 60];
                                                        }
    
                                                        m.longitude1 = [NSNumber numberWithDouble:meeting.longitude1];
                                                        m.latitude1 = [NSNumber numberWithDouble:meeting.latitude1];
                                                        
                                                        contact.time = [NSDate date];
                                                        

                                                        [_theApp saveContext];
                                                        
                                                    }
                                                
                                                    // When done requesting/reloading/processing invoke endRefreshing, to close the control
                                                    [self.refreshControl endRefreshing];
                                                
                                                    dispatch_async(dispatch_get_main_queue(), ^ {
                                                        [self.collectionView reloadData];
                                                    });
                                                    
                                                }
                                                failure:^(NSError * _Nullable error) {
                                                    
                                                    if ([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"Request failed: unauthorized (401)"]) {
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^ {
                                                            [[ServiceEngine sharedEngine] logout];
                                                            [_theApp enterLoginSegue];
                                                        });
                                                    }
                                                        
                                                    
                                                     // When done requesting/reloading/processing invoke endRefreshing, to close the control
                                                    [self.refreshControl endRefreshing];
                                                        
                                                }];

        
        NSLog(@"DONE");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (void)loadCell:(MatchCollectionViewCell*)cell
     withContact:(Contact *)contact{
    
//    if (contact.uuid != nil)
    [[ServiceEngine sharedEngine] getContactByUid:contact.uid
                                          withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
                                               
            if (contacts.count > 0) {
               
               ServiceContact *sc = contacts[0];
               contact.uuid = sc.uuid;
               contact.lastname = sc.lastname;
               contact.firstname = sc.firstname;
               contact.gender = sc.gender;
               contact.username = sc.username;
               contact.bio = sc.bio;
               contact.birthday = sc.birthday;
               contact.city = sc.city;
               contact.company = sc.company;
               contact.needRefresh = NO;
               
               NSDictionary *sharedEngineConfiguration = [ServiceEngine sharedEngineConfiguration];
               
               if ([sc.photourl hasPrefix:@"https://"])
                   contact.photourl = sc.photourl;
               else
                   contact.photourl = [NSString stringWithFormat:@"%@%@", sharedEngineConfiguration[kServiceURLKey], sc.photourl];
               
               [_theApp saveContext];
               
               NSURL *URL = [NSURL URLWithString:contact.photourl];
               NSURLRequest *request = [NSURLRequest requestWithURL:URL];
               
               [cell.imgView setImageWithURLRequest:request
                                   placeholderImage:[UIImage imageNamed:@"profile"]
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                
                                                cell.imgView.image = image;
                                                [cell setNeedsLayout];
                                                
                                            } failure:nil];
                
                
               [[ServiceEngine sharedEngine] getProfile:contact.uuid
                                                    type:@"self"
                                             withSuccess:^(NSArray<NSString *> * _Nullable tags) {
                                                 
                                                 [contact removeTags:contact.tags];
                                                 
                                                 for (NSString *t in tags) {
                                                     
                                                     Tag * tag = [_theApp newTag:t];
                                                     [contact addTagsObject:tag];
                                                     
                                                 }
                                                 
                                                 [_theApp saveContext];
                                                 
                                             } failure:^(NSError * _Nullable error) {
                                                 
                                             }];
               
           }
           
           
       } failure:^(NSError * _Nullable error) {
           
       }];

}

- (void)renderCell:(MatchCollectionViewCell*)cell
       withContact:(Contact *)contact{
    
    //if (contact.meetings.count > 0) {
        if (contact.meetings.count == 1) {
            cell.labelTimes.text = @"For the first time.";
        } else {
            cell.labelTimes.text = [NSString stringWithFormat:@"Encounter %u times", contact.meetings.count];
        }
        
        Meeting *meeting = [contact.meetings lastObject];
        
        cell.labelWhen.text = [meeting.start timeAgo];
        
        if (meeting.matches != nil) {
            cell.imgFlag.hidden = NO;
            cell.backView.backgroundColor = [UIColor redColor];
            
            if ([contact.flag integerValue] == 1) {
                
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Matched:%@", meeting.matches]];
                [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
                                        range:NSMakeRange(0, meeting.matches.length + 8)];
                cell.labelMatches.attributedText = attributedText;
                
            } else {
                cell.labelMatches.text = [NSString stringWithFormat:@"Matched:%@", meeting.matches];
            }
            
        } else if (contact.bio != nil && ![contact.bio isEqualToString:@""]){
            cell.imgFlag.hidden = YES;
            cell.labelMatches.text = contact.bio;
            cell.backView.backgroundColor = [self.view tintColor];
        } else {
            cell.imgFlag.hidden = YES;
            cell.labelMatches.text = @"No biography";
            cell.backView.backgroundColor = [self.view tintColor];
        }
        
        if (contact.firstname != nil) {
            cell.labelName.text = contact.firstname;
        } else {
            cell.labelName.text = @"Anonymous";
        }
        
        if (contact.birthday != nil) {
            
            NSDate* now = [NSDate date];
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                               components:NSCalendarUnitYear
                                               fromDate:contact.birthday
                                               toDate:now
                                               options:0];
            
            cell.labelAge.text = [NSString stringWithFormat:@"%ld", (long)[ageComponents year]];
        } else {
            cell.labelAge.text = @"";
        }
    //}
    
    if (contact.photourl != nil) {
        
        NSURL *URL = [NSURL URLWithString:contact.photourl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [cell.imgView setImageWithURLRequest:request
                            placeholderImage:[UIImage imageNamed:@"profile"]
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         
                                         cell.imgView.image = image;
                                         [cell setNeedsLayout];
                                         
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error){
                                         NSLog(@"loading image error:%@",error.description);
                                     }];
    }
    
    //NSLog(@"%d", [contact.room.pending integerValue]);
    
    if (contact.rooms.count > 0) {
        
        Room *room = [contact.rooms allObjects][0];
        
        if ([room.pending integerValue] == 2)
            [cell.buttonLike setTitle: @"Like" forState: UIControlStateNormal];
        else
            [cell.buttonLike setTitle: @"Unlike" forState: UIControlStateNormal];


        NSLog(@"%d", room.contacts.count);
        if (room.contacts.count > 1)
            cell.buttonChat.hidden = NO;
        else
            cell.buttonChat.hidden = YES;
        
    } else {
    
        [cell.buttonLike setTitle: @"Like" forState: UIControlStateNormal];
        cell.buttonChat.hidden = YES;
    }
        

}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MatchCollectionViewCell *cell = (MatchCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                                         forIndexPath:indexPath];
    
    [cell.buttonDelete addTarget:self
                          action:@selector(deleteButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell.buttonLike addTarget:self
                        action:@selector(likeButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [cell.buttonChat addTarget:self
                        action:@selector(chatButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ///gender is empty need to load the contact
    if (contact.needRefresh)
        [self loadCell:cell withContact:contact];
    else
        [self renderCell:cell withContact:contact];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detail"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        DetailTableViewController *controller = [segue destinationViewController];
        Contact *contact = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        if ([contact.flag integerValue] == 1) {
            contact.flag = [NSNumber numberWithInteger:2];
            [_theApp saveContext];
        }
        
        Meeting *meeting = [contact.meetings lastObject];
        
        if (meeting.matches != nil) {
            [_theApp setBadgeMatch:-1];
        }
        
        controller.contact = contact;
        
    } else if ([[segue identifier] isEqualToString:@"chat"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        Contact *contact = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        ChatViewController *chat = (ChatViewController*)segue.destinationViewController;
        chat.title = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
        
        if (contact.rooms.count > 0) {
            
            Room * room = [contact.rooms allObjects][0];
        
            chat.room = room;
        
            [_theApp setBadgeChat:-[room.badge integerValue]];
            room.badge = [NSNumber numberWithInteger:0];
        
            [_theApp saveContext];
            
        }

    }
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:_theApp.managedObjectContext];
    
    // exclude one
    // advertise via bluetooth
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kUUIDKey];
    assert(uuid != nil);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(uuid <> '%@') AND (flag <> 0) ", uuid]]; // inbox for
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:_theApp.managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    if ([_objectChanges count] > 0) {
        
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _objectChanges) {
                
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type) {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    [_objectChanges removeAllObjects];
}

- (void)didDiscoverNewMatch:(NSNotification*)notif{

    [self refresh:self];
}



#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(153, 209);
}


#pragma mark - event

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

- (IBAction)deleteButtonPressed:(UIButton *)button{
    
    //Acccess the cell
    MatchCollectionViewCell *cell = [[[button superview] superview] superview];
    button.enabled = NO;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];

    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    contact.flag = [NSNumber numberWithInteger:0];

    [_theApp saveContext];
}

- (IBAction)chatButtonPressed:(UIButton *)button{
    
    MatchCollectionViewCell *cell = [[[button superview] superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self performSegueWithIdentifier:@"chat" sender:self];
}

- (IBAction)likeButtonPressed:(UIButton *)button{
    
    //Acccess the cell
    MatchCollectionViewCell *cell = [[[button superview] superview] superview];
    button.enabled = NO;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (contact.rooms.count == 0) { // need to send invite to other side
        
        [[ServiceEngine sharedEngine] createRoomWithDoneBlock:^(NSString * _Nonnull roomid) {
            
            if (roomid != nil) {
                //create a new chat room here

                [[ServiceEngine sharedEngine] inviteUser:contact.uid
                                                  toRoom:roomid
                                           WithDoneBlock:^(NSError * _Nullable error) {
                                               
                                               if (error) {
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       button.enabled = YES;
                                                   });
                                                   
                                                   return;
                                               }
                                               
                                               // add room and contact to the room
                                               Room *r = [_theApp newRoom];
                                               r.rid = roomid;
                                               r.pending = [NSNumber numberWithInteger:1]; // pending on request
                                               
                                               //NSLog(@"%d", contact.room.contacts.count);
                                               
                                               // add other to the room
                                               [_theApp enterRoom1:r
                                                           andUser:contact];

                                               //enter chat room
                                               NSDictionary *parameters = @{@"roomId" : roomid};
                                               NSArray *array = [NSArray arrayWithObject:parameters];
                                               [[WebSocketEngine sharedEngine] emit:@"enter" args:array];
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   
                                                   button.enabled = YES;
                                                   
                                                   UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Invite sent"
                                                                                                                message:[[@"Like " stringByAppendingString:contact.firstname ?: @"Anonymous"] stringByAppendingString:@" once he/she likes back so you can chat"]
                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                               
                                                   UIAlertAction *okAction = [UIAlertAction
                                                                          actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                          style:UIAlertActionStyleCancel
                                                                          handler:^(UIAlertAction *action) {
                                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                                          }];
                                               
                                                   [alert addAction:okAction];
                                               
                                                   [self presentViewController:alert animated:YES completion:nil];
                                               });
                                        }];
            }
        }];
        
    } else if (contact.rooms.count > 0) {
        
        Room *room = [contact.rooms allObjects][0];
        
        if ([room.pending integerValue] == 2) { //like
        
//enter chat room
            [[ServiceEngine sharedEngine] enterRoom:room.rid
                                            andUser:contact.uid
                                      withDoneBlock:^(NSError * _Nullable error) {
                                      
                                        if (error) {
                                          
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                button.enabled = YES;
                                              
                                                UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                               message:[[@"Cannot like " stringByAppendingString:contact.firstname ?: @""] stringByAppendingString:@" because she/he unliked you"]
                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                              
                                                UIAlertAction *okAction = [UIAlertAction
                                                                         actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                         style:UIAlertActionStyleCancel
                                                                         handler:^(UIAlertAction *action)
                                                                         {
                                                                             //NSLog(@"ok action");
                                                                         }];
                                              
                                                [alert addAction:okAction];
                                              
                                                [self presentViewController:alert animated:YES completion:^{
                                                            
                                                        [_theApp setBadgeChat:-[room.badge integerValue]];
                                                        [_theApp deleteRoom:room];
                                                    
                                                        [contact removeRoomsObject:room];
                                                        //contact.room = nil;
                                                        [_theApp saveContext];
                                        
                                                 }];
                                            });
                                                                                  
                                            return;
                                        }
                                      
                                      
                                        Contact* c = [_theApp getContactbyUid:[[ServiceEngine sharedEngine] uid]];
                                        //[contact.room addContactsObject:c];
                                        room.pending = [NSNumber numberWithInteger:0];
                                        [_theApp enterRoom1:room andUser:c];
                                      
                                      
                                        // enter the room
                                        NSDictionary *parameters = @{@"roomId" : room.rid};
                                        NSArray *array = [NSArray arrayWithObject:parameters];
                                        [[WebSocketEngine sharedEngine] emit:@"enter" args:array];
                                      
                                  }];

        
        } else {
        
        // indicate to leave the room
        
            NSString *const kMessageSequence = @"MessageSequence";

            NSInteger seq = [[NSUserDefaults standardUserDefaults] integerForKey:kMessageSequence];
            NSDictionary *parameters = @{kAppSocketRoomId: room.rid, kAppSocketMessage : @"Unlike you and left room", kAppSocketSequence : [NSString stringWithFormat: @"%ld", (long)++seq]};
            NSArray *array = [NSArray arrayWithObject:parameters];
            [[WebSocketEngine sharedEngine] emitWithAck:@"send"
                                                   args:array
                                  withCompletionHandler:^() {
                                  
                                      NSDictionary *parameters = @{@"roomId" : room.rid};
                                      NSArray *array = [NSArray arrayWithObject:parameters];
                                      [[WebSocketEngine sharedEngine] emit:@"leave" args:array];
                                  
                                      [_theApp setBadgeChat:-[room.badge integerValue]];
                                      room.badge = [NSNumber numberWithInteger:0];
                                  
                                      [_theApp deleteRoom:room];
                                      
                                      //[contact removeRoomsObject:room];
                                      //contact.room = nil;
                                      [_theApp saveContext];
                                  }];
        
        

        }

    }
    
}


- (void)messageDidChange: (NSNotification*) aNotification {
    
//    NSDictionary* info = [aNotification userInfo];
//    ServiceMessage *m = [info objectForKey:@"message"];
//    
//    if (m.type == MessageTypeSubscribe) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^ {
//            [self.collectionView reloadData];
//        });
//        
//    } else if (m.type == MessageTypeSubscribe) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^ {
//            [self.collectionView reloadData];
//        });
//    }
}


@end
