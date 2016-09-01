//
//  RoomTableViewController.m
//  SocialTracker
//
//  Created by Admin on 7/9/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "RoomTableViewController.h"
#import "AppDelegate.h"
#import "Data/Room.h"
#import "Data/Contact.h"
#import "Http/ServiceEngine.h"
#import "UIImageView+AFNetworking.h"
#import "ChatViewController.h"
#import "RoomTableViewCell.h"
#import "NSDate+TimeAgo.h"
#import "DetailTableViewController.h"


@interface RoomTableViewController ()

@end

@implementation RoomTableViewController {
    
    NSMutableArray *_objectChanges;
    AppDelegate *_theApp;
    NSInteger _countNew;
    Room    *_room;
}

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    self.title = @"Chat";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(RoomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Room *room = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSArray<Contact*> *contacts = [[room.contacts allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid != %@", [[ServiceEngine sharedEngine] uid]]];
    
    if (contacts.count == 0)
        return;
    
    Contact* contact = contacts[0];
        
    ///gender is empty need to load the contact
    if (contact.needRefresh) {
        
        [[ServiceEngine sharedEngine] getContactByUid:contact.uid
                                           withSuccess:^(NSArray<ServiceContact *> * _Nullable contacts) {
                                               
            if (contacts.count > 0) {
            
                ServiceContact *sc = contacts[0];
                contact.lastname = sc.lastname;
                contact.firstname = sc.firstname;
                contact.gender = sc.gender;
                contact.username = sc.username;
                contact.bio = sc.bio;
                contact.birthday = sc.birthday;
               
                NSDictionary *sharedEngineConfiguration = [ServiceEngine sharedEngineConfiguration];
               
                if ([sc.photourl hasPrefix:@"https://"])
                   contact.photourl = sc.photourl;
                else
                   contact.photourl = [NSString stringWithFormat:@"%@%@", sharedEngineConfiguration[kServiceURLKey], sc.photourl];
                
                contact.needRefresh = NO;
                
                
               [self.tableView beginUpdates];
               [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
               [self.tableView endUpdates];
               
               // use 30 days ago date
                NSDate *start = [[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
               
               
              [[ServiceEngine sharedEngine] searchMeetingFromTime:start
                                                            toTime:nil
                                                            andUid:contact.uid
                                                       withSuccess:^(NSArray<ServiceMeeting *> * _Nullable meetings) {
                                                           
                       for (ServiceMeeting *meeting in meetings) {
                           
                           Meeting *m = [_theApp getMeeting:meeting.mid];
                           
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
                               
                               if ([meeting.uid isEqualToString:[[ServiceEngine sharedEngine] uid]])
                                   m.matches = meeting.matches;
                               else
                                   m.matches = meeting.matches1;
                               
                               [contact addMeetingsObject:m];
                           }
                           
                           if (meeting.lengthInMinutes != 0)
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
                       
                } failure:^(NSError * _Nullable error) {
           
                    NSLog(@"Web fetch meeting error %@, %@", error, [error userInfo]);
                    
                }];
                
            }
        
        } failure:^(NSError * _Nullable error) {
            
            NSLog(@"Web fetch contact error %@, %@", error, [error userInfo]);
        }];
        
    }
    
    
    cell.labelName.text = [NSString stringWithFormat:@"%@ %@", contact.firstname?:@"Anonymous", contact.lastname?:@"NA"];
    if (room.time != nil)
        cell.labelWhen.text = [room.time timeAgo];
    else
        cell.labelWhen.text = @"";
    
    [cell setBadgeCount:[room.badge integerValue]];
    
    if (room.messages.count > 0)
        cell.labelMessage.text = [room.messages lastObject].text;
    else if ([room.pending integerValue] == 1)
        cell.labelMessage.text = @"Request to like back";
    else if ([room.pending integerValue] == 2)
        cell.labelMessage.text = @"Please like back/unlike";
    else
        cell.labelMessage.text = @"";
    
    NSURL *URL = [NSURL URLWithString:contact.photourl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //Fix warning "Capturing [an object] strongly in this block is likely to lead to a retain cycle" in ARC-enabled code
    __weak RoomTableViewCell *wcell = cell;
    
    //if (wcell.imgView.image == nil)
        [cell.imgView setImageWithURLRequest:request
                            placeholderImage:[UIImage imageNamed:@"profile"]
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         wcell.imgView.image = image;
//                                         contact.image = image;
                                         [wcell setNeedsLayout];
                                       
                                   } failure:nil];
    
    
            
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChatCell";
    RoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    _room = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"enter %@", _room.rid);
    
    if ([_room.pending integerValue] == 2) // wait for approve
        [self performSegueWithIdentifier:@"detail" sender:self];
    else
        [self performSegueWithIdentifier:@"chat" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"chat"]) {
        
        ChatViewController *chat = (ChatViewController*)segue.destinationViewController;
        chat.room = _room;
        
        NSArray<Contact*> *contacts = [[_room.contacts allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid != %@", [[ServiceEngine sharedEngine] uid]]];
        
        assert (contacts.count > 0);
        
        chat.title = [NSString stringWithFormat:@"%@ %@", contacts[0].firstname, contacts[0].lastname];

        
    } else if ([segue.identifier isEqualToString:@"detail"]) {
        
        DetailTableViewController *controller = [segue destinationViewController];
        
        NSArray<Contact*> *contacts = [[_room.contacts allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid != %@", [[ServiceEngine sharedEngine] uid]]];
        
        if (contacts.count > 0)
            controller.contact = contacts[0];
        
        [_theApp setBadgeChat:-[_room.badge integerValue]];
        
        _room.badge = [NSNumber numberWithInteger:0];
        
        [_theApp saveContext];
    }
    
}


#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Room" inManagedObjectContext:_theApp.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"contacts.@count>0"]];
    [fetchRequest setPredicate:predicate];
    
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSSortDescriptor *sortTime = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortTime, sortName, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_theApp.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Room"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [sender locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath == nil) {
            NSLog(@"long press on table view but not on a row");
        } else {
            
            _room = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:@"Do you want to delete conversation"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yes = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     assert(_room != nil);
                                     [_theApp deleteRoom:_room];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            UIAlertAction* no = [UIAlertAction
                                     actionWithTitle:@"No"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            [alert addAction:yes];
            [alert addAction:no];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
