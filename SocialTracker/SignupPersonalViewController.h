//
//  SignupPersonalViewController.h
//  SocialTracker
//
//  Created by Admin on 5/18/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data/Contact.h"

@interface SignupPersonalViewController : UIViewController

- (IBAction)signup:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSwitch;
//@property (weak, nonatomic) IBOutlet UITextField *zipText;

@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;

@property (strong, nonatomic) Contact *contact;


@end
