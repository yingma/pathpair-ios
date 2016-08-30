//
//  SignupGeoViewController.h
//  SocialTracker
//
//  Created by Admin on 6/8/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data/Contact.h"

@interface SignupGeoViewController : UIViewController

- (IBAction)signup:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *zipText;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignup;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;

@property (strong, nonatomic) Contact *contact;

@end
