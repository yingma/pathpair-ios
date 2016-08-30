//
//  MyselfViewController.h
//  SocialTracker
//
//  Created by Ying Ma on 5/21/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface MyselfViewController : UITableViewController

- (void)loadContact;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) Contact *contact;

@end
