//
//  DetailTableViewController.h
//  SocialTracker
//
//  Created by Admin on 6/24/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "Room.h"
#import "WebSocketEngine.h"

@interface DetailTableViewController : UITableViewController <UIScrollViewDelegate>

-(void) messageDidChange: (NSNotification*) aNotification;

- (void)loadScrollViewWithPage:(NSUInteger)page;

- (void)gotoPage:(BOOL)animated;

- (IBAction)doLike:(id)sender;

- (IBAction)doDelete:(id)sender;

- (IBAction)changePage:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageFlag;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelCompany;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelAge;
@property (weak, nonatomic) IBOutlet UILabel *labelGender;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellInfo;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTags;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBio;
@property (weak, nonatomic) IBOutlet UIButton *buttonLike;
@property (weak, nonatomic) IBOutlet UIButton *buttonChat;

@property (strong, nonatomic) Contact *contact;

@end
