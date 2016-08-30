//
//  DetailTableViewController.m
//  SocialTracker
//
//  Created by Admin on 6/24/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "DetailTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MeetingViewController.h"
#import "AppDelegate.h"
#import "ServiceEngine.h"
#import "ChatViewController.h"

@interface DetailTableViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation DetailTableViewController {
    
    AppDelegate *_theApp;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.topItem.title = @"Match";
    
    _theApp = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    if (self.contact != nil) {
        
        // load image
        NSURL *URL = [NSURL URLWithString:self.contact.photourl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [self.imageView setImageWithURLRequest:request
                            placeholderImage:[UIImage imageNamed:@"profile"]
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         
                                         self.imageView.image = image;
                                         [self.cellInfo setNeedsLayout];
                                         
                                     } failure:nil];
        
        self.labelName.text = [NSString stringWithFormat:@"%@ %@", self.contact.firstname?:@"NA", self.contact.lastname?:@"NA"];
        self.labelCity.text = self.contact.city;
        self.labelGender.text = self.contact.gender;
        self.labelCompany.text = self.contact.company;
        
        if (self.contact.meetings.count > 0 && [self.contact.meetings lastObject].matches != nil)
            self.imageFlag.hidden = NO;
        else
            self.imageFlag.hidden = YES;
        
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                          fromDate:self.contact.birthday
                                                                            toDate:now
                                                                           options:0];
        
        self.labelAge.text = [NSString stringWithFormat:@"%ld years old", (long)[ageComponents year]];
   
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        
        Search * search = [_theApp getCriteria];
        
        // mark matches tags
        for (Tag *t in self.contact.tags) {
            NSMutableAttributedString *attributedWord = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", t.tag]];
            for (Tag *tagSearch in search.tags) {
                if ([tagSearch.tag isEqualToString:t.tag]) {
                
                        [attributedWord addAttribute:NSForegroundColorAttributeName
                                               value:[UIColor redColor]
                                               range:NSMakeRange(0, tagSearch.tag.length + 1)];
                }
            }
            
            [attributedString appendAttributedString:attributedWord];
        }
        
        
        self.cellTags.detailTextLabel.attributedText = attributedString;
        self.cellBio.detailTextLabel.text = self.contact.bio;

        // view controllers are created lazily
        // in the meantime, load the array with placeholders which will be replaced on demand
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < self.contact.meetings.count; i++) {
            [controllers addObject:[NSNull null]];
        }
        self.viewControllers = controllers;

        self.scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        
        self.pageControl.numberOfPages = self.contact.meetings.count;
        self.pageControl.currentPage = 0;
        
        // pages are created on demand
        // load the visible page
        // load the page on either side to avoid flashes when the user starts scrollin
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageDidChange:)
                                                     name:kMessageChangeNotification
                                                   object:nil];
        
        if (self.contact.room!= nil && [self.contact.room.pending integerValue] != 2) {
            [self.buttonLike setTitle: @"Unlike" forState: UIControlStateNormal];
            
            if (self.contact.room.contacts.count > 1)
                self.buttonChat.hidden = NO;
            else
                self.buttonChat.hidden = YES;
            
        } else {
            
            [self.buttonLike setTitle: @"Like" forState: UIControlStateNormal];
            self.buttonChat.hidden = YES;
        }

            
    
        
        // adjust the contentSize (larger or smaller) depending on the orientation
        self.scrollView.contentSize =
        CGSizeMake(CGRectGetWidth(self.scrollView.frame) * self.contact.meetings.count, CGRectGetHeight(self.scrollView.frame));

    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 4;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return 165;
    else if (indexPath.row == 3)
        return 208;
    else if (indexPath.row == 2 && self.contact != nil && ![self.contact.bio isEqualToString:@""]) {
        CGSize size = [self.contact.bio sizeWithAttributes:
                       @{NSFontAttributeName: [UIFont systemFontOfSize:16.0f]}];
        return size.height + 24;
    }
    
    return 44.0;
    
}


- (void)loadScrollViewWithPage:(NSUInteger)page {
    
    if (page >= self.contact.meetings.count)
        return;
    
    // replace the placeholder if necessary
    MeetingViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"map"];
        [controller loadView];
        controller.meeting = self.contact.meetings[page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated {
    
    NSInteger page = self.pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender {
    [self gotoPage:YES];    // YES = animate
}

- (IBAction)doLike:(id)sender {
    
    self.buttonLike.enabled = NO;
    
    if (self.contact.room == nil) {
        
            [[ServiceEngine sharedEngine] createRoomWithDoneBlock:^(NSString * _Nonnull roomid) {
                
                if (roomid != nil)
                      [[ServiceEngine sharedEngine] inviteUser:self.contact.uid
                                                        toRoom:roomid
                                                 WithDoneBlock:^(NSError * _Nullable error) {
                                                     
                                                     self.buttonLike.enabled = YES;
                                                     
                                                     if (error != nil)
                                                         return;
                                                     

                                                     [self.buttonLike setTitle: @"Unlike" forState: UIControlStateNormal];
                                                     
                                                     // add room and contact to the room
                                                     Room *r = [_theApp newRoom];
                                                     r.name = [NSString stringWithFormat:@"%@ %@", self.contact.firstname, self.contact.lastname];
                                                     r.rid = roomid;
                                                     r.pending = [NSNumber numberWithInteger:1];
                                                     
                                                     r.badge = [NSNumber numberWithInteger:0];
                                                     [_theApp setBadgeChat:0];
                                                     
                                                     [_theApp enterRoom1:r
                                                                 andUser:self.contact];
                                                     
                                                     // enter the room
                                                     NSDictionary *parameters = @{@"roomId" : self.contact.room.rid};
                                                     NSArray *array = [NSArray arrayWithObject:parameters];
                                                     [[WebSocketEngine sharedEngine] emit:@"enter" args:array];
                                                     
                                                     UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Invite sent"
                                                                                                                      message:[[@"Like " stringByAppendingString:self.contact.firstname ?: @""] stringByAppendingString:@" once he/she likes back so you can chat"]
                                                                                                               preferredStyle:UIAlertControllerStyleAlert];
                                                     
                                                     UIAlertAction *okAction = [UIAlertAction
                                                                                    actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                                    style:UIAlertActionStyleCancel
                                                                                    handler:^(UIAlertAction *action)
                                                                                    {
                                                                                        //NSLog(@"ok action");
                                                                                    }];
                                                     
                                                     [alert addAction:okAction];
                                                     
                                                     [self presentViewController:alert animated:YES completion:nil];
                                                     
                                                 }];
            }];
            
    } else if ([self.contact.room.pending integerValue] == 2){
            

        
            NSDictionary *parameters = @{@"roomId" : self.contact.room.rid};
            NSArray *array = [NSArray arrayWithObject:parameters];
            [[WebSocketEngine sharedEngine] emit:@"enter" args:array];
            
            //enter chat room
            [[ServiceEngine sharedEngine] enterRoom:self.contact.room.rid
                                            andUser:self.contact.uid
                                      withDoneBlock:^(NSError * _Nullable error) {
                                      
                                      self.buttonLike.enabled = YES;
                                      
                                      if (error)
                                          return;
                                          
                                      [self.buttonLike setTitle: @"Unlike" forState: UIControlStateNormal];
                                          
                                      self.buttonChat.hidden = NO;
                                      
                                      Contact* c = [_theApp getContactbyUid:[[ServiceEngine sharedEngine] uid]];
                                      //[contact.room addContactsObject:c];
                                      self.contact.room.pending = [NSNumber numberWithInteger:0];
                                      [_theApp enterRoom1:self.contact.room andUser:c];
                                      
                                  }];

    } else {
        
        NSString *const kMessageSequence       = @"MessageSequence";
        
        NSInteger seq = [[NSUserDefaults standardUserDefaults] integerForKey:kMessageSequence];
        NSDictionary *parameters = @{kAppSocketRoomId: self.contact.room.rid, kAppSocketMessage : @"Unlike you and left room", kAppSocketSequence : [NSString stringWithFormat: @"%ld", (long)seq]};
        NSArray *array = [NSArray arrayWithObject:parameters];
        [[WebSocketEngine sharedEngine] emitWithAck:@"send"
                                               args:array
                              withCompletionHandler:^() {
                                  
                                  self.buttonLike.enabled = YES;
                                  
                                  [self.buttonLike setTitle: @"Like" forState: UIControlStateNormal];
                                  self.buttonChat.hidden = YES;
                                  
                                  NSDictionary *parameters = @{@"roomId" : self.contact.room.rid};
                                  NSArray *array = [NSArray arrayWithObject:parameters];
                                  [[WebSocketEngine sharedEngine] emit:@"leave" args:array];
                                  
                                  [_theApp deleteRoom:self.contact.room];
                                  
                              }];
        
        [_theApp setBadgeChat:-[self.contact.room.badge integerValue]];
        self.contact.room.badge = [NSNumber numberWithInteger:0];

        
//        [[ServiceEngine sharedEngine] leaveRoom:self.contact.room.rid
//                                        //andUser:self.contact.uid
//                                  withDoneBlock:^(NSError * _Nullable error) {
//                                      
//                                      self.buttonLike.enabled = YES;
//                                      
//                                      if (error)
//                                          return;
//                                      
//
//                                      [self.buttonLike setTitle: @"Like" forState: UIControlStateNormal];
//                                      self.buttonChat.hidden = YES;
//                                      
//                                      [_theApp deleteRoom:self.contact.room];
//                                      
//                                  }];

    }
}

- (IBAction)doDelete:(id)sender {
    
    self.contact.flag = [NSNumber numberWithInteger:0];
    
    [_theApp saveContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - message received method overrides

-(void) messageDidChange: (NSNotification*) aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    ServiceMessage *m = [info objectForKey:@"message"];
    
    if (self.contact.room == nil || ![m.room isEqualToString:self.contact.room.rid])
        return;
    
    
    
//    if (m.type == MessageTypeSubscribe) {
        
//        [_theApp deleteRoom:self.contact.room];
//        
//        [self.buttonLike setTitle: @"Like" forState: UIControlStateNormal];
//        self.buttonLike.enabled = YES;
        
//    } else if (m.type == MessageTypeSubscribe) {
        
//        Room *r = [_theApp newRoom];
//        r.rid = m.room;
//        self.contact.room = r;
//        [r addContactsObject:self.contact];
//        
//        [_theApp saveContext];
//        
//        [self.buttonLike setTitle: @"Unlike" forState: UIControlStateNormal];
//        self.buttonLike.enabled = YES;
        
//    }
    
}


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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"chat"]) {
        
        ChatViewController *chat = (ChatViewController*)segue.destinationViewController;
        chat.room = self.contact.room;
        chat.title = [NSString stringWithFormat:@"%@ %@", self.contact.firstname, self.contact.lastname];
        
        self.contact.room.badge = [NSNumber numberWithInteger:0];
        
        [_theApp saveContext];
        
    }


 
}


@end
