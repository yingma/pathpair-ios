//
//  EmailFindViewController.h
//  SocialTracker
//
//  Created by Admin on 7/18/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailFindViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UITextField *textEmail;

- (IBAction)Search:(id)sender;

@end
