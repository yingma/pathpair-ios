//
//  SignupViewController.h
//  SeeAndRate
//
//  Created by Admin on 2/17/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SignupViewController : UIViewController

- (IBAction)textEmailValueChanged:(id)sender;
- (IBAction)signup:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;


@end
